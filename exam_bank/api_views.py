from uuid import uuid4

from django.db import transaction
from django.db.models import Count, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .api_services import (
    create_practice_attempt,
    ensure_question_packages,
    package_download,
    package_metadata,
    parse_since,
    process_sync_operations,
    resolve_question_package,
    serialize_question,
)
from .models import (
    Answer,
    Attempt,
    AttemptAnswer,
    Category,
    Exam,
    PracticeAttempt,
    QuestionPackage,
    Subject,
)
from .serializers import (
    CategorySerializer,
    PracticeAttemptSerializer,
    SubjectSerializer,
    UserSerializer,
)
from .question_selection import (
    ALLOWED_MOCK_QUESTION_COUNTS,
    QuestionSelectionError,
    latest_completed_question_ids,
    select_balanced_mock_questions,
)


class HealthAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(
            {
                "status": "ok",
                "server_time": timezone.now(),
                "api_version": "1",
            }
        )


class MeAPIView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user).data)


class SubjectListAPIView(generics.ListAPIView):
    serializer_class = SubjectSerializer

    def get_queryset(self):
        return Subject.objects.annotate(
            question_count=Count(
                "questions",
                filter=Q(
                    questions__status="approved",
                    questions__is_locked_for_official_exam=False,
                ),
            )
        ).order_by("code")


class CategoryListAPIView(generics.ListAPIView):
    serializer_class = CategorySerializer

    def get_queryset(self):
        queryset = Category.objects.select_related("subject").order_by(
            "subject__code",
            "name",
        )
        subject_id = self.request.query_params.get("subject")
        return queryset.filter(subject_id=subject_id) if subject_id else queryset


class QuestionPackageListAPIView(APIView):
    def get(self, request):
        packages = ensure_question_packages()
        return Response(
            [package_metadata(package) for package in packages]
        )


class QuestionPackageDetailAPIView(APIView):
    def get(self, request, package_id):
        package = resolve_question_package(package_id)
        if package is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(package_metadata(package))


class QuestionPackageDownloadAPIView(APIView):
    def get(self, request, package_id):
        package = resolve_question_package(package_id)
        if package is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(package_download(package))


class PracticeStartAPIView(APIView):
    def post(self, request):
        subject = get_object_or_404(Subject, pk=request.data.get("subject_id"))
        try:
            count = int(request.data.get("question_count", 20))
        except (TypeError, ValueError):
            raise ValidationError({"question_count": "Số câu hỏi không hợp lệ."})
        if count not in ALLOWED_MOCK_QUESTION_COUNTS:
            raise ValidationError(
                {"question_count": "Số câu chỉ được chọn 10, 20 hoặc 50."}
            )
        previous_ids = latest_completed_question_ids(request.user, subject)
        try:
            questions, distribution = select_balanced_mock_questions(
                subject,
                count,
                excluded_question_ids=previous_ids,
            )
        except QuestionSelectionError as exc:
            raise ValidationError({"question_count": str(exc)}) from exc
        return Response(
            {
                "local_session_id": f"local-{uuid4()}",
                "subject": {
                    "id": subject.id,
                    "code": subject.code,
                    "name": subject.name,
                },
                "started_at": timezone.now(),
                "distribution": distribution,
                "questions": [
                    serialize_question(question) for question in questions
                ],
            }
        )


