import random
import re
import unicodedata
from collections import Counter, defaultdict

from .models import Attempt, PracticeAttempt, Question


ALLOWED_MOCK_QUESTION_COUNTS = (10, 20, 50)
TSN_PERCENT = 35


class QuestionSelectionError(ValueError):
    pass


def _plain_text(value):
    text = unicodedata.normalize("NFD", str(value or ""))
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    return re.sub(r"\s+", " ", text).strip().upper()


def is_tsn_question(question):
    """Identify Tan Son Nhat questions from stable source codes and text."""
    haystack = _plain_text(
        " ".join(
            [
                question.code,
                question.content,
                question.topic,
                question.position_scope,
            ]
        )
    )
    return bool(
        re.search(r"(^|[^A-Z0-9])TSN([^A-Z0-9]|$)", haystack)
        or "TAN SON NHAT" in haystack
        or "TANSONNHAT" in haystack
    )


def tsn_target_count(total_questions):
    if total_questions not in ALLOWED_MOCK_QUESTION_COUNTS:
        allowed = ", ".join(str(value) for value in ALLOWED_MOCK_QUESTION_COUNTS)
        raise QuestionSelectionError(f"Số câu chỉ được chọn: {allowed}.")
    return int(total_questions * TSN_PERCENT / 100 + 0.5)


def _category_key(question):
    if question.category_id:
        return (question.category_id, question.category.name)
    return (0, question.topic or "Khac")


def _balanced_take(questions, count, rng):
    buckets = defaultdict(list)
    for question in questions:
        buckets[_category_key(question)].append(question)

    keys = list(buckets)
    rng.shuffle(keys)
    for bucket in buckets.values():
        rng.shuffle(bucket)

    selected = []
    while len(selected) < count:
        progressed = False
        for key in keys:
            bucket = buckets[key]
            if not bucket:
                continue
            selected.append(bucket.pop())
            progressed = True
            if len(selected) == count:
                break
        if not progressed:
            break
    return selected


def select_balanced_mock_questions(
    subject,
    total_questions,
    excluded_question_ids=None,
    rng=None,
):
    rng = rng or random.SystemRandom()
    excluded_question_ids = set(excluded_question_ids or [])
    tsn_count = tsn_target_count(total_questions)
    other_count = total_questions - tsn_count

    queryset = (
        Question.objects.filter(
            subject=subject,
            status=Question.STATUS_APPROVED,
            is_locked_for_official_exam=False,
        )
        .select_related("category")
        .prefetch_related("answers")
    )
    if excluded_question_ids:
        queryset = queryset.exclude(id__in=excluded_question_ids)

    tsn_pool = []
    other_pool = []
    for question in queryset:
        (tsn_pool if is_tsn_question(question) else other_pool).append(question)

    if len(tsn_pool) < tsn_count:
        raise QuestionSelectionError(
            f"Ngân hàng {subject.code} chỉ còn {len(tsn_pool)} câu TSN; "
            f"cần {tsn_count} câu để đạt tỷ lệ {TSN_PERCENT}%."
        )
    if len(other_pool) < other_count:
        raise QuestionSelectionError(
            f"Ngân hàng {subject.code} chỉ còn {len(other_pool)} câu ngoài TSN; "
            f"cần {other_count} câu để đạt tỷ lệ {100 - TSN_PERCENT}%."
        )

    selected_tsn = _balanced_take(tsn_pool, tsn_count, rng)
    selected_other = _balanced_take(other_pool, other_count, rng)
    selected = [*selected_tsn, *selected_other]
    rng.shuffle(selected)
    return selected, {
        "total_questions": total_questions,
        "tsn_percent": TSN_PERCENT,
        "tsn_question_count": len(selected_tsn),
        "other_question_count": len(selected_other),
        "tsn_categories": dict(Counter(q.category.name for q in selected_tsn)),
        "other_categories": dict(Counter(q.category.name for q in selected_other)),
        "excluded_previous_questions": len(excluded_question_ids),
    }


def latest_completed_question_ids(user, subject):
    candidates = []
    exam_attempt = (
        Attempt.objects.filter(
            user=user,
            exam__subject=subject,
            status=Attempt.STATUS_SUBMITTED,
        )
        .select_related("exam")
        .order_by("-submitted_at", "-id")
        .first()
    )
    if exam_attempt is not None:
        candidates.append(
            (
                exam_attempt.submitted_at or exam_attempt.started_at,
                set(
                    exam_attempt.exam.exam_questions.values_list(
                        "question_id", flat=True
                    )
                ),
            )
        )

    practice_attempt = (
        PracticeAttempt.objects.filter(user=user, subject=subject)
        .order_by("-completed_at", "-id")
        .first()
    )
    if practice_attempt is not None:
        question_ids = {
            int(item["question_id"])
            for item in practice_attempt.answers
            if str(item.get("question_id", "")).isdigit()
        }
        candidates.append((practice_attempt.completed_at, question_ids))

    return max(candidates, key=lambda item: item[0])[1] if candidates else set()
