from django.contrib import admin
from .models import (
    Answer,
    Attempt,
    AttemptAnswer,
    AuditLog,
    Category,
    Document,
    Exam,
    ExamQuestion,
    Question,
    QuestionVersion,
    Role,
    Subject,
    User,
)


class AnswerInline(admin.TabularInline):
    model = Answer
    extra = 1


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ("code", "subject", "category", "difficulty", "status", "is_locked_for_official_exam", "updated_at")
    list_filter = ("subject", "category", "difficulty", "status", "is_locked_for_official_exam")
    search_fields = ("code", "content", "topic")
    inlines = [AnswerInline]


@admin.register(QuestionVersion)
class QuestionVersionAdmin(admin.ModelAdmin):
    list_display = ("question", "version_number", "changed_by", "changed_at")
    list_filter = ("changed_at",)


admin.site.register(Role)
admin.site.register(User)
admin.site.register(Subject)
admin.site.register(Category)
admin.site.register(Document)
admin.site.register(Exam)
admin.site.register(ExamQuestion)
admin.site.register(Attempt)
admin.site.register(AttemptAnswer)
admin.site.register(AuditLog)
