@echo off
setlocal
cd /d "%~dp0"

set "REPO_ROOT=%~dp0.."
set "DB_PATH=%REPO_ROOT%\dist\offline_exam.db"
set "VENV_PY=%REPO_ROOT%\.venv\Scripts\python.exe"

if exist "%VENV_PY%" (
  set "PY=%VENV_PY%"
) else (
  set "PY=python"
)

if not exist "%DB_PATH%" (
  echo Building offline DB first...
  "%PY%" "%REPO_ROOT%\online\scripts\build_offline_db.py"
  if errorlevel 1 (
    echo Failed to build offline_exam.db
    exit /b 1
  )
)

"%PY%" -m pip show pyinstaller >nul 2>nul
if errorlevel 1 (
  "%PY%" -m pip install pyinstaller
)

"%PY%" -m PyInstaller ^
  --noconfirm ^
  --clean ^
  --onefile ^
  --windowed ^
  --name ATC_Offline_Exam_Windows ^
  --distpath "%REPO_ROOT%\dist" ^
  --workpath "%~dp0build" ^
  --specpath "%~dp0" ^
  --add-data "%DB_PATH%;." ^
  offline_exam.py

echo.
echo Da dong goi xong: %REPO_ROOT%\dist\ATC_Offline_Exam_Windows.exe
endlocal
