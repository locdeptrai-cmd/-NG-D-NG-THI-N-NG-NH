from pathlib import Path
from random import shuffle
from time import sleep
from uuid import uuid4
from django.conf import settings
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Count, Q
from django.db import transaction
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone

from .importers import CATEGORY_RULES, EXCEL_DB_MAP, ImportError, import_questions_from_file, preview_import_classification
from .models import (
    SUBJECT_GROUPS,
    Answer,
    Attempt,
    AttemptAnswer,
    Exam,
    ExamQuestion,
    Question,
    Subject,
    User,
)
from .question_selection import (
    ALLOWED_MOCK_QUESTION_COUNTS,
    QuestionSelectionError,
    is_tsn_question,
    recent_completed_question_ids,
    select_balanced_mock_questions,
    uses_tsn_ratio,
)

DEFAULT_QUESTION_COUNT = 50


def ensure_subject_groups():
    for code in SUBJECT_GROUPS:
        Subject.objects.get_or_create(code=code, defaults={"name": code})


def home(request):
    if not request.user.is_authenticated:
        return redirect("login")
    if request.user.is_staff or request.user.is_superuser:
        return redirect("management_dashboard")
    return redirect("start_exam")


def login_view(request):
    if request.user.is_authenticated:
        return redirect("home")

    if request.method == "POST":
        username = request.POST.get("username", "").strip()
        password = request.POST.get("password", "")
        user = authenticate(request, username=username, password=password)
        if user is None:
            messages.error(request, "Sai tài khoản hoặc mật khẩu.")
        else:
            login(request, user)
            return redirect("home")
    return render(request, "login.html")


@login_required
def logout_view(request):
    logout(request)
    return redirect("login")


@login_required
def management_dashboard(request):
    if not (request.user.is_staff or request.user.is_superuser):
        return HttpResponseForbidden("Bạn không có quyền truy cập trang quản trị.")

    ensure_subject_groups()

    def dashboard_context(extra=None):
        by_subject = (
            Question.objects.values("subject__code")
            .annotate(total=Count("id"), approved=Count("id", filter=Q(status=Question.STATUS_APPROVED)))
            .order_by("subject__code")
        )
        context = {
            "subjects": Subject.objects.filter(code__in=SUBJECT_GROUPS).order_by("code"),
            "total_users": User.objects.count(),
            "total_questions": Question.objects.count(),
            "draft_questions": Question.objects.filter(status=Question.STATUS_DRAFT).count(),
            "review_questions": Question.objects.filter(status=Question.STATUS_REVIEW).count(),
            "approved_questions": Question.objects.filter(status=Question.STATUS_APPROVED).count(),
            "by_subject": by_subject,
            "excel_db_map": EXCEL_DB_MAP,
            "category_rules": CATEGORY_RULES,
        }
        if extra:
            context.update(extra)
        return context

    if request.method == "POST":
        action = request.POST.get("action", "import")
        group_code = request.POST.get("group_code", "").strip().upper()
        if group_code not in SUBJECT_GROUPS:
            messages.error(request, "Nhóm không hợp lệ.")
            return redirect("management_dashboard")

        if action == "approve_group":
            updated = (
                Question.objects.filter(subject__code=group_code, status__in=[Question.STATUS_DRAFT, Question.STATUS_REVIEW])
                .exclude(answers__isnull=True)
                .distinct()
                .update(status=Question.STATUS_APPROVED)
            )
            messages.success(request, f"Đã duyệt {updated} câu hỏi của nhóm {group_code}.")
            return redirect("management_dashboard")

        upload = request.FILES.get("question_file")
        if not upload:
            messages.error(request, "Bạn chưa chọn file import.")
            return redirect("management_dashboard")

        suffix = Path(upload.name).suffix.lower()
        if suffix not in {".csv", ".xlsx", ".xlsm"}:
            messages.error(request, "Chỉ hỗ trợ file CSV/XLSX/XLSM.")
            return redirect("management_dashboard")

        tmp_path = Path(settings.BASE_DIR) / f".tmp_import_{uuid4().hex}{suffix}"
        with tmp_path.open("wb") as out:
            for chunk in upload.chunks():
                out.write(chunk)

        try:
            if action == "preview_import":
                preview = preview_import_classification(tmp_path, group_code)
                messages.success(
                    request,
                    f"Đã phân tích {preview['record_count']} dòng hợp lệ, dự kiến import {preview['import_count']} câu.",
                )
                return render(request, "management_dashboard.html", dashboard_context({"import_preview": preview}))

            result = import_questions_from_file(tmp_path, group_code)
            by_subject = result.get("by_subject") or {}
            detail = ", ".join(f"{code}: {count}" for code, count in sorted(by_subject.items())) or "không có"
            if result.get("imported", 0) <= 0:
                messages.error(
                    request,
                    "Import không ghi được câu nào. Kiểm tra header QUESTION/ANS và A/B (hoặc 1/2) cùng cột rating (APS/ADC/ACC HAN/SUP/SUP ACS HAN/ACS SUP HCM).",
                )
            else:
                messages.success(
                    request,
                    f"Import thành công {result['imported']} câu "
                    f"(dòng hợp lệ: {result['record_count']}; theo nhóm: {detail}). "
                    f"Câu vào trạng thái draft — dùng Duyệt nhanh theo nhóm để mở thi.",
                )
        except ImportError as exc:
            messages.error(request, f"Import thất bại: {exc}")
        finally:
            if tmp_path.exists():
                for _ in range(3):
                    try:
                        tmp_path.unlink()
                        break
                    except PermissionError:
                        sleep(0.2)

        return redirect("management_dashboard")

    return render(request, "management_dashboard.html", dashboard_context())


