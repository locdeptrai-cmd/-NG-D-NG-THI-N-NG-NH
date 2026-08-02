"""Root WSGI shim for legacy Render start commands that call gunicorn config.wsgi."""
import os
import sys
from pathlib import Path

ONLINE = Path(__file__).resolve().parent.parent / "online"
sys.path.insert(0, str(ONLINE))
os.chdir(ONLINE)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

from django.core.wsgi import get_wsgi_application

application = get_wsgi_application()
