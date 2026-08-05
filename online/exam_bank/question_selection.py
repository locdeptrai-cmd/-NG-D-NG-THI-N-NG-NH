import random
import re
import unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone as dt_timezone

from django.utils import timezone

from .models import Attempt, PracticeAttempt, Question


ALLOWED_MOCK_QUESTION_COUNTS = (20, 50, 100)
# Prefer 35% TSN; if the remaining bank is too small, step down to 25% then 15%.
TSN_PERCENT_FALLBACKS = (35, 25, 15)
TSN_PERCENT = TSN_PERCENT_FALLBACKS[0]
# These rating banks skip the TSN/LTCS split and only balance by knowledge category.
CATEGORY_ONLY_SUBJECTS = frozenset(
    {"ACC HAN", "ACS SUP HCM", "SUP ACS HAN"}
)
# Skip questions that appeared in any of the user's last N completed
# practice/mock exams for the same subject.
RECENT_EXAM_EXCLUSION_LIMIT = 6


def uses_tsn_ratio(subject) -> bool:
    code = getattr(subject, "code", subject)
    return str(code or "").strip().upper() not in {
        item.upper() for item in CATEGORY_ONLY_SUBJECTS
    }


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


def tsn_target_count(total_questions, percent=None):
    if total_questions not in ALLOWED_MOCK_QUESTION_COUNTS:
        allowed = ", ".join(str(value) for value in ALLOWED_MOCK_QUESTION_COUNTS)
        raise QuestionSelectionError(f"Số câu chỉ được chọn: {allowed}.")
    ratio = TSN_PERCENT if percent is None else percent
    if ratio not in TSN_PERCENT_FALLBACKS:
        raise QuestionSelectionError(
            f"Tỷ lệ TSN không hợp lệ: {ratio}. Cho phép: "
            + ", ".join(str(value) for value in TSN_PERCENT_FALLBACKS)
        )
    return int(total_questions * ratio / 100 + 0.5)


def resolve_tsn_percent(tsn_available, other_available, total_questions):
    """Pick the highest feasible TSN percent from the fallback ladder."""
    for percent in TSN_PERCENT_FALLBACKS:
        tsn_need = tsn_target_count(total_questions, percent)
        other_need = total_questions - tsn_need
        if tsn_available >= tsn_need and other_available >= other_need:
            return percent, tsn_need, other_need
    tried = ", ".join(f"{value}%" for value in TSN_PERCENT_FALLBACKS)
    raise QuestionSelectionError(
        f"Ngân hàng chỉ còn {tsn_available} câu TSN và {other_available} câu ngoài TSN; "
        f"không đủ để tạo đề {total_questions} câu ở các tỷ lệ {tried}."
    )


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
    seen_ids = set()
    while len(selected) < count:
        progressed = False
        for key in keys:
            bucket = buckets[key]
            if not bucket:
                continue
            question = bucket.pop()
            if question.id in seen_ids:
                continue
            seen_ids.add(question.id)
            selected.append(question)
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
    apply_tsn = uses_tsn_ratio(subject)

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

    pool = []
    seen_ids = set()
    for question in queryset:
        if question.id in seen_ids:
            continue
        seen_ids.add(question.id)
        pool.append(question)

    if apply_tsn:
        tsn_pool = [question for question in pool if is_tsn_question(question)]
        other_pool = [
            question for question in pool if not is_tsn_question(question)
        ]
        percent, tsn_count, other_count = resolve_tsn_percent(
            len(tsn_pool), len(other_pool), total_questions
        )
        selected_tsn = _balanced_take(tsn_pool, tsn_count, rng)
        selected_other = _balanced_take(other_pool, other_count, rng)
        selected = [*selected_tsn, *selected_other]
        distribution = {
            "total_questions": total_questions,
            "strategy": f"tsn_{percent}_balanced_categories",
            "tsn_percent": percent,
            "tsn_question_count": len(selected_tsn),
            "other_question_count": len(selected_other),
            "tsn_categories": dict(
                Counter(q.category.name for q in selected_tsn)
            ),
            "other_categories": dict(
                Counter(q.category.name for q in selected_other)
            ),
            "categories": dict(Counter(q.category.name for q in selected)),
            "excluded_previous_questions": len(excluded_question_ids),
            "recent_exams_excluded": RECENT_EXAM_EXCLUSION_LIMIT,
        }
    else:
        if len(pool) < total_questions:
            raise QuestionSelectionError(
                f"Ngân hàng {subject.code} chỉ còn {len(pool)} câu; "
                f"cần {total_questions} câu."
            )
        selected = _balanced_take(pool, total_questions, rng)
        selected_tsn = [question for question in selected if is_tsn_question(question)]
        distribution = {
            "total_questions": total_questions,
            "strategy": "equal_categories_no_tsn_ratio",
            "tsn_percent": 0,
            "tsn_question_count": len(selected_tsn),
            "other_question_count": len(selected) - len(selected_tsn),
            "tsn_categories": {},
            "other_categories": {},
            "categories": dict(Counter(q.category.name for q in selected)),
            "excluded_previous_questions": len(excluded_question_ids),
            "recent_exams_excluded": RECENT_EXAM_EXCLUSION_LIMIT,
        }

    # Guard: never allow duplicate question ids inside one exam.
    unique_selected = []
    unique_ids = set()
    for question in selected:
        if question.id in unique_ids:
            continue
        unique_ids.add(question.id)
        unique_selected.append(question)
    if len(unique_selected) != total_questions:
        raise QuestionSelectionError(
            f"Không tạo được đề {total_questions} câu không trùng "
            f"(chỉ chọn được {len(unique_selected)} câu)."
        )
    rng.shuffle(unique_selected)
    return unique_selected, distribution


def _session_sort_key(item):
    completed_at, tie_breaker, _question_ids = item
    if completed_at is None:
        completed_at = datetime.min.replace(tzinfo=dt_timezone.utc)
    elif timezone.is_naive(completed_at):
        completed_at = timezone.make_aware(
            completed_at, timezone.get_current_timezone()
        )
    return (completed_at, tie_breaker)


def recent_completed_question_ids(
    user,
    subject,
    limit=RECENT_EXAM_EXCLUSION_LIMIT,
):
    """Union of question ids from the user's last N completed exams/practices."""
    sessions = []

    exam_attempts = (
        Attempt.objects.filter(
            user=user,
            exam__subject=subject,
            status=Attempt.STATUS_SUBMITTED,
        )
        .select_related("exam")
        .prefetch_related("exam__exam_questions")
        .order_by("-submitted_at", "-id")[:limit]
    )
    for attempt in exam_attempts:
        sessions.append(
            (
                attempt.submitted_at or attempt.started_at,
                attempt.id,
                set(
                    attempt.exam.exam_questions.values_list("question_id", flat=True)
                ),
            )
        )

    practice_attempts = PracticeAttempt.objects.filter(
        user=user,
        subject=subject,
        completed_at__isnull=False,
    ).order_by("-completed_at", "-id")[:limit]
    for practice in practice_attempts:
        question_ids = {
            int(item["question_id"])
            for item in (practice.answers or [])
            if str(item.get("question_id", "")).isdigit()
        }
        sessions.append((practice.completed_at, practice.id, question_ids))

    sessions.sort(key=_session_sort_key, reverse=True)
    excluded = set()
    for _completed_at, _tie_breaker, question_ids in sessions[:limit]:
        excluded.update(question_ids)
    return excluded


def latest_completed_question_ids(user, subject):
    """Backward-compatible alias for the most recent completed exam only."""
    return recent_completed_question_ids(user, subject, limit=1)