@login_required
def start_exam(request):
    ensure_subject_groups()

    if request.user.is_staff or request.user.is_superuser:
        return redirect("management_dashboard")

    if request.method == "POST":
        group_code = request.POST.get("group_code", "").strip().upper()
        if group_code not in SUBJECT_GROUPS:
            messages.error(request, "Nhóm thi không hợp lệ.")
            return redirect("start_exam")

        subject = get_object_or_404(Subject, code=group_code)
        try:
            question_count = int(
                request.POST.get("question_count", DEFAULT_QUESTION_COUNT)
            )
        except (TypeError, ValueError):
            question_count = 0
        if question_count not in ALLOWED_MOCK_QUESTION_COUNTS:
            messages.error(request, "Số câu chỉ được chọn 20, 50 hoặc 100.")
            return redirect("start_exam")

        previous_ids = recent_completed_question_ids(request.user, subject)
        try:
            selected, distribution = select_balanced_mock_questions(
                subject,
                question_count,
                excluded_question_ids=previous_ids,
            )
        except QuestionSelectionError as exc:
            messages.error(request, str(exc))
            return redirect("start_exam")

        exam = Exam.objects.create(
            name=f"Đề thi {group_code} - {timezone.now().strftime('%Y-%m-%d %H:%M')}",
            subject=subject,
            duration_minutes=60,
            mix_questions=True,
            mix_answers=True,
            matrix_config={
                "group": group_code,
                "strategy": distribution.get(
                    "strategy", "tsn_35_balanced_categories_no_last_6"
                ),
                **distribution,
            },
            created_by=request.user,
        )

        shuffle(selected)
        for idx, q in enumerate(selected, start=1):
            ExamQuestion.objects.create(exam=exam, question=q, order=idx)

        attempt = Attempt.objects.create(exam=exam, user=request.user)
        return redirect("take_exam", attempt_id=attempt.id)

    subjects = list(
        Subject.objects.filter(code__in=SUBJECT_GROUPS).order_by("code")
    )
    for subject in subjects:
        questions = list(
            Question.objects.filter(
                subject=subject,
                status=Question.STATUS_APPROVED,
                is_locked_for_official_exam=False,
            ).select_related("category")
        )
        subject.uses_tsn_ratio = uses_tsn_ratio(subject)
        subject.mock_tsn_count = sum(is_tsn_question(q) for q in questions)
        subject.mock_other_count = len(questions) - subject.mock_tsn_count
        subject.mock_total_count = len(questions)
    return render(
        request,
        "start_exam.html",
        {
            "subjects": subjects,
            "question_counts": ALLOWED_MOCK_QUESTION_COUNTS,
            "default_question_count": DEFAULT_QUESTION_COUNT,
        },
    )


