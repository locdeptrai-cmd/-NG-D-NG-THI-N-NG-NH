# ATC Exam Platform

Monorepo gồm bốn phần:

| Thư mục | Vai trò |
|---|---|
| `online/` | Django API và web thi thử (Render, Docker, local) |
| `offline-windows/` | Ứng dụng Windows offline (Tkinter + PyInstaller) |
| `flutter/` | Một mã nguồn cho PWA, Android và iOS |
| `dist/` | Database offline; các gói cài đặt được build cục bộ hoặc tải từ GitHub Actions |

## Chạy Django local

```powershell
cd online
..\.venv\Scripts\python.exe manage.py migrate --settings=config.sqlite_settings
..\.venv\Scripts\python.exe manage.py setup_local_defaults --settings=config.sqlite_settings
$env:ATC_BOOTSTRAP_PASSWORD = "mat-khau-manh-cua-ban"
..\.venv\Scripts\python.exe manage.py setup_local_defaults --create-users --settings=config.sqlite_settings
Remove-Item Env:ATC_BOOTSTRAP_PASSWORD
..\.venv\Scripts\python.exe manage.py runserver --settings=config.sqlite_settings
```

Hoặc chạy `online/ATC_Exam_Local_Setup_And_Run.bat`. Chương trình sẽ yêu cầu
nhập mật khẩu khởi tạo; dự án không còn mật khẩu tài khoản mặc định.

- Trang đăng nhập: http://127.0.0.1:8000/login/
- Tài khoản demo được tạo khi có yêu cầu: `admin`, `endteacher`, `enduser`
- File Excel nguồn: `online/imports/`

Docker từ repo root:

```powershell
docker compose up --build
```

Bootstrap production chỉ tạo role/quyền và đồng bộ ngân hàng câu hỏi; không sao
chép tài khoản từ SQLite development. Tạo quản trị viên production bằng Render
Shell hoặc môi trường quản trị riêng:

```bash
python manage.py createsuperuser --settings=config.settings
```

## Làm sạch và đồng bộ ngân hàng câu hỏi

```powershell
cd online
..\.venv\Scripts\python.exe manage.py clean_exam_bank --settings=config.sqlite_settings
..\.venv\Scripts\python.exe manage.py clean_exam_bank --apply --settings=config.sqlite_settings
cd ..
.\.venv\Scripts\python.exe online\scripts\build_offline_db.py
```

Lệnh làm sạch mặc định chỉ báo cáo. `--apply` xóa bản trùng hoàn toàn chưa từng
được dùng; câu có lịch sử thi được lưu trữ và khóa thay vì xóa.

## Build offline

Windows:

```bat
cd offline-windows
build_exe.bat
```

Flutter/PWA/Android:

```powershell
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build web --release
flutter build apk --release
```

- Windows EXE và Android APK được tạo trong `dist/` nhưng không commit vào Git.
- iOS phải build trên macOS/Xcode hoặc workflow `Build iOS Offline App`.
- PWA: https://locdeptrai-cmd.github.io/-NG-D-NG-THI-N-NG-NH/

## Tài liệu

- `offline-windows/README.md`
- `flutter/BUILD_MOBILE.md`
- `flutter/BUILD_IOS.md`
- `docs/HUONG_DAN_SU_DUNG_CHI_TIET.md`
- `docs/PWA_IMPLEMENTATION_STATUS.md`
