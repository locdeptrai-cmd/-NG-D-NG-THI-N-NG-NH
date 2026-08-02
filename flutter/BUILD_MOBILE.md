# Bản offline chạy trên iOS + Android

Một codebase Flutter dùng chung cho cả hai nền tảng:

- Thư mục app: `flutter`
- DB nhúng offline: `assets/offline_exam.db` (APS / ADC / ACC HAN / SUP / SUP ACS HAN)
- UI: chọn nhóm đề → thi 50 câu → chấm điểm

## File cài đặt

| Nền tảng | File | Cách tạo trên máy này (Windows) |
|---|---|---|
| Android | `offline/dist/ATC_Offline_Mobile_Android.apk` | `build_android_one_file.bat` hoặc `build_mobile_offline.bat` |
| iOS | `offline/dist/ATC_Offline_Mobile_iOS.ipa` | **Không** build local trên Windows — dùng GitHub Actions hoặc macOS |

## Build nhanh (Windows)

```bat
cd flutter
build_mobile_offline.bat
```

Cài APK lên điện thoại Android (bật “Cài từ nguồn không xác định” nếu cần).

## Build trên GitHub (iOS + Android)

Workflow: `.github/workflows/build-mobile-offline.yml`

1. Repo → **Actions** → **Build Mobile Offline (iOS + Android)**
2. **Run workflow**
3. Tải artifact:
   - `ATC_Offline_Mobile_Android.apk` (cài được ngay)
   - iOS unsigned zip (kiểm tra compile) hoặc `.ipa` nếu đã cấu hình Apple signing secrets

Secrets cho iOS `.ipa` cài được: xem `BUILD_IOS.md`.

## Cập nhật ngân hàng câu hỏi

```bat
cd /d "f:\app thi thu"
python offline\build_offline_db.py
copy /Y offline\data\offline_exam.db flutter\assets\offline_exam.db
cd flutter
build_mobile_offline.bat
```

Sau đó chạy lại workflow GitHub nếu cần bản iOS mới.
