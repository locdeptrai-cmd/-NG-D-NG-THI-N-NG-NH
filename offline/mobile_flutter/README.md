# Hướng dẫn - Bản mobile offline (Flutter)

**Một app offline chạy được trên Android + iOS** (cùng codebase).

Xem tổng hợp nhanh: [`BUILD_MOBILE.md`](BUILD_MOBILE.md)

## Yêu cầu
- Flutter SDK đã cài đặt
- Android Studio (Android) / Xcode (iOS)

## Chạy thử
```bash
cd offline/mobile_flutter
flutter pub get
flutter run
```

## Build cả nền tảng (khuyến nghị)
### Trên Windows (ra APK Android ngay)
```bat
build_mobile_offline.bat
```

### Trên GitHub (Android APK + iOS)
Actions → **Build Mobile Offline (iOS + Android)** → Run workflow

## Build Android riêng
```bash
build_android_one_file.bat
```

File:
- `offline/dist/ATC_Offline_Mobile_Android.apk`

## Build iOS
- Local Windows: **không** tạo được `.ipa`
- **GitHub Actions**: được — xem `BUILD_IOS.md` / `BUILD_MOBILE.md`
- Local macOS:
```bash
chmod +x build_ios_one_file.sh
./build_ios_one_file.sh
```

File:
- `offline/dist/ATC_Offline_Mobile_iOS.ipa`

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
