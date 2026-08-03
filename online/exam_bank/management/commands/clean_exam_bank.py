import re
from collections import defaultdict

from django.core.management.base import BaseCommand
from django.db import transaction

from exam_bank.importers import classify_question_category
from exam_bank.models import Category, Question
from exam_bank.question_lifecycle import (
    ARCHIVED_CODE_PREFIX,
    archive_question,
    question_has_history,
)


PLACEHOLDER_CATEGORIES = {
    "nội dung câu hỏi",
    "nội dung câu hỏi (*)",
    "noi dung cau hoi",
    "noi dung cau hoi (*)",
}


def normalized_text(value):
    return re.sub(r"\s+", " ", (value or "").strip()).casefold()


def question_signature(question):
    answers = tuple(
        sorted(
            (
                answer.label.strip().upper(),
                normalized_text(answer.content),
                bool(answer.is_correct),
                int(answer.order),
            )
            for answer in question.answers.all()
        )
    )
    return question.subject_id, normalized_text(question.content), answers


class Command(BaseCommand):
    help = (
        "Remove exact duplicate questions and classify placeholder categories. "
        "Dry-run by default; pass --apply to write changes."
    )

    def add_arguments(self, parser):
        parser.add_argument("--apply", action="store_true", help="Write changes")

    @transaction.atomic
    def handle(self, *args, **options):
        apply_changes = options["apply"]
        stats = {
            "duplicate_groups": 0,
            "duplicates_deleted": 0,
            "duplicates_archived": 0,
            "placeholder_reclassified": 0,
            "empty_categories_deleted": 0,
        }

        grouped = defaultdict(list)
        questions = list(
            Question.objects.exclude(code__startswith=ARCHIVED_CODE_PREFIX)
            .select_related("subject", "category")
            .prefetch_related("answers", "exam_questions", "attempt_answers")
            .order_by("id")
        )
        for question in questions:
            grouped[question_signature(question)].append(question)

        for duplicates in grouped.values():
            if len(duplicates) < 2:
                continue
            stats["duplicate_groups"] += 1
            # Prefer a historically referenced row as canonical so the oldest
            # exam links remain untouched.
            duplicates.sort(key=lambda q: (not question_has_history(q), q.id))
            for duplicate in duplicates[1:]:
                if question_has_history(duplicate):
                    stats["duplicates_archived"] += 1
                    if apply_changes:
                        archive_question(duplicate)
                else:
                    stats["duplicates_deleted"] += 1
                    if apply_changes:
                        duplicate.delete()

        placeholder_questions = Question.objects.filter(
            category__name__in=[
                "Nội dung câu hỏi",
                "Nội dung câu hỏi (*)",
                "Noi dung cau hoi",
                "Noi dung cau hoi (*)",
            ]
        ).select_related("subject", "category")
        for question in placeholder_questions:
            category_name = classify_question_category("", question.content)
            if normalized_text(category_name) in PLACEHOLDER_CATEGORIES:
                category_name = "General Knowledge"
            stats["placeholder_reclassified"] += 1
            if apply_changes:
                category, _ = Category.objects.get_or_create(
                    subject=question.subject, name=category_name
                )
                question.category = category
                question.save(update_fields=["category", "updated_at"])

        empty_categories = Category.objects.filter(questions__isnull=True)
        stats["empty_categories_deleted"] = empty_categories.count()
        if apply_changes:
            empty_categories.delete()
        else:
            transaction.set_rollback(True)

        mode = "APPLIED" if apply_changes else "DRY-RUN"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode}: duplicate_groups={stats['duplicate_groups']}, "
                f"deleted={stats['duplicates_deleted']}, "
                f"archived={stats['duplicates_archived']}, "
                f"reclassified={stats['placeholder_reclassified']}, "
                f"empty_categories={stats['empty_categories_deleted']}"
            )
        )
