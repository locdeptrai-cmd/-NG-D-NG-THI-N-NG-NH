from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


def create_question_packages(apps, schema_editor):
    Subject = apps.get_model("exam_bank", "Subject")
    QuestionPackage = apps.get_model("exam_bank", "QuestionPackage")
    for subject in Subject.objects.all():
        QuestionPackage.objects.get_or_create(
            subject=subject,
            defaults={
                "package_id": f"{subject.code}-2026-PRACTICE",
                "name": f"Ngân hàng luyện tập {subject.code}",
            },
        )


class Migration(migrations.Migration):
    dependencies = [
        ("exam_bank", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="QuestionPackage",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("package_id", models.CharField(max_length=100, unique=True)),
                ("name", models.CharField(max_length=255)),
                ("version", models.PositiveBigIntegerField(default=1)),
                ("checksum", models.CharField(blank=True, max_length=80)),
                ("minimum_app_version", models.CharField(default="1.0.0", max_length=30)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("subject", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="question_package", to="exam_bank.subject")),
            ],
            options={"ordering": ["subject__code"]},
        ),
        migrations.CreateModel(
            name="PracticeAttempt",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("local_attempt_id", models.CharField(max_length=100)),
                ("client_id", models.CharField(blank=True, max_length=100)),
                ("started_at", models.DateTimeField()),
                ("completed_at", models.DateTimeField()),
                ("score", models.DecimalField(decimal_places=2, max_digits=5)),
                ("total_questions", models.PositiveIntegerField(default=0)),
                ("correct_answers", models.PositiveIntegerField(default=0)),
                ("answers", models.JSONField(blank=True, default=list)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("subject", models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name="practice_attempts", to="exam_bank.subject")),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="practice_attempts", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ["-completed_at", "-id"]},
        ),
        migrations.CreateModel(
            name="SyncOperation",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("client_id", models.CharField(max_length=100)),
                ("operation_id", models.CharField(max_length=100)),
                ("operation_type", models.CharField(max_length=100)),
                ("status", models.CharField(choices=[("completed", "Completed"), ("failed", "Failed")], default="completed", max_length=20)),
                ("payload", models.JSONField(blank=True, default=dict)),
                ("server_reference", models.CharField(blank=True, max_length=100)),
                ("last_error", models.TextField(blank=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("processed_at", models.DateTimeField(auto_now=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="sync_operations", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ["-created_at", "-id"]},
        ),
        migrations.AddConstraint(
            model_name="practiceattempt",
            constraint=models.UniqueConstraint(fields=("user", "local_attempt_id"), name="unique_user_local_practice_attempt"),
        ),
        migrations.AddConstraint(
            model_name="syncoperation",
            constraint=models.UniqueConstraint(fields=("user", "client_id", "operation_id"), name="unique_user_client_sync_operation"),
        ),
        migrations.RunPython(create_question_packages, migrations.RunPython.noop),
    ]
