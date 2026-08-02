import os
import shutil
import sqlite3
import sys
from pathlib import Path

ONLINE_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = ONLINE_ROOT.parent
sys.path.insert(0, str(ONLINE_ROOT))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.sqlite_settings")

import django

django.setup()

from exam_bank.models import Question

OUT = REPO_ROOT / "dist" / "offline_exam.db"
OUT.parent.mkdir(parents=True, exist_ok=True)
if OUT.exists():
    OUT.unlink()

conn = sqlite3.connect(OUT)
cur = conn.cursor()

cur.executescript(
    """
    PRAGMA journal_mode=WAL;
    CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        subject TEXT NOT NULL,
        category TEXT,
        content TEXT NOT NULL,
        explanation TEXT,
        question_type TEXT
    );

    CREATE TABLE answers (
        id INTEGER PRIMARY KEY,
        question_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        content TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        ord INTEGER,
        FOREIGN KEY(question_id) REFERENCES questions(id)
    );

    CREATE INDEX idx_questions_subject ON questions(subject);
    CREATE INDEX idx_answers_question ON answers(question_id);
    """
)

q_count = 0
a_count = 0
qs = (
    Question.objects.filter(
        status=Question.STATUS_APPROVED, is_locked_for_official_exam=False
    )
    .select_related("subject", "category")
    .prefetch_related("answers")
)

for q in qs:
    answers = list(q.answers.all().order_by("order", "id"))
    if len(answers) < 2:
        continue

    cur.execute(
        "INSERT INTO questions(code, subject, category, content, explanation, question_type) VALUES (?, ?, ?, ?, ?, ?)",
        (
            q.code,
            q.subject.code,
            q.category.name if q.category else "",
            q.content,
            q.explanation or "",
            q.question_type,
        ),
    )
    qid = cur.lastrowid
    q_count += 1

    for a in answers:
        cur.execute(
            "INSERT INTO answers(id, question_id, label, content, is_correct, ord) VALUES (?, ?, ?, ?, ?, ?)",
            (a.id, qid, a.label, a.content, 1 if a.is_correct else 0, a.order),
        )
        a_count += 1

conn.commit()
conn.close()

flutter_asset = REPO_ROOT / "flutter" / "assets" / "offline_exam.db"
if flutter_asset.parent.exists():
    shutil.copy2(OUT, flutter_asset)

print(f"Built SQLite DB: {OUT}")
print(f"Questions: {q_count}, Answers: {a_count}")
