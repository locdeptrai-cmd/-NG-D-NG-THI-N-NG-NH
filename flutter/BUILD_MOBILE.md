# Bản offline chạy trên iOS + Android

Một codebase Flutter dùng chung cho cả hai nền tảng:

- Thư mục app: `flutter`
- DB nhúng offline: `assets/offline_exam.db` (APS / ADC / ACC HAN / SUP / SUP ACS HAN / ACS SUP HCM)
- UI: chọn nhóm đề → thi 50 câu → chấm điểm

## File cài đặt

| Nền tảng | File | Cách tạo trên máy này (Windows) |
|---|---|---|
| Android | `dist/ATC_Offline_Mobile_Android.apk` | `build_android_one_file.bat` hoặc `build_mobile_offline.bat` |
| iOS | `dist/ATC_Offline_Mobile_iOS.ipa` | **Không** build local trên Windows — dùng GitHub Actions hoặc macOS |

## Build nhanh (Windows)

```bat
cd flutter
build_mobile_offline.bat
```

Cài APK lên điện thoại Android (bật “Cài từ nguồn không xác định” nếu cần).

## Build trên GitHub (iOS + Android)

Workflow Android: `.github/workflows/build-mobile-offline.yml`
Workflow iOS: `.github/workflows/build-ios.yml`

1. Repo → **Actions** → chọn **Build Android Offline** hoặc **Build iOS Offline App**
2. **Run workflow**
3. Tải artifact:
   - `ATC_Offline_Mobile_Android.apk` (cài được ngay)
   - iOS unsigned zip (kiểm tra compile) hoặc `.ipa` nếu đã cấu hình Apple signing secrets

Secrets cho iOS `.ipa` cài được: xem `BUILD_IOS.md`.

## Cập nhật ngân hàng câu hỏi

```bat
cd /d "f:\app thi thu"
.\.venv\Scripts\python.exe online\scripts\build_offline_db.py
copy /Y dist\offline_exam.db flutter\assets\offline_exam.db
cd flutter
build_mobile_offline.bat
```

Sau đó chạy lại workflow GitHub nếu cần bản iOS mới.
