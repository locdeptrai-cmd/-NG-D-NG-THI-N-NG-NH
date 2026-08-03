from django.db import migrations


USERNAME = "atctester"
PASSWORD_HASH = "pbkdf2_sha256$1000000$qWRTWRLvEVYz0gqQOoffFT$5PrrveZqRloSLolFNmN7zUtZC8Hqvcp7v4muL5yuxeo="


def bootstrap_atctester(apps, schema_editor):
    Role = apps.get_model("exam_bank", "Role")
    User = apps.get_model("exam_bank", "User")

    enduser_role, _ = Role.objects.get_or_create(
        code="enduser",
        defaults={
            "name": "End User",
            "description": "Hoc vien thi thu",
        },
    )
    User.objects.update_or_create(
        username=USERNAME,
        defaults={
            "password": PASSWORD_HASH,
            "is_active": True,
            "is_staff": False,
            "is_superuser": False,
            "role": enduser_role,
        },
    )


class Migration(migrations.Migration):
    dependencies = [
        ("exam_bank", "0003_bootstrap_render_superuser"),
    ]

    operations = [
        migrations.RunPython(
            bootstrap_atctester,
            migrations.RunPython.noop,
        ),
    ]
