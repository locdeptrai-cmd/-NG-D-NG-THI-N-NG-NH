#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

python manage.py setup_local_defaults --settings=config.settings

# Sync only reference/question-bank data. Authentication data is never copied
# from the development SQLite database into production.
python manage.py sync_exam_bank_from_sqlite --settings=config.settings

python manage.py shell --settings=config.settings -c \
  "import sys; from exam_bank.models import Question, Answer; counts=(Question.objects.count(), Answer.objects.count()); print({'questions': counts[0], 'answers': counts[1]}); sys.exit(0 if all(counts) else 1)"
