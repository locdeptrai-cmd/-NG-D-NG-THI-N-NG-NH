from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class Role(models.Model):
    code = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name


class User(AbstractUser):
    role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, blank=True, related_name="users")


# Nhóm đề thi / năng định / duyệt dùng chung trong toàn hệ thống.
SUBJECT_GROUPS = ("APS", "ADC", "SUP")


class Subject(models.Model):
    code = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name


class Category(models.Model):
    name = models.CharField(max_length=255)
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name="categories")

    def __str__(self):
        return f"{self.subject.code} - {self.name}"


class Document(models.Model):
    code = models.CharField(max_length=100, unique=True)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    url = models.URLField(blank=True)

    def __str__(self):
        return f"{self.code} - {self.title}"


class Question(models.Model):
    TYPE_SINGLE = "single"
    TYPE_MULTI = "multi"
    TYPE_TRUE_FALSE = "true_false"
    TYPE_SCENARIO = "scenario"
    TYPE_CHOICES = [
        (TYPE_SINGLE, "Trac nghiem 1 dap an"),
        (TYPE_MULTI, "Trac nghiem nhieu dap an"),
        (TYPE_TRUE_FALSE, "Dung/Sai"),
        (TYPE_SCENARIO, "Tinh huong"),
    ]

    STATUS_DRAFT = "draft"
    STATUS_REVIEW = "review"
    STATUS_APPROVED = "approved"
    STATUS_LOCKED = "locked"
    STATUS_CHOICES = [
        (STATUS_DRAFT, "Nhap"),
        (STATUS_REVIEW, "Cho duyet"),
        (STATUS_APPROVED, "Da duyet"),
        (STATUS_LOCKED, "Da khoa"),
    ]

    code = models.CharField(max_length=100, unique=True)
    content = models.TextField()
    explanation = models.TextField(blank=True)
    question_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default=TYPE_SINGLE)
    subject = models.ForeignKey(Subject, on_delete=models.PROTECT, related_name="questions")
    category = models.ForeignKey(Category, on_delete=models.PROTECT, related_name="questions")
    difficulty = models.CharField(max_length=20, blank=True)
    topic = models.CharField(max_length=255, blank=True)
    position_scope = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_DRAFT)
    is_locked_for_official_exam = models.BooleanField(default=False)
    reference_document = models.ForeignKey(Document, on_delete=models.SET_NULL, null=True, blank=True, related_name="questions")
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="created_questions")
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="updated_questions")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.code


class Answer(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name="answers")
    label = models.CharField(max_length=5)
    content = models.TextField()
    is_correct = models.BooleanField(default=False)
    order = models.PositiveSmallIntegerField(default=1)

    class Meta:
        unique_together = ("question", "label")
        ordering = ["order", "id"]

    def __str__(self):
        return f"{self.question.code} - {self.label}"


class QuestionVersion(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name="versions")
    version_number = models.PositiveIntegerField()
    snapshot_content = models.TextField()
    snapshot_explanation = models.TextField(blank=True)
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    changed_at = models.DateTimeField(auto_now_add=True)
    change_note = models.TextField(blank=True)

    class Meta:
        unique_together = ("question", "version_number")
        ordering = ["-version_number"]


class Exam(models.Model):
    name = models.CharField(max_length=255)
    subject = models.ForeignKey(Subject, on_delete=models.PROTECT, related_name="exams")
    duration_minutes = models.PositiveIntegerField(default=60)
    mix_questions = models.BooleanField(default=True)
    mix_answers = models.BooleanField(default=True)
    matrix_config = models.JSONField(default=dict, blank=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class ExamQuestion(models.Model):
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE, related_name="exam_questions")
    question = models.ForeignKey(Question, on_delete=models.PROTECT, related_name="exam_questions")
    order = models.PositiveIntegerField(default=1)

    class Meta:
        unique_together = ("exam", "question")
        ordering = ["order", "id"]


class Attempt(models.Model):
    STATUS_IN_PROGRESS = "in_progress"
    STATUS_SUBMITTED = "submitted"
    STATUS_CHOICES = [
        (STATUS_IN_PROGRESS, "Dang lam"),
        (STATUS_SUBMITTED, "Da nop"),
    ]

    exam = models.ForeignKey(Exam, on_delete=models.PROTECT, related_name="attempts")
    user = models.ForeignKey(User, on_delete=models.PROTECT, related_name="attempts")
    started_at = models.DateTimeField(default=timezone.now)
    submitted_at = models.DateTimeField(null=True, blank=True)
    score = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_IN_PROGRESS)


class AttemptAnswer(models.Model):
    attempt = models.ForeignKey(Attempt, on_delete=models.CASCADE, related_name="attempt_answers")
    question = models.ForeignKey(Question, on_delete=models.PROTECT, related_name="attempt_answers")
    selected_answers = models.ManyToManyField(Answer, blank=True, related_name="attempt_answers")
    is_correct = models.BooleanField(default=False)

    class Meta:
        unique_together = ("attempt", "question")


class AuditLog(models.Model):
    actor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    target_table = models.CharField(max_length=100)
    target_id = models.CharField(max_length=100)
    action = models.CharField(max_length=50)
    changes = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class TimestampedApprovalMixin(models.Model):
    approved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="+")
    approved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True
