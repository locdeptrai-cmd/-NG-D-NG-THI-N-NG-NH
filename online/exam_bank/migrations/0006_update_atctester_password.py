from django.db import migrations


USERNAME = "atctester"
# Password: ATC@123456
PASSWORD_HASH = (
    "pbkdf2_sha256$1000000$FJyPPZE9LbpNAEfwar47Cs$"
    "fDqYMpKt9rZizWKIolkA2k8m2qRFQb50llzNxj+3Fd0="
)


def update_atctester_password(apps, schema_editor):
    User = apps.get_model("exam_bank", "User")
    updated = User.objects.filter(username=USERNAME).update(
        password=PASSWORD_HASH,
        is_active=True,
    )
    if updated:
        return

    Role = apps.get_model("exam_bank", "Role")
    enduser_role, _ = Role.objects.get_or_create(
        code="enduser",
        defaults={
            "name": "End User",
            "description": "Hoc vien thi thu",
        },
    )
    User.objects.create(
        username=USERNAME,
        password=PASSWORD_HASH,
        is_active=True,
        is_staff=False,
        is_superuser=False,
        role=enduser_role,
    )


class Migration(migrations.Migration):
    dependencies = [
        ("exam_bank", "0005_normalize_acs_sup_hcm_subject"),
    ]

    operations = [
        migrations.RunPython(
            update_atctester_password,
            migrations.RunPython.noop,
        ),
    ]
