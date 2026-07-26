from django.contrib.auth.models import Group, Permission
from django.core.management.base import BaseCommand

from exam_bank.models import SUBJECT_GROUPS, Role, Subject, User


DEFAULT_PASSWORD = "123456"


class Command(BaseCommand):
    help = "Create local default roles, subjects, groups, permissions, and users"

    def handle(self, *args, **options):
        role_user, _ = Role.objects.get_or_create(
            code="enduser",
            defaults={"name": "End User", "description": "Hoc vien thi thu"},
        )
        role_teacher, _ = Role.objects.get_or_create(
            code="endteacher",
            defaults={"name": "End Teacher", "description": "Giao vien quan tri ngan hang cau hoi"},
        )

        for code in SUBJECT_GROUPS:
            Subject.objects.get_or_create(code=code, defaults={"name": code})

        teacher_group, _ = Group.objects.get_or_create(name="question_teachers")
        teacher_perms = Permission.objects.filter(
            content_type__app_label="exam_bank",
            content_type__model__in=["question", "answer", "category", "subject", "document"],
        )
        teacher_group.permissions.set(teacher_perms)

        admin, created = User.objects.get_or_create(username="admin", defaults={"role": role_teacher})
        if created or not admin.has_usable_password():
            admin.set_password(DEFAULT_PASSWORD)
        admin.is_staff = True
        admin.is_superuser = True
        admin.is_active = True
        admin.role = role_teacher
        admin.save()

        teacher, created = User.objects.get_or_create(username="endteacher", defaults={"role": role_teacher})
        if created or not teacher.has_usable_password():
            teacher.set_password(DEFAULT_PASSWORD)
        teacher.is_staff = True
        teacher.is_superuser = False
        teacher.is_active = True
        teacher.role = role_teacher
        teacher.save()
        teacher.groups.add(teacher_group)

        student, created = User.objects.get_or_create(username="enduser", defaults={"role": role_user})
        if created or not student.has_usable_password():
            student.set_password(DEFAULT_PASSWORD)
        student.is_staff = False
        student.is_superuser = False
        student.is_active = True
        student.role = role_user
        student.save()

        self.stdout.write(self.style.SUCCESS("Local defaults are ready."))
        self.stdout.write("Accounts: admin / endteacher / enduser")
        self.stdout.write(f"Default password: {DEFAULT_PASSWORD}")
