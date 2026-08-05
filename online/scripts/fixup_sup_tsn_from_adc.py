"""Ensure SUP keeps TSN-marked copies of ADC Tan Son Nhat questions."""

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
from exam_bank.question_lifecycle import archive_question, question_has_history
from exam_bank.question_selection import is_tsn_question


def _plain(value: str) -> str:
    text = str(value or "").replace("đ", "d").replace("Đ", "D")
    text = unicodedata.normalize("NFD", text)
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    return re.sub(r"\s+", " ", text).strip().upper()


def _retire(question: Question) -> None:
    if question_has_history(question):
        archive_question(question)
    else:
        question.delete()


def main() -> None:
    with transaction.atomic():
        by_key: dict[str, list[Question]] = {}
        for question in Question.objects.filter(subject__code="SUP").exclude(
            status=Question.STATUS_LOCKED
        ):
            by_key.setdefault(_plain(question.content), []).append(question)

        adc_tsn_by_key = {
            _plain(question.content): question
            for question in Question.objects.filter(
                subject__code="ADC",
                status=Question.STATUS_APPROVED,
                topic__icontains="Tan Son",
            ).prefetch_related("answers")
        }

        retired = 0
        upgraded = 0
        for key, group in by_key.items():
            group.sort(key=lambda item: (0 if is_tsn_question(item) else 1, item.id))
            keep = group[0]
            for extra in group[1:]:
                _retire(extra)
                retired += 1
            src = adc_tsn_by_key.get(key)
            if src is not None and not is_tsn_question(keep):
                keep.topic = src.topic
                keep.save(update_fields=["topic", "updated_at"])
                upgraded += 1

        sup_subject = Subject.objects.get(code="SUP")
        sup_keys = {
            _plain(question.content)
            for question in Question.objects.filter(
                subject__code="SUP",
                status=Question.STATUS_APPROVED,
                is_locked_for_official_exam=False,
            )
        }
        created = 0
        for key, src in adc_tsn_by_key.items():
            if key in sup_keys:
                continue
            category, _ = Category.objects.get_or_create(
                subject=sup_subject,
                name=src.category.name if src.category_id else "Khac",
            )
            question = Question.objects.create(
                code=f"SUP-FROM-ADC-{src.id}",
                content=src.content,
                subject=sup_subject,
                category=category,
                topic=src.topic,
                status=Question.STATUS_APPROVED,
                question_type=src.question_type,
            )
            for order, answer in enumerate(
                src.answers.all().order_by("order", "id"), start=1
            ):
                Answer.objects.create(
                    question=question,
                    label=answer.label,
                    content=answer.content,
                    is_correct=answer.is_correct,
                    order=order,
                )
            created += 1
            sup_keys.add(key)

    print(f"retired={retired} upgraded={upgraded} created={created}")
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
