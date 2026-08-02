from django.apps import AppConfig


class ExamBankConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "exam_bank"

    def ready(self):
        from . import signals  # noqa: F401