@login_required
def take_exam(request, attempt_id: int):
    attempt = get_object_or_404(Attempt.objects.select_related("exam", "user"), id=attempt_id)
    if attempt.user_id != request.user.id:
        return HttpResponseForbidden("Bạn không có quyền truy cập bài thi này.")
    if attempt.status == Attempt.STATUS_SUBMITTED:
        return redirect("exam_result", attempt_id=attempt.id)

    items = list(
        ExamQuestion.objects.filter(exam=attempt.exam)
        .select_related("question")
        .prefetch_related("question__answers")
        .order_by("order")
    )
    return render(request, "take_exam.html", {"attempt": attempt, "items": items})


@login_required
@transaction.atomic
def submit_exam(request, attempt_id: int):
    if request.method != "POST":
        return redirect("take_exam", attempt_id=attempt_id)

    attempt = get_object_or_404(Attempt.objects.select_related("exam", "user"), id=attempt_id)
    if attempt.user_id != request.user.id:
        return HttpResponseForbidden("Bạn không có quyền nộp bài này.")
    if attempt.status == Attempt.STATUS_SUBMITTED:
        return redirect("exam_result", attempt_id=attempt.id)

    exam_questions = list(
        ExamQuestion.objects.filter(exam=attempt.exam)
        .select_related("question")
        .prefetch_related("question__answers")
        .order_by("order")
    )

    correct_count = 0
    for eq in exam_questions:
        question = eq.question
        selected_ids = {int(v) for v in request.POST.getlist(f"q_{question.id}") if v.isdigit()}
        correct_ids = set(question.answers.filter(is_correct=True).values_list("id", flat=True))
        is_correct = selected_ids == correct_ids
        if is_correct:
            correct_count += 1

        aa, _ = AttemptAnswer.objects.get_or_create(attempt=attempt, question=question)
        aa.is_correct = is_correct
        aa.save()
        aa.selected_answers.set(Answer.objects.filter(id__in=selected_ids, question=question))

    total = len(exam_questions)
    attempt.score = round((correct_count / total) * 10, 2) if total else 0
    attempt.status = Attempt.STATUS_SUBMITTED
    attempt.submitted_at = timezone.now()
    attempt.save(update_fields=["score", "status", "submitted_at"])

    return redirect("exam_result", attempt_id=attempt.id)


@login_required
def exam_result(request, attempt_id: int):
    attempt = get_object_or_404(Attempt.objects.select_related("exam", "user"), id=attempt_id)
    if attempt.user_id != request.user.id:
        return HttpResponseForbidden("Bạn không có quyền xem kết quả này.")
    if attempt.status != Attempt.STATUS_SUBMITTED:
        messages.error(request, "Bạn cần nộp bài trước khi xem kết quả.")
        return redirect("take_exam", attempt_id=attempt.id)

    answers = (
        AttemptAnswer.objects.filter(attempt=attempt)
        .select_related("question")
        .prefetch_related("selected_answers", "question__answers")
    )
    answer_map = {x.question_id: x for x in answers}

    items = list(
        ExamQuestion.objects.filter(exam=attempt.exam)
        .select_related("question")
        .prefetch_related("question__answers")
        .order_by("order")
    )

    detailed = []
    for eq in items:
        question = eq.question
        row = answer_map.get(question.id)
        selected_ids = set(row.selected_answers.values_list("id", flat=True)) if row else set()
        detailed.append(
            {
                "order": eq.order,
                "question": question,
                "selected_ids": selected_ids,
                "is_correct": bool(row and row.is_correct),
            }
        )

    correct = sum(1 for d in detailed if d["is_correct"])
    total = len(detailed)
    return render(
        request,
        "exam_result.html",
        {
            "attempt": attempt,
            "detailed": detailed,
            "correct": correct,
            "total": total,
        },
    )
