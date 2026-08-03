# Build bản offline iOS (iPhone)

## Giới hạn quan trọng
Apple **bắt buộc** build iOS trên **macOS + Xcode**.  
Máy Windows local **không thể** tạo file `.ipa` cài trực tiếp lên iPhone.

## Build trên GitHub (được)
Repo đã có workflow:
- `.github/workflows/build-ios.yml`

Cách chạy:
1. Vào GitHub repo → tab **Actions**
2. Chọn workflow **Build iOS Offline App**
3. Bấm **Run workflow**
4. Sau khi xong, tải artifact `atc-offline-ios`

### Nếu chưa cấu hình Apple signing
Workflow vẫn build được bản **unsigned** (chỉ kiểm tra compile, **chưa cài lên iPhone**).

### Để ra file `.ipa` cài được
Tạo Apple Developer cert + provisioning profile, rồi thêm GitHub Secrets:

| Secret | Nội dung |
|---|---|
| `APPLE_CERTIFICATE_BASE64` | file `.p12` encode base64 |
| `APPLE_CERTIFICATE_PASSWORD` | mật khẩu `.p12` |
| `APPLE_PROVISIONING_PROFILE_BASE64` | file `.mobileprovision` encode base64 |
| `APPLE_TEAM_ID` | Team ID (10 ký tự) |
| `KEYCHAIN_PASSWORD` | mật khẩu keychain tạm (tự đặt) |

Encode trên Mac/Linux:
```bash
base64 -i Certificates.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

Bundle ID hiện tại: `com.atc.offline.atcOfflineMobile`

## Đã chuẩn bị sẵn trong repo
- Project Flutter đầy đủ platform `ios/` + `android/`
- UI nhóm đề: **APS / ADC / ACC HAN / SUP / SUP ACS HAN**
- DB offline nhúng: `assets/offline_exam.db`

## Trên máy Mac (để ra file cài iPhone)

### 1) Cài tool
- Flutter SDK
- Xcode (mới)
- CocoaPods (`sudo gem install cocoapods`)
- Tài khoản Apple Developer (ký app)

### 2) Cập nhật DB mới nhất (nếu cần)
```bash
cd "/path/to/app thi thu"
python3 online/scripts/build_offline_db.py
cp dist/offline_exam.db flutter/assets/offline_exam.db
```

### 3) Build IPA một file
```bash
cd flutter
chmod +x build_ios_one_file.sh
./build_ios_one_file.sh
```

Output:
- `dist/ATC_Offline_Mobile_iOS.ipa`

### 4) Ký app trong Xcode (nếu script báo thiếu signing)
```bash
open ios/Runner.xcworkspace
```
Trong Xcode:
1. Chọn target **Runner**
2. Tab **Signing & Capabilities**
3. Chọn Team Apple Developer
4. Bundle ID duy nhất (vd: `com.atc.offline.exam`)
5. Chạy lại `./build_ios_one_file.sh`

### 5) Cài lên iPhone
- Test nội bộ: cài qua Xcode / Apple Configurator / TestFlight
- Phân phối ngoài App Store: thiết bị phải nằm trong provisioning profile

## Chạy thử trên simulator (Mac)
```bash
cd flutter
flutter pub get
flutter run -d ios
```
