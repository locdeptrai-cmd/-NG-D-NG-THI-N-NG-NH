#!/usr/bin/env python
import os
import sys


def main():
    # This workspace is distributed as a self-contained local application.
    # Docker explicitly opts into PostgreSQL; normal manage.py commands should
    # therefore use the bundled SQLite database and must not hang waiting for a
    # PostgreSQL instance that is not running.
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.sqlite_settings")
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
