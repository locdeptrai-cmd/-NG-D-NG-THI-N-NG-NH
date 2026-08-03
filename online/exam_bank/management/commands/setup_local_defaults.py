import os

from django.conf import settings
from django.contrib.auth.models import Group, Permission
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.management.base import BaseCommand, CommandError

from exam_bank.models import SUBJECT_GROUPS, Role, Subject, User


LEGACY_DEFAULT_USERNAMES = ("admin", "endteacher", "enduser")
LEGACY_WEAK_PASSWORDS = ("123456", "admin123456")


class Command(BaseCommand):
    help = (
        "Create roles, subjects, groups and permissions. Demo users are only "
        "created when --create-users is explicitly supplied."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--create-users",
            action="store_true",
            help="Create admin/endteacher/enduser when they do not exist",
        )
        parser.add_argument(
            "--password",
            default=None,
            help=(
                "Initial password for newly created demo users. Prefer the "
                "ATC_BOOTSTRAP_PASSWORD environment variable."
            ),
        )

    def handle(self, *args, **options):
        role_user, _ = Role.objects.get_or_create(
            code="enduser",
            defaults={"name": "End User", "description": "Hoc vien thi thu"},
        )
        role_teacher, _ = Role.objects.get_or_create(
            code="endteacher",
            defaults={"name": "End Teacher", "description": "Giao vien quan tri ngan hang cau hoi"},
        )

        # Rename legacy ACC -> ACC HAN if present.
        legacy_acc = Subject.objects.filter(code="ACC").first()
        if legacy_acc and not Subject.objects.filter(code="ACC HAN").exists():
            legacy_acc.code = "ACC HAN"
            legacy_acc.name = "ACC HAN"
            legacy_acc.save(update_fields=["code", "name"])

        for code in SUBJECT_GROUPS:
            Subject.objects.get_or_create(code=code, defaults={"name": code})

        teacher_group, _ = Group.objects.get_or_create(name="question_teachers")
        teacher_perms = Permission.objects.filter(
            content_type__app_label="exam_bank",
            content_type__model__in=["question", "answer", "category", "subject", "document"],
        )
        teacher_group.permissions.set(teacher_perms)

        if options["create_users"]:
            password = options["password"] or os.getenv("ATC_BOOTSTRAP_PASSWORD")
            missing_password = any(
                not User.objects.filter(username=username).exists()
                for username in LEGACY_DEFAULT_USERNAMES
            )
            if missing_password and not password:
                raise CommandError(
                    "ATC_BOOTSTRAP_PASSWORD or --password is required when "
                    "creating users. No default password is provided."
                )
            if password:
                try:
                    validate_password(password)
                except ValidationError as exc:
                    raise CommandError("; ".join(exc.messages)) from exc

            admin = self._ensure_user(
                "admin", password, role_teacher, is_staff=True, is_superuser=True
            )
            teacher = self._ensure_user(
                "endteacher",
                password,
                role_teacher,
                is_staff=True,
                is_superuser=False,
            )
            teacher.groups.add(teacher_group)
            self._ensure_user(
                "enduser",
                password,
                role_user,
                is_staff=False,
                is_superuser=False,
            )
            self.stdout.write("Accounts ready: admin / endteacher / enduser")
        elif not settings.DEBUG:
            disabled = self._disable_legacy_weak_users()
            if disabled:
                self.stdout.write(
                    self.style.WARNING(
                        "Disabled legacy users with unchanged weak passwords: "
                        + ", ".join(disabled)
                    )
                )

        environment = "development" if settings.DEBUG else "production"
        self.stdout.write(self.style.SUCCESS(f"System defaults are ready ({environment})."))

    @staticmethod
    def _ensure_user(username, password, role, *, is_staff, is_superuser):
        user, created = User.objects.get_or_create(username=username, defaults={"role": role})
        if (created or not user.has_usable_password()) and password:
            user.set_password(password)
        user.is_staff = is_staff
        user.is_superuser = is_superuser
        user.is_active = True
        user.role = role
        user.save()
        return user

    @staticmethod
    def _disable_legacy_weak_users():
        disabled = []
        for user in User.objects.filter(username__in=LEGACY_DEFAULT_USERNAMES):
            if not any(user.check_password(password) for password in LEGACY_WEAK_PASSWORDS):
                continue
            user.set_unusable_password()
            user.is_active = False
            user.save(update_fields=["password", "is_active"])
            disabled.append(user.username)
        return sorted(disabled)
