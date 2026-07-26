from random import shuffle

from django.db.models import Q

from .models import Exam, ExamQuestion, Question


def generate_exam_questions(exam: Exam):
    """
    matrix_config example:
    {
      "rows": [
        {"category": "Quy dinh", "percent": 30},
        {"category": "Nghiep vu", "percent": 30}
      ],
      "total_questions": 50
    }
    """
    cfg = exam.matrix_config or {}
    rows = cfg.get("rows", [])
    total = int(cfg.get("total_questions", 0))
    if total <= 0:
        return []

    selected = []
    for row in rows:
        name = row.get("category")
        percent = float(row.get("percent", 0))
        count = round(total * percent / 100)
        pool = list(
            Question.objects.filter(
                subject=exam.subject,
                status=Question.STATUS_APPROVED,
                is_locked_for_official_exam=False,
                category__name=name,
            )
        )
        shuffle(pool)
        selected.extend(pool[:count])

    if len(selected) < total:
        more = list(
            Question.objects.filter(
                subject=exam.subject,
                status=Question.STATUS_APPROVED,
                is_locked_for_official_exam=False,
            ).exclude(id__in=[q.id for q in selected])
        )
        shuffle(more)
        selected.extend(more[: total - len(selected)])

    if exam.mix_questions:
        shuffle(selected)

    ExamQuestion.objects.filter(exam=exam).delete()
    created = []
    for idx, q in enumerate(selected, start=1):
        created.append(ExamQuestion.objects.create(exam=exam, question=q, order=idx))
    return created
