@echo off
setlocal EnableExtensions EnableDelayedExpansion

title ATC Exam Platform - Local Setup and Run
cd /d "%~dp0"

echo ============================================================
echo  ATC Exam Platform - Cai dat va chay local
echo ============================================================
echo  Thu muc: %CD%
echo.

where py >nul 2>nul
if %ERRORLEVEL%==0 (
    set "PY_CMD=py -3"
) else (
    where python >nul 2>nul
    if %ERRORLEVEL%==0 (
        set "PY_CMD=python"
    ) else (
        echo [LOI] Khong tim thay Python 3.
        echo Vui long cai Python 3.11+ tu https://www.python.org/downloads/
        echo Khi cai dat, tick "Add python.exe to PATH".
        pause
        exit /b 1
    )
)

echo [1/7] Kiem tra Python...
%PY_CMD% --version
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Python khong chay duoc.
    pause
    exit /b 1
)

set "REPO_ROOT=%CD%\.."
if exist "%REPO_ROOT%\.venv\Scripts\python.exe" (
    set "VENV_DIR=%REPO_ROOT%\.venv"
) else if exist "%CD%\.venv\Scripts\python.exe" (
    set "VENV_DIR=%CD%\.venv"
) else (
    set "VENV_DIR=%REPO_ROOT%\.venv"
)

if not exist "%VENV_DIR%\Scripts\python.exe" (
    echo.
    echo [2/7] Tao moi moi truong ao .venv tai repo root...
    %PY_CMD% -m venv "%VENV_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo [LOI] Khong tao duoc .venv.
        pause
        exit /b 1
    )
) else (
    echo.
    echo [2/7] Da co .venv, bo qua tao moi.
)

set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "VENV_PIP=%VENV_DIR%\Scripts\pip.exe"
set "DJANGO_SETTINGS_MODULE=config.sqlite_settings"
set "PYTHONIOENCODING=utf-8"

echo.
echo [3/7] Nang cap pip va cai dependencies...
"%VENV_PY%" -m pip install --upgrade pip
if %ERRORLEVEL% NEQ 0 (
    echo [CANH BAO] Khong nang cap duoc pip, tiep tuc cai requirements.
)
if exist "wheels" (
    echo Dang cai dependencies tu thu muc wheels local...
    "%VENV_PIP%" install --no-index --find-links=wheels -r requirements.txt
    if %ERRORLEVEL% NEQ 0 (
        echo [CANH BAO] Cai tu wheels that bai, thu cai online bang pip...
        "%VENV_PIP%" install -r requirements.txt
    )
) else (
    "%VENV_PIP%" install -r requirements.txt
)
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Cai requirements that bai.
    pause
    exit /b 1
)

echo.
echo [4/7] Chay migrate SQLite local...
"%VENV_PY%" manage.py migrate --settings=config.sqlite_settings
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Migrate database that bai.
    pause
    exit /b 1
)

echo.
echo [5/7] Tao cau hinh local va tai khoan mac dinh neu thieu...
"%VENV_PY%" manage.py setup_local_defaults --settings=config.sqlite_settings
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Tao cau hinh local that bai.
    pause
    exit /b 1
)

echo.
echo [6/7] Kiem tra he thong...
"%VENV_PY%" manage.py check --settings=config.sqlite_settings
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Django check phat hien loi.
    pause
    exit /b 1
)

echo.
echo [7/7] Kiem tra ngan hang cau hoi...
"%VENV_PY%" manage.py shell --settings=config.sqlite_settings -c "from django.db.models import Count; from exam_bank.models import Question; print('Approved:', list(Question.objects.filter(status=Question.STATUS_APPROVED).values('subject__code').order_by('subject__code').annotate(count=Count('id'))))"

echo.
echo ============================================================
echo  San sang.
echo  URL dang nhap: http://127.0.0.1:8000/login/
echo  Tai khoan: admin / endteacher / enduser
echo  Mat khau mac dinh: 123456
echo.
echo  Nhan Ctrl+C de dung server.
echo ============================================================
echo.

start "" "http://127.0.0.1:8000/login/"
"%VENV_PY%" manage.py runserver 127.0.0.1:8000 --settings=config.sqlite_settings

pause
