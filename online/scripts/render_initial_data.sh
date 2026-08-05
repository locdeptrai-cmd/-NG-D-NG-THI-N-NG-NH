#!/usr/bin/env bash
set -o errexit
export PYTHONUTF8=1

python manage.py setup_local_defaults --settings=config.settings

# Always force-sync question banks from the committed SQLite snapshot so
# production picks up replaced APS/ADC/SUP banks even when totals look close.
python manage.py sync_exam_bank_from_sqlite --force --settings=config.settings

python manage.py shell --settings=config.settings -c \
  "import sys; from exam_bank.models import Question, Answer, Subject; \
codes=('APS','ADC','SUP'); \
counts={c: Question.objects.filter(subject__code=c, status='approved', is_locked_for_official_exam=False).exclude(code__startswith='ARCHIVED-').count() for c in codes}; \
print({'questions': Question.objects.count(), 'answers': Answer.objects.count(), 'by_subject': counts}); \
sys.exit(0 if all(counts.values()) else 1)"
