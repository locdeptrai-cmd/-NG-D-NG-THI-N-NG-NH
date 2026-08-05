from exam_bank.models import Question

ARCHIVED_CODE_PREFIX = "ARCHIVED-"


def question_has_history(question):
    return question.exam_questions.exists() or question.attempt_answers.exists()


def archive_question(question):
    """Keep a question and its answers available to historical attempts."""
    max_length = question._meta.get_field("code").max_length
    original = question.code or ""
    if original.startswith(ARCHIVED_CODE_PREFIX):
        question.status = question.STATUS_LOCKED
        question.is_locked_for_official_exam = True
        question.save(
            update_fields=["status", "is_locked_for_official_exam", "updated_at"]
        )
        return question

    base = f"{ARCHIVED_CODE_PREFIX}{question.pk}-"
    suffix = 0
    while True:
        extra = "" if suffix == 0 else f"-{suffix}"
        room = max_length - len(base) - len(extra)
        candidate = f"{base}{original[:room]}{extra}"
        conflict = (
            Question.objects.filter(code=candidate)
            .exclude(pk=question.pk)
            .exists()
        )
        if not conflict:
            break
        suffix += 1

    question.code = candidate
    question.status = question.STATUS_LOCKED
    question.is_locked_for_official_exam = True
    question.save(
        update_fields=["code", "status", "is_locked_for_official_exam", "updated_at"]
    )
    return question
