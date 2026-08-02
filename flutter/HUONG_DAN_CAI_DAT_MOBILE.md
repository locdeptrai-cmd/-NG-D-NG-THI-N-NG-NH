# HUONG DAN CAI DAT PHIEN BAN MOBILE (iOS + Android)

Tai lieu nay dung cho ung dung mobile offline Flutter trong thu muc:
- `flutter`

---

## 1) Yeu cau moi truong

### Bat buoc
- Flutter SDK (khuyen nghi ban stable moi nhat)
- Git

### Neu build Android
- Android Studio
- Android SDK + Android SDK Platform tools
- Java JDK (theo khuyen nghi cua Flutter)

### Neu build iOS
- May macOS
- Xcode (ban moi)
- CocoaPods

---

## 2) Kiem tra moi truong

Mo terminal va chay:

```bash
flutter doctor
```

Dat muc tieu:
- Khong con loi do thieu SDK/tool quan trong
- Android toolchain OK (neu build Android)
- Xcode toolchain OK (neu build iOS)

---

## 3) Cai dat project mobile

Di chuyen vao thu muc app:

```bash
cd flutter
```

Tai package:

```bash
flutter pub get
```

---

## 4) Chay thu tren thiet bi

### Android (USB debugging hoac emulator)
```bash
flutter devices
flutter run
```

### iOS (chi tren macOS)
```bash
flutter devices
flutter run
```

---

## 5) Dong goi thanh file cai dat duy nhat

### Android APK mot file
```bash
build_android_one_file.bat
```

File output:
- `offline/dist/ATC_Offline_Mobile_Android.apk`

Nguoi dung Android chi can cai file `.apk` nay.

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

File output:
- `build/app/outputs/bundle/release/app-release.aab`

### iOS IPA mot file - macOS
```bash
chmod +x build_ios_one_file.sh
./build_ios_one_file.sh
```

File output:
- `offline/dist/ATC_Offline_Mobile_iOS.ipa`

Luu y bat buoc cua iOS:
- Phai build tren macOS
- Phai co Apple Developer signing/certificate/provisioning profile
- Neu phan phoi ngoai App Store, thiet bi phai duoc phep cai theo hinh thuc phan phoi cua Apple

---

## 6) Du lieu offline (DB kem san)

App mobile doc DB SQLite tu:
- `flutter/assets/offline_exam.db`

DB nay da duoc dong goi trong app qua `pubspec.yaml`.

---

## 7) Cap nhat ngan hang cau hoi cho mobile

Khi DB web thay doi, cap nhat theo quy trinh:

1. Tao lai DB offline:
```bash
cd d:\app thi thu
python offline/build_offline_db.py
```

2. Copy DB moi vao mobile assets:
```bash
copy offline\data\offline_exam.db flutter\assets\offline_exam.db
```

3. Chay lai:
```bash
cd flutter
flutter pub get
flutter run
```

4. Neu phat hanh ban moi, build lai file cai dat:
```bash
cd flutter
build_android_one_file.bat
```

Tren macOS cho iOS:
```bash
cd flutter
./build_ios_one_file.sh
```

---

## 8) Su co thuong gap

### Loi khong tim thay thiet bi
- Kiem tra `flutter devices`
- Android: bat USB debugging
- iOS: trust device + mo khoa may

### Loi package/sqflite
- Chay lai `flutter clean`
- Sau do `flutter pub get`

### App van hien du lieu cu
- Da copy DB moi chua?
- Da build/chay lai app chua?
- Neu can, go app cu roi cai lai ban moi.

---

## 9) Lenh nhanh tong hop

```bash
cd flutter
flutter pub get
flutter run
build_android_one_file.bat
flutter build appbundle --release
```

(iOS tren macOS)
```bash
./build_ios_one_file.sh
```
