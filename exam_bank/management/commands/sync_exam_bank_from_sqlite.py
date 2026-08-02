import os
import sqlite3
from contextlib import closing
from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from exam_bank.api_services import ensure_question_packages, refresh_package
from exam_bank.models import SUBJECT_GROUPS, Answer, Category, Document, Question, Subject


class Command(BaseCommand):
    help = (
        "Sync subjects/categories/documents/questions/answers from local "
        "dev.sqlite3 into the active database (used on Render deploys)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--source",
            default=str(Path(settings.BASE_DIR) / "dev.sqlite3"),
            help="Path to source SQLite database (default: BASE_DIR/dev.sqlite3)",
        )
        parser.add_argument(
            "--force",
            action="store_true",
            help="Sync all subjects even when per-subject question counts already match",
        )
        parser.add_argument(
            "--subjects",
            nargs="*",
            default=None,
            help="Optional subject codes to sync (default: mismatched or all with --force)",
        )

    def handle(self, *args, **options):
        source_path = Path(options["source"])
        force = bool(options["force"] or os.getenv("RENDER_FORCE_EXAM_BANK_SYNC") == "1")
        if not source_path.exists():
            raise CommandError(f"Source SQLite not found: {source_path}")

        legacy_acc = Subject.objects.filter(code="ACC").first()
        if legacy_acc and not Subject.objects.filter(code="ACC HAN").exists():
            legacy_acc.code = "ACC HAN"
            legacy_acc.name = "ACC HAN"
            legacy_acc.save(update_fields=["code", "name"])

        for code in SUBJECT_GROUPS:
            Subject.objects.get_or_create(code=code, defaults={"name": code})

        snapshot = self._load_snapshot(source_path)
        source_counts = snapshot["counts"]

        if options["subjects"]:
            target_codes = list(options["subjects"])
        elif force:
            target_codes = sorted(source_counts.keys())
        else:
            target_codes = []
            for code, total in sorted(source_counts.items()):
                dest_total = Question.objects.filter(subject__code=code).count()
                if dest_total != total:
                    target_codes.append(code)
                    self.stdout.write(
                        f"Mismatch {code}: dest={dest_total} source={total}"
                    )

        if not target_codes:
            self.stdout.write(
                self.style.SUCCESS(
                    "Exam bank already matches source SQLite; skipping sync."
                )
            )
            self._refresh_packages()
            return

        self.stdout.write("Syncing subjects: " + ", ".join(target_codes))
        stats = self._apply_snapshot(snapshot, target_codes)
        self._refresh_packages()
        self.stdout.write(
            self.style.SUCCESS(
                "Synced exam bank from SQLite: "
                f"subjects={stats['subjects']}, categories={stats['categories']}, "
                f"documents={stats['documents']}, questions={stats['questions']}, "
                f"answers={stats['answers']}"
            )
        )

    def _refresh_packages(self):
        packages = ensure_question_packages()
        for package in packages:
            refresh_package(package)
        self.stdout.write(f"Refreshed {len(packages)} question package(s).")

    def _load_snapshot(self, source_path: Path):
        # Read-only snapshot so source can be the same file as the Django DB.
        uri = source_path.resolve().as_uri() + "?mode=ro"
        # sqlite3.Connection's context manager only commits/rolls back; it does
        # not close the handle.  Close it explicitly so deploy syncs and tests
        # do not leave the source SQLite file locked on Windows.
        with closing(sqlite3.connect(uri, uri=True)) as conn:
            conn.row_factory = sqlite3.Row
            counts = {
                row["code"]: int(row["total"])
                for row in conn.execute(
                    """
                    SELECT s.code AS code, COUNT(q.id) AS total
                    FROM exam_bank_subject s
                    LEFT JOIN exam_bank_question q ON q.subject_id = s.id
                    GROUP BY s.code
                    """
                )
            }
            subjects = [
                dict(row)
                for row in conn.execute(
                    "SELECT id, code, name FROM exam_bank_subject ORDER BY id"
                )
            ]
            documents = [
                dict(row)
                for row in conn.execute(
                    """
                    SELECT id, code, title, description, url
                    FROM exam_bank_document
                    ORDER BY id
                    """
                )
            ]
            categories = [
                dict(row)
                for row in conn.execute(
                    "SELECT id, name, subject_id FROM exam_bank_category ORDER BY id"
                )
            ]
            questions = [
                dict(row)
                for row in conn.execute(
                    """
                    SELECT id, code, content, explanation, question_type, subject_id,
                           category_id, difficulty, topic, position_scope, status,
                           is_locked_for_official_exam, reference_document_id
                    FROM exam_bank_question
                    ORDER BY id
                    """
                )
            ]
            answers = [
                dict(row)
                for row in conn.execute(
                    """
                    SELECT question_id, label, content, is_correct,
                           "order" AS sort_order
                    FROM exam_bank_answer
                    ORDER BY question_id, "order", id
                    """
                )
            ]

        answers_by_question = {}
        for row in answers:
            answers_by_question.setdefault(row["question_id"], []).append(row)

        return {
            "counts": counts,
            "subjects": subjects,
            "documents": documents,
            "categories": categories,
            "questions": questions,
            "answers_by_question": answers_by_question,
        }

    @transaction.atomic
    def _apply_snapshot(self, snapshot, target_codes):
        stats = {
            "subjects": 0,
            "categories": 0,
            "documents": 0,
            "questions": 0,
            "answers": 0,
        }
        target_set = set(target_codes)
        subject_id_map = {}
        for row in snapshot["subjects"]:
            if row["code"] not in target_set:
                continue
            subject, _ = Subject.objects.update_or_create(
                code=row["code"],
                defaults={"name": row["name"] or row["code"]},
            )
            subject_id_map[row["id"]] = subject
            stats["subjects"] += 1

        source_subject_ids = {
            row["id"] for row in snapshot["subjects"] if row["code"] in target_set
        }
        question_rows = [
            row
            for row in snapshot["questions"]
            if row["subject_id"] in source_subject_ids
        ]
        needed_document_ids = {
            row["reference_document_id"]
            for row in question_rows
            if row["reference_document_id"]
        }
        document_id_map = {}
        for row in snapshot["documents"]:
            if row["id"] not in needed_document_ids:
                continue
            document, _ = Document.objects.update_or_create(
                code=row["code"],
                defaults={
                    "title": row["title"] or row["code"],
                    "description": row["description"] or "",
                    "url": row["url"] or "",
                },
            )
            document_id_map[row["id"]] = document
            stats["documents"] += 1

        category_id_map = {}
        for row in snapshot["categories"]:
            if row["subject_id"] not in source_subject_ids:
                continue
            subject = subject_id_map.get(row["subject_id"])
            if subject is None:
                continue
            category = Category.objects.filter(
                subject=subject, name=row["name"]
            ).first()
            if category is None:
                category = Category.objects.create(subject=subject, name=row["name"])
            category_id_map[row["id"]] = category
            stats["categories"] += 1

        for row in question_rows:
            subject = subject_id_map.get(row["subject_id"])
            category = category_id_map.get(row["category_id"])
            if subject is None or category is None:
                continue

            question, _ = Question.objects.update_or_create(
                code=row["code"],
                defaults={
                    "content": row["content"] or "",
                    "explanation": row["explanation"] or "",
                    "question_type": row["question_type"] or Question.TYPE_SINGLE,
                    "subject": subject,
                    "category": category,
                    "difficulty": row["difficulty"] or "",
                    "topic": row["topic"] or "",
                    "position_scope": row["position_scope"] or "",
                    "status": row["status"] or Question.STATUS_DRAFT,
                    "is_locked_for_official_exam": bool(
                        row["is_locked_for_official_exam"]
                    ),
                    "reference_document": document_id_map.get(
                        row["reference_document_id"]
                    ),
                },
            )
            stats["questions"] += 1

            keep_labels = set()
            for answer_row in snapshot["answers_by_question"].get(row["id"], []):
                label = (answer_row["label"] or "").strip().upper()
                if not label:
                    continue
                keep_labels.add(label)
                Answer.objects.update_or_create(
                    question=question,
                    label=label,
                    defaults={
                        "content": answer_row["content"] or "",
                        "is_correct": bool(answer_row["is_correct"]),
                        "order": int(answer_row["sort_order"] or 1),
                    },
                )
                stats["answers"] += 1
            if keep_labels:
                question.answers.exclude(label__in=keep_labels).delete()

        return stats
