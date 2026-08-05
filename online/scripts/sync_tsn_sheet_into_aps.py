"""Copy ADC Tan Son Nhat sheet questions into APS (and SUP if missing).

The new APS workbook has too few TSN items for 100-question papers (need 35).
The ADC file's LTCS Tan Son Nhat sheet is shared local knowledge used by APS/ADC/SUP.
"""

from __future__ import annotations

import os
import re
import sys
import unicodedata
from pathlib import Path

ONLINE_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ONLINE_ROOT))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.sqlite_settings")

import django

django.setup()

from django.db import transaction

from exam_bank.models import Answer, Category, Question, Subject
from exam_bank.question_selection import is_tsn_question


def _plain(value: str) -> str:
    text = str(value or "").replace("đ", "d").replace("Đ", "D")
    text = unicodedata.normalize("NFD", text)
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    return re.sub(r"\s+", " ", text).strip().upper()


def _ensure_in_subject(src: Question, subject_code: str, existing_keys: set[str]) -> bool:
    key = _plain(src.content)
    if key in existing_keys:
        return False
    subject = Subject.objects.get(code=subject_code)
    category, _ = Category.objects.get_or_create(
        subject=subject,
        name=src.category.name if src.category_id else "Khac",
    )
    question = Question.objects.create(
        code=f"{subject_code}-FROM-ADC-TSN-{src.id}",
        content=src.content,
        subject=subject,
        category=category,
        topic=src.topic,
        status=Question.STATUS_APPROVED,
        question_type=src.question_type,
    )
    for order, answer in enumerate(src.answers.all().order_by("order", "id"), start=1):
        Answer.objects.create(
            question=question,
            label=answer.label,
            content=answer.content,
            is_correct=answer.is_correct,
            order=order,
        )
    existing_keys.add(key)
    return True


def main() -> None:
    adc_tsn = list(
        Question.objects.filter(
            subject__code="ADC",
            status=Question.STATUS_APPROVED,
            topic__icontains="Tan Son",
        ).prefetch_related("answers")
    )
    with transaction.atomic():
        created = {"APS": 0, "SUP": 0}
        for code in ("APS", "SUP"):
            keys = {
                _plain(question.content)
                for question in Question.objects.filter(
                    subject__code=code,
                    status=Question.STATUS_APPROVED,
                    is_locked_for_official_exam=False,
                )
            }
            for src in adc_tsn:
                if _ensure_in_subject(src, code, keys):
                    created[code] += 1

    print(f"created={created}")
    for code in ("APS", "ADC", "SUP"):
        questions = list(
            Question.objects.filter(
                subject__code=code,
                status=Question.STATUS_APPROVED,
                is_locked_for_official_exam=False,
            )
        )
        tsn = sum(1 for question in questions if is_tsn_question(question))
        print(f"{code}: approved={len(questions)} tsn={tsn}")


if __name__ == "__main__":
    main()
