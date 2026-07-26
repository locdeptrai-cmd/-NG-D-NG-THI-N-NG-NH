# Hướng dẫn - Bản mobile offline (Flutter)

## Yêu cầu
- Flutter SDK đã cài đặt
- Android Studio (Android) / Xcode (iOS)

## Chạy thử
```bash
cd offline/mobile_flutter
flutter pub get
flutter run
```

## Build Android
```bash
build_android_one_file.bat
```

File cài đặt một file duy nhất:
- `offline/dist/ATC_Offline_Mobile_Android.apk`

## Build iOS (macOS)
```bash
chmod +x build_ios_one_file.sh
./build_ios_one_file.sh
```

File cài đặt một file duy nhất:
- `offline/dist/ATC_Offline_Mobile_iOS.ipa`

Lưu ý: iOS bắt buộc build trên macOS và phải cấu hình signing bằng Apple Developer/Xcode.

## DB offline
App dùng DB SQLite local từ assets:
- `assets/offline_exam.db`

Khi cập nhật ngân hàng câu hỏi từ web DB:
1. Tạo lại DB offline:
```bash
python ..\\build_offline_db.py
```
2. Copy DB mới vào assets:
```bash
copy ..\\data\\offline_exam.db assets\\offline_exam.db
```
3. Build lại app bằng `build_android_one_file.bat` hoặc `build_ios_one_file.sh`.
