from django.db import migrations


USERNAME = "atc_admin_a8d3ced6"
PASSWORD_HASH = "pbkdf2_sha256$1000000$CbCdp0qn1Sbv7UfHo7nsBh$SwyoZJK2zLA7wnkY01r9JedPeBHI8wQBOpbKdq8AINk="


def bootstrap_render_superuser(apps, schema_editor):
    Role = apps.get_model("exam_bank", "Role")
    User = apps.get_model("exam_bank", "User")

    teacher_role, _ = Role.objects.get_or_create(
        code="endteacher",
        defaults={
            "name": "End Teacher",
            "description": "Giao vien quan tri ngan hang cau hoi",
        },
    )
    User.objects.update_or_create(
        username=USERNAME,
        defaults={
            "password": PASSWORD_HASH,
            "is_active": True,
            "is_staff": True,
            "is_superuser": True,
            "role": teacher_role,
        },
    )


class Migration(migrations.Migration):
    dependencies = [
        ("exam_bank", "0002_pwa_offline_sync"),
    ]

    operations = [
        migrations.RunPython(
            bootstrap_render_superuser,
            migrations.RunPython.noop,
        ),
    ]
