#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

python manage.py setup_local_defaults --settings=config.settings

if python manage.py shell --settings=config.settings -c \
  "import sys; from django.contrib.auth import get_user_model; from exam_bank.models import Question, Answer; counts=(get_user_model().objects.count(), Question.objects.count(), Answer.objects.count()); print({'current_counts': counts}); sys.exit(0 if all(counts) else (1 if not any(counts) else 2))"
then
  echo "PostgreSQL already contains ATC EXAM seed users/questions; syncing exam bank from SQLite."
else
  state=$?
  if [ "$state" -eq 2 ]; then
    echo "Refusing to import into a partially populated PostgreSQL database." >&2
    exit 2
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
fi

# Always reconcile question bank with the SQLite snapshot shipped in the repo.
python manage.py sync_exam_bank_from_sqlite --settings=config.settings
