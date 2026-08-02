@echo off
setlocal
cd /d "%~dp0"

where flutter >nul 2>nul
if errorlevel 1 (
  echo Khong tim thay Flutter trong PATH.
  exit /b 1
)

if exist "..\dist\offline_exam.db" (
  copy /Y "..\dist\offline_exam.db" "assets\offline_exam.db" >nul
)

echo === Flutter pub get ===
flutter pub get
if errorlevel 1 exit /b 1

echo === Build Android APK ===
call build_android_one_file.bat
if errorlevel 1 exit /b 1

echo.
echo Android OK: ..\dist\ATC_Offline_Mobile_Android.apk
echo.
echo iOS: tren Windows khong build duoc .ipa.
echo   - Dung GitHub Actions: Build Mobile Offline (iOS + Android)
echo   - Hoac Mac: build_ios_one_file.sh
echo Chi tiet: BUILD_MOBILE.md
endlocal
