#!/usr/bin/env bash
set -o errexit
cd "$(dirname "$0")/online"
python manage.py migrate --settings=config.settings
bash scripts/render_initial_data.sh
exec gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers 2 --timeout 120
