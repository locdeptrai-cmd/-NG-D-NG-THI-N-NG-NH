#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

fixture_path="$(mktemp --suffix=.json)"

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
