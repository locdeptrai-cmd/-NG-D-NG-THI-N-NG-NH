from django.db import migrations


LEGACY_CODE = "ACS SUP HCM·"
CANONICAL_CODE = "ACS SUP HCM"
PACKAGE_ID = "ACS_SUP_HCM-2026-PRACTICE"


def normalize_acs_sup_hcm_subject(apps, schema_editor):
    Subject = apps.get_model("exam_bank", "Subject")
    Category = apps.get_model("exam_bank", "Category")
    Question = apps.get_model("exam_bank", "Question")
    QuestionPackage = apps.get_model("exam_bank", "QuestionPackage")

    legacy = Subject.objects.filter(code=LEGACY_CODE).first()
    canonical = Subject.objects.filter(code=CANONICAL_CODE).first()

    if legacy is not None and canonical is None:
        legacy.code = CANONICAL_CODE
        legacy.name = CANONICAL_CODE
        legacy.save(update_fields=["code", "name"])
        canonical = legacy
    elif legacy is not None and canonical is not None:
        for category in Category.objects.filter(subject=legacy):
            target, _ = Category.objects.get_or_create(
                subject=canonical,
                name=category.name,
            )
            Question.objects.filter(category=category).update(
                subject=canonical,
                category=target,
            )

        legacy_package = QuestionPackage.objects.filter(subject=legacy).first()
        canonical_package = QuestionPackage.objects.filter(subject=canonical).first()
        if legacy_package is not None and canonical_package is None:
            legacy_package.subject = canonical
            legacy_package.save(update_fields=["subject", "updated_at"])
        elif legacy_package is not None:
            legacy_package.delete()
        legacy.delete()

    if canonical is None:
        canonical = Subject.objects.create(
            code=CANONICAL_CODE,
            name=CANONICAL_CODE,
        )
    elif canonical.name != CANONICAL_CODE:
        canonical.name = CANONICAL_CODE
        canonical.save(update_fields=["name"])

    package = QuestionPackage.objects.filter(subject=canonical).first()
    if package is not None:
        package.package_id = PACKAGE_ID
        package.name = f"Ngân hàng luyện tập {CANONICAL_CODE}"
        package.save(update_fields=["package_id", "name", "updated_at"])


class Migration(migrations.Migration):
    dependencies = [
        ("exam_bank", "0004_bootstrap_atctester"),
    ]

    operations = [
        migrations.RunPython(
            normalize_acs_sup_hcm_subject,
            migrations.RunPython.noop,
        ),
    ]
