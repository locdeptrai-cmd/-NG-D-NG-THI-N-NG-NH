"""Root WSGI shim for legacy Render start commands that call gunicorn config.wsgi."""
import os
import sys
from pathlib import Path

ONLINE = Path(__file__).resolve().parent.parent / "online"
sys.path.insert(0, str(ONLINE))
os.chdir(ONLINE)

# Drop the root shim package so Django loads online/config/settings.py.
for key in list(sys.modules):
    if key == "config" or key.startswith("config."):
        del sys.modules[key]

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

from django.core.wsgi import get_wsgi_application

application = get_wsgi_application()
