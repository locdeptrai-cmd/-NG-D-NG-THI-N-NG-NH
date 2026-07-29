#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

if python manage.py shell --settings=config.settings -c \
  "import sys; from django.contrib.auth import get_user_model; from exam_bank.models import Question, Answer; counts=(get_user_model().objects.count(), Question.objects.count(), Answer.objects.count()); print({'current_counts': counts}); sys.exit(0 if all(counts) else (1 if not any(counts) else 2))"
then
  echo "PostgreSQL already contains the ATC EXAM seed data; skipping import."
  exit 0
else
  state=$?
  if [ "$state" -eq 2 ]; then
    echo "Refusing to import into a partially populated PostgreSQL database." >&2
    exit 2
  fi
fi

fixture_path="$(mktemp --suffix=.json)"
trap 'rm -f "$fixture_path"' EXIT

python manage.py dumpdata \
  --settings=config.sqlite_settings \
  --natural-foreign \
  --natural-primary \
  --exclude contenttypes \
  --exclude auth.permission \
  --exclude admin.logentry \
  --exclude sessions.session \
  --indent 2 \
  --output "$fixture_path"

python manage.py loaddata "$fixture_path" --settings=config.settings

python manage.py shell --settings=config.settings -c \
  "from django.contrib.auth import get_user_model; from exam_bank.models import Question, Answer; print({'users': get_user_model().objects.count(), 'questions': Question.objects.count(), 'answers': Answer.objects.count()})"
