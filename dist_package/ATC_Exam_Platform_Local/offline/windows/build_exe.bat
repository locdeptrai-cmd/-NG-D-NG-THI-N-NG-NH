@echo off
setlocal
cd /d "%~dp0"

python -m pip show pyinstaller >nul 2>nul
if errorlevel 1 (
  python -m pip install pyinstaller
)

python -m PyInstaller ^
  --noconfirm ^
  --clean ^
  --onefile ^
  --windowed ^
  --name ATC_Offline_Exam_Windows ^
  --add-data "..\data\offline_exam.db;data" ^
  offline_exam.py

if not exist "..\dist" mkdir "..\dist"
copy /Y "dist\ATC_Offline_Exam_Windows.exe" "..\dist\ATC_Offline_Exam_Windows.exe"
echo.
echo Da dong goi xong: ..\dist\ATC_Offline_Exam_Windows.exe
endlocal
