#!/usr/bin/env python
"""Root shim so Render/dashboard commands keep working after the app moved to online/."""
import os
import sys
from pathlib import Path

ONLINE = Path(__file__).resolve().parent / "online"
sys.path.insert(0, str(ONLINE))
os.chdir(ONLINE)


def main():
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
