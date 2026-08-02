from pathlib import Path

from django.core.management.base import BaseCommand, CommandError

from exam_bank.importers import ImportError, import_questions_from_file, preview_import_classification


class Command(BaseCommand):
    help = "Import questions from CSV/XLSX with standardized format"

    def add_arguments(self, parser):
        parser.add_argument("file", type=str)
        parser.add_argument("--subject", type=str, default="GENERAL")
        parser.add_argument("--preview", action="store_true", help="Preview auto classification without importing")

    def handle(self, *args, **options):
        file_path = Path(options["file"])
        try:
            if options["preview"]:
                preview = preview_import_classification(file_path, options["subject"])
                self.stdout.write(f"File: {preview['file_name']}")
                self.stdout.write(f"Source code: {preview['source_code']}")
                self.stdout.write(f"Valid rows: {preview['record_count']}")
                self.stdout.write(f"Questions to import: {preview['import_count']}")
                for row in preview["rows"]:
                    self.stdout.write(f"- {row['subject']} | {row['category']}: {row['count']}")
                return

            result = import_questions_from_file(file_path, options["subject"])
        except ImportError as exc:
            raise CommandError(str(exc)) from exc

        by_subject = result.get("by_subject") or {}
        detail = ", ".join(f"{code}={count}" for code, count in sorted(by_subject.items())) or "none"
        self.stdout.write(
            self.style.SUCCESS(
                f"Imported {result.get('imported', 0)} questions from {file_path.name} "
                f"(valid rows: {result.get('record_count', 0)}; by group: {detail})"
            )
        )
