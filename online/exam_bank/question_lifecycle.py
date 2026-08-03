ARCHIVED_CODE_PREFIX = "ARCHIVED-"


def question_has_history(question):
    return question.exam_questions.exists() or question.attempt_answers.exists()


def archive_question(question):
    """Keep a question and its answers available to historical attempts."""
    max_length = question._meta.get_field("code").max_length
    prefix = f"{ARCHIVED_CODE_PREFIX}{question.pk}-"
    original = question.code
    question.code = prefix + original[: max_length - len(prefix)]
    question.status = question.STATUS_LOCKED
    question.is_locked_for_official_exam = True
    question.save(
        update_fields=["code", "status", "is_locked_for_official_exam", "updated_at"]
    )
    return question
