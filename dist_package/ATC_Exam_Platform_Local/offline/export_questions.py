import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.sqlite_settings")
import django

django.setup()

from exam_bank.models import Question

OUT = Path("offline/data/questions.json")
OUT.parent.mkdir(parents=True, exist_ok=True)

rows = []
qs = (
    Question.objects.filter(status=Question.STATUS_APPROVED, is_locked_for_official_exam=False)
    .select_related("subject", "category")
    .prefetch_related("answers")
)
for q in qs:
    answers = []
    for a in q.answers.all().order_by("order", "id"):
        answers.append({
            "id": a.id,
            "label": a.label,
            "content": a.content,
            "is_correct": a.is_correct,
        })
    if len(answers) < 2:
        continue
    rows.append({
        "code": q.code,
        "subject": q.subject.code,
        "category": q.category.name,
        "content": q.content,
        "explanation": q.explanation or "",
        "question_type": q.question_type,
        "answers": answers,
    })

with OUT.open("w", encoding="utf-8") as f:
    json.dump(rows, f, ensure_ascii=False, indent=2)

print(f"Exported {len(rows)} questions to {OUT}")