class PracticeSubmitAPIView(APIView):
    def post(self, request):
        try:
            attempt, created = create_practice_attempt(request.user, request.data)
        except Subject.DoesNotExist:
            raise ValidationError({"subject_id": "Môn học không tồn tại."})
        return Response(
            {
                **PracticeAttemptSerializer(attempt).data,
                "duplicate": not created,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class ExamStartAPIView(APIView):
    def post(self, request):
        exam = get_object_or_404(
            Exam.objects.select_related("subject").prefetch_related(
                "exam_questions__question__answers"
            ),
            pk=request.data.get("exam_id"),
        )
        attempt = Attempt.objects.create(exam=exam, user=request.user)
        questions = [
            serialize_question(exam_question.question, include_solutions=False)
            for exam_question in exam.exam_questions.all()
        ]
        return Response(
            {
                "attempt_id": attempt.id,
                "exam": {
                    "id": exam.id,
                    "name": exam.name,
                    "duration_minutes": exam.duration_minutes,
                    "subject": exam.subject.code,
                },
                "started_at": attempt.started_at,
                "questions": questions,
            },
            status=status.HTTP_201_CREATED,
        )


def _attempt_payload(attempt):
    answers = {
        item.question_id: list(
            item.selected_answers.values_list("id", flat=True)
        )
        for item in attempt.attempt_answers.prefetch_related(
            "selected_answers"
        )
    }
    return {
        "attempt_id": attempt.id,
        "exam_id": attempt.exam_id,
        "exam_name": attempt.exam.name,
        "status": attempt.status,
        "started_at": attempt.started_at,
        "submitted_at": attempt.submitted_at,
        "score": attempt.score,
        "answers": answers,
        "questions": [
            serialize_question(item.question, include_solutions=False)
            for item in attempt.exam.exam_questions.all()
        ],
    }


class ExamAttemptAPIView(APIView):
    def get(self, request, attempt_id):
        attempt = get_object_or_404(
            Attempt.objects.select_related("exam").prefetch_related(
                "exam__exam_questions__question__answers",
                "attempt_answers__selected_answers",
            ),
            pk=attempt_id,
            user=request.user,
        )
        return Response(_attempt_payload(attempt))


class ExamAutosaveAPIView(APIView):
    @transaction.atomic
    def post(self, request, attempt_id):
        attempt = get_object_or_404(
            Attempt,
            pk=attempt_id,
            user=request.user,
            status=Attempt.STATUS_IN_PROGRESS,
        )
        saved = 0
        for item in request.data.get("answers", []):
            question_id = item.get("question_id")
            if not attempt.exam.exam_questions.filter(
                question_id=question_id
            ).exists():
                continue
            selected = Answer.objects.filter(
                question_id=question_id,
                id__in=item.get("answer_ids", []),
            )
            attempt_answer, _ = AttemptAnswer.objects.get_or_create(
                attempt=attempt,
                question_id=question_id,
            )
            attempt_answer.selected_answers.set(selected)
            saved += 1
        return Response({"status": "saved", "saved_answers": saved})


class ExamSubmitAPIView(APIView):
    @transaction.atomic
    def post(self, request, attempt_id):
        attempt = get_object_or_404(
            Attempt.objects.select_related("exam"),
            pk=attempt_id,
            user=request.user,
        )
        if attempt.status == Attempt.STATUS_SUBMITTED:
            return Response(
                {
                    "attempt_id": attempt.id,
                    "status": attempt.status,
                    "score": attempt.score,
                    "duplicate": True,
                }
            )

        total = attempt.exam.exam_questions.count()
        correct = 0
        for item in attempt.attempt_answers.prefetch_related(
            "selected_answers",
            "question__answers",
        ):
            selected_ids = set(
                item.selected_answers.values_list("id", flat=True)
            )
            correct_ids = set(
                item.question.answers.filter(is_correct=True).values_list(
                    "id",
                    flat=True,
                )
            )
            item.is_correct = bool(correct_ids) and selected_ids == correct_ids
            item.save(update_fields=["is_correct"])
            correct += int(item.is_correct)

        attempt.score = round((correct / total) * 100, 2) if total else 0
        attempt.status = Attempt.STATUS_SUBMITTED
        attempt.submitted_at = timezone.now()
        attempt.save(
            update_fields=["score", "status", "submitted_at"]
        )
        return Response(
            {
                "attempt_id": attempt.id,
                "status": attempt.status,
                "score": attempt.score,
                "correct_answers": correct,
                "total_questions": total,
                "duplicate": False,
            }
        )


class ResultListAPIView(generics.ListAPIView):
    serializer_class = PracticeAttemptSerializer

    def get_queryset(self):
        return PracticeAttempt.objects.filter(
            user=self.request.user
        ).select_related("subject")


class ResultDetailAPIView(generics.RetrieveAPIView):
    serializer_class = PracticeAttemptSerializer

    def get_queryset(self):
        return PracticeAttempt.objects.filter(
            user=self.request.user
        ).select_related("subject")


class SyncAPIView(APIView):
    def post(self, request):
        client_id = str(request.data.get("client_id", "")).strip()
        operations = request.data.get("operations")
        if not client_id:
            raise ValidationError({"client_id": "client_id là bắt buộc."})
        if not isinstance(operations, list):
            raise ValidationError({"operations": "operations phải là danh sách."})
        return Response(
            {"results": process_sync_operations(request.user, client_id, operations)}
        )


class SyncChangesAPIView(APIView):
    def get(self, request):
        try:
            since = parse_since(request.query_params.get("since"))
        except ValueError:
            raise ValidationError({"since": "Mốc thời gian ISO-8601 không hợp lệ."})
        packages = ensure_question_packages()
        metadata = [package_metadata(package) for package in packages]
        return Response(
            {
                "server_time": timezone.now(),
                "packages": [
                    item for item in metadata if item["updated_at"] > since
                ],
            }
        )
