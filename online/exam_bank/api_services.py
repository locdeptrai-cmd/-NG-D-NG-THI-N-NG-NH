import hashlib
import json
from datetime import datetime, timezone as dt_timezone

from django.db import transaction
from django.utils import timezone

from .models import (
    Answer,
    PracticeAttempt,
    Question,
    QuestionPackage,
    Subject,
    SyncOperation,
)
from .serializers import PracticeAttemptInputSerializer


def subject_package_slug(code: str) -> str:
    """Stable package id fragment (spaces/slashes -> underscore)."""
    return code.replace(" ", "_").replace("/", "_")


def desired_package_id(subject_code, year=None):
    year = year or timezone.localdate().year
    return f"{subject_package_slug(subject_code)}-{year}-PRACTICE"


def resolve_question_package(package_id: str):
    """Lookup by current or legacy spaced package id."""
    ensure_question_packages()
    qs = QuestionPackage.objects.select_related("subject")
    package = qs.filter(package_id=package_id).first()
    if package is not None:
        return package
    # Legacy ids used subject codes with spaces, e.g. "ACC HAN-2026-PRACTICE".
    slug_id = package_id.replace(" ", "_")
    if slug_id != package_id:
        return qs.filter(package_id=slug_id).first()
    spaced_id = package_id.replace("_", " ", 1) if "_" in package_id else None
    if spaced_id:
        return qs.filter(package_id=spaced_id).first()
    return None


def ensure_question_packages():
    year = timezone.localdate().year
    packages = []
    for subject in Subject.objects.order_by("code"):
        desired_id = desired_package_id(subject.code, year)
        package = QuestionPackage.objects.filter(subject=subject).first()
        if package is None:
            package = QuestionPackage.objects.create(
                subject=subject,
                package_id=desired_id,
                name=f"Ngân hàng luyện tập {subject.code}",
            )
        else:
            update_fields = []
            if package.package_id != desired_id and not QuestionPackage.objects.filter(
                package_id=desired_id
            ).exclude(pk=package.pk).exists():
                package.package_id = desired_id
                update_fields.append("package_id")
            expected_name = f"Ngân hàng luyện tập {subject.code}"
            if package.name != expected_name:
                package.name = expected_name
                update_fields.append("name")
            if update_fields:
                package.save(update_fields=[*update_fields, "updated_at"])
        packages.append(package)
    return packages


def practice_questions(subject):
    return (
        Question.objects.filter(
            subject=subject,
            status=Question.STATUS_APPROVED,
            is_locked_for_official_exam=False,
        )
        .select_related("subject", "category", "reference_document")
        .prefetch_related("answers")
        .order_by("id")
    )


def serialize_question(question, include_solutions=True):
    answers = []
    correct = []
    for answer in question.answers.all():
        answers.append(
            {
                "id": answer.id,
                "label": answer.label,
                "content": answer.content,
            }
        )
        if answer.is_correct:
            correct.append(answer.label)

    payload = {
        "id": question.id,
        "code": question.code,
        "content": question.content,
        "question_type": question.question_type,
        "category_id": question.category_id,
        "category": question.category.name,
        "difficulty": question.difficulty,
        "topic": question.topic,
        "answers": answers,
    }
    if include_solutions:
        payload.update(
            {
                "correct_answer": correct,
                "explanation": question.explanation,
                "reference": (
                    question.reference_document.title
                    if question.reference_document_id
                    else ""
                ),
            }
        )
    return payload


def _canonical_package_content(package):
    return {
        "package_id": package.package_id,
        "subject": {
            "id": package.subject_id,
            "code": package.subject.code,
            "name": package.subject.name,
        },
        "questions": [
            serialize_question(question)
            for question in practice_questions(package.subject)
        ],
    }


def refresh_package(package):
    content = _canonical_package_content(package)
    encoded = json.dumps(
        content,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    checksum = f"sha256:{hashlib.sha256(encoded).hexdigest()}"
    if checksum != package.checksum:
        package.version = package.version + 1 if package.checksum else package.version
        package.checksum = checksum
        package.save(update_fields=["version", "checksum", "updated_at"])
    return content, len(encoded)


def package_metadata(package, refresh=True):
    question_count = practice_questions(package.subject).count()
    size_bytes = 0
    if refresh:
        _, size_bytes = refresh_package(package)
    return {
        "package_id": package.package_id,
        "name": package.name,
        "version": package.version,
        "checksum": package.checksum,
        "minimum_app_version": package.minimum_app_version,
        "updated_at": package.updated_at,
        "size_bytes": size_bytes,
        "question_count": question_count,
        "subject": {
            "id": package.subject_id,
            "code": package.subject.code,
            "name": package.subject.name,
        },
    }


def package_download(package):
    content, size_bytes = refresh_package(package)
    return {
        **package_metadata(package, refresh=False),
        "size_bytes": size_bytes,
        "questions": content["questions"],
    }


def create_practice_attempt(user, raw_payload):
    serializer = PracticeAttemptInputSerializer(data=raw_payload)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data
    subject = Subject.objects.get(pk=data.pop("subject_id"))
    attempt, created = PracticeAttempt.objects.get_or_create(
        user=user,
        local_attempt_id=data.pop("local_attempt_id"),
        defaults={"subject": subject, **data},
    )
    return attempt, created


@transaction.atomic
def process_sync_operations(user, client_id, operations):
    results = []
    for operation in operations:
        operation_id = str(operation.get("operation_id", "")).strip()
        operation_type = str(operation.get("type", "")).strip()
        payload = operation.get("payload") or {}
        if not operation_id or not operation_type:
            results.append(
                {
                    "operation_id": operation_id,
                    "status": "failed",
                    "error": "operation_id và type là bắt buộc.",
                }
            )
            continue

        existing = SyncOperation.objects.filter(
            user=user,
            client_id=client_id,
            operation_id=operation_id,
        ).first()
        if existing:
            results.append(
                {
                    "operation_id": operation_id,
                    "status": existing.status,
                    "server_id": existing.server_reference or None,
                    "duplicate": True,
                }
            )
            continue

        try:
            if operation_type != "submit_practice_attempt":
                raise ValueError(f"Loại tác vụ không được hỗ trợ: {operation_type}")
            attempt, _ = create_practice_attempt(
                user,
                {**payload, "client_id": client_id},
            )
            sync_operation = SyncOperation.objects.create(
                user=user,
                client_id=client_id,
                operation_id=operation_id,
                operation_type=operation_type,
                status=SyncOperation.STATUS_COMPLETED,
                payload=payload,
                server_reference=str(attempt.id),
            )
            results.append(
                {
                    "operation_id": operation_id,
                    "status": sync_operation.status,
                    "server_id": sync_operation.server_reference,
                    "duplicate": False,
                }
            )
        except Exception as exc:
            sync_operation = SyncOperation.objects.create(
                user=user,
                client_id=client_id,
                operation_id=operation_id,
                operation_type=operation_type,
                status=SyncOperation.STATUS_FAILED,
                payload=payload,
                last_error=str(exc),
            )
            results.append(
                {
                    "operation_id": operation_id,
                    "status": sync_operation.status,
                    "error": sync_operation.last_error,
                }
            )
    return results


def parse_since(value):
    if not value:
        return datetime(1970, 1, 1, tzinfo=dt_timezone.utc)
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if timezone.is_naive(parsed):
        parsed = timezone.make_aware(parsed, dt_timezone.utc)
    return parsed
