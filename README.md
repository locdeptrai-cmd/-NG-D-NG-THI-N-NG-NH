# ATC Exam Platform

Monorepo chia 4 phần:

| Thư mục | Vai trò |
|---------|---------|
| `online/` | Django API + web thi thử (Render / Docker / local) |
| `offline-windows/` | App Windows offline (Tkinter + PyInstaller) |
| `flutter/` | **1 mã nguồn** chạy PWA + Android + iOS |
| `dist/` | Artifact đã build (exe, apk, ipa, `offline_exam.db`) |

## 1) Online (Django)

```bash
```powershell
cd online
# Dùng Python từ venv ở repo root
..\.venv\Scripts\python.exe manage.py migrate --settings=config.sqlite_settings
..\.venv\Scripts\python.exe manage.py setup_local_defaults --settings=config.sqlite_settings
..\.venv\Scripts\python.exe manage.py runserver --settings=config.sqlite_settings
```

Hoặc chạy `online/ATC_Exam_Local_Setup_And_Run.bat`.

- Trang chủ: http://127.0.0.1:8000/
- Tài khoản mặc định: `admin` / `endteacher` / `enduser` — mật khẩu `123456`
- File Excel nguồn: `online/imports/`

Docker (từ repo root):

```bash
docker compose up --build
```

Production: `render.yaml` dùng `rootDir: online` → https://atc-exam-api.onrender.com

## 2) Windows offline

```bat
cd offline-windows
build_exe.bat
```

Exe: `dist/ATC_Offline_Exam_Windows.exe`

Dựng lại DB offline từ Django:

```bash
..\ .venv\Scripts\python.exe online\scripts\build_offline_db.py
```

## 3) Flutter (PWA + Android + iOS)

Một codebase: `flutter/`

```bash
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build web --release
flutter build apk --release
```

- PWA GitHub Pages: https://locdeptrai-cmd.github.io/-NG-D-NG-THI-N-NG-NH/
- Hướng dẫn mobile: `flutter/BUILD_MOBILE.md`, `flutter/BUILD_IOS.md`

## 4) `dist/`

Chứa sản phẩm đóng gói và `offline_exam.db` (seed cho Windows/Flutter offline).

## Tài liệu thêm

- `docs/HUONG_DAN_SU_DUNG_CHI_TIET.md`
- `docs/PWA_IMPLEMENTATION_STATUS.md`
