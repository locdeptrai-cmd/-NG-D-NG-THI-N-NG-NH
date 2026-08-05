#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

python manage.py setup_local_defaults --settings=config.settings

# Force-sync question banks from the committed SQLite snapshot. Do not abort
# service startup if sync hits a transient data conflict — gunicorn must still boot.
set +o errexit
python manage.py sync_exam_bank_from_sqlite --force --settings=config.settings
sync_status=$?
set -o errexit
if [ "$sync_status" -ne 0 ]; then
  echo "WARNING: exam bank sync exited with status ${sync_status}; continuing startup."
fi

python manage.py shell --settings=config.settings -c \
  "from exam_bank.models import Question, Answer, Subject; \
codes=('APS','ADC','SUP'); \
counts={c: Question.objects.filter(subject__code=c, status='approved', is_locked_for_official_exam=False).exclude(code__startswith='ARCHIVED-').count() for c in codes}; \
print({'questions': Question.objects.count(), 'answers': Answer.objects.count(), 'by_subject': counts})"
