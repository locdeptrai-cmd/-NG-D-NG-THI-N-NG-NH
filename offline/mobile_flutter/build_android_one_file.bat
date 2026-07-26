@echo off
setlocal
cd /d "%~dp0"

where flutter >nul 2>nul
if errorlevel 1 (
  echo Khong tim thay Flutter trong PATH.
  echo Cai Flutter SDK, mo terminal moi, roi chay lai file nay.
  exit /b 1
)

REM Java 26+ chua tuong thich Gradle Flutter mac dinh; uu tien JDK 17 neu co.
if exist "H:\jdk26\temurin-17\bin\java.exe" (
  set "JAVA_HOME=H:\jdk26\temurin-17"
  set "PATH=%JAVA_HOME%\bin;%PATH%"
  flutter config --jdk-dir="H:\jdk26\temurin-17" >nul
)

if exist "..\data\offline_exam.db" (
  copy /Y "..\data\offline_exam.db" "assets\offline_exam.db" >nul
)

flutter pub get
if errorlevel 1 exit /b 1

flutter build apk --release
if errorlevel 1 exit /b 1

if not exist "..\dist" mkdir "..\dist"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\dist\ATC_Offline_Mobile_Android.apk"

echo.
echo Da dong goi xong: ..\dist\ATC_Offline_Mobile_Android.apk
endlocal
