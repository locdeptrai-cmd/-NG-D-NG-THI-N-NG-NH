"""Root WSGI shim for legacy Render start commands that call gunicorn config.wsgi."""
import os
import sys
from pathlib import Path

ONLINE = Path(__file__).resolve().parent.parent / "online"
sys.path.insert(0, str(ONLINE))
os.chdir(ONLINE)

# Keep this imported module registered as ``config.wsgi`` while extending the
# package search path so ``config.settings`` resolves to online/config.
config_package = sys.modules["config"]
online_config = str(ONLINE / "config")
if online_config not in config_package.__path__:
    config_package.__path__.insert(0, online_config)

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

from django.core.wsgi import get_wsgi_application

application = get_wsgi_application()
