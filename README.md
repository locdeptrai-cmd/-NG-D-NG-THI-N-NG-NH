# ATC Exam Platform (Django + SQLite local / PostgreSQL Docker)

## 1) Chay local (khong Docker)

```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py setup_local_defaults
python manage.py runserver
```

Truy cap:
- Trang chu: http://127.0.0.1:8000/
- Admin: http://127.0.0.1:8000/admin/

Ban Windows co the chay truc tiep `ATC_Exam_Local_Setup_And_Run.bat`.
Lenh `manage.py` mac dinh dung file `dev.sqlite3`; Docker Compose tu dong
chuyen sang cau hinh PostgreSQL.

## 2) Chay bang Docker

```bash
docker compose up --build
```

## 3) Import cau hoi CSV/XLSX

Format cot:
- Ma cau hoi / Mã câu hỏi
- Noi dung cau hoi / Nội dung câu hỏi
- A, B, C, D
- Dap an dung / Đáp án đúng (VD: B hoac AC)
- Giai thich / Giải thích
- Chu de / Chủ đề
- Muc do / Mức độ
- Tai lieu tham chieu / Tài liệu tham chiếu
- rating / RATING (khong bat buoc; APS/ADC/ACC HAN/SUP; alias ACC->ACC HAN; SUP co the trung APS/ADC)

Lenh:
```bash
python manage.py import_questions "10. LTCS TWR GCU TSN.xlsx" --subject ADC
python manage.py import_questions "sup-bank.xlsx" --subject SUP
```

## 4) Kien truc chinh

- `exam_bank/models.py`: users/roles/subjects/categories/questions/answers/question_versions/exams/exam_questions/attempts/attempt_answers/documents/audit_logs
- `exam_bank/admin.py`: quan tri ngan hang cau hoi
- `exam_bank/services.py`: tao de ngau nhien theo ma tran
- `exam_bank/management/commands/import_questions.py`: import CSV/XLSX

## 5) Ban offline mobile (Android + iOS)

Mot app Flutter dung chung:
- `offline/mobile_flutter/`
- Huong dan: `offline/mobile_flutter/BUILD_MOBILE.md`

Build Android (Windows):
```bat
cd offline\mobile_flutter
build_android_one_file.bat
```
File: `offline/dist/ATC_Offline_Mobile_Android.apk`

Build iOS + Android tren GitHub Actions:
- Workflow: **Build Mobile Offline (iOS + Android)**

## 6) PWA offline-first

Backend cung cap REST API JWT tai `/api/`:
- `/api/health/`
- `/api/auth/login/`, `/api/auth/refresh/`, `/api/auth/me/`
- `/api/subjects/`, `/api/categories/`
- `/api/question-packages/` va API download
- `/api/practice/`, `/api/exams/`, `/api/results/`, `/api/sync/`

Frontend PWA nam tai `offline/mobile_flutter/`, dung Drift de luu SQLite
native va IndexedDB/OPFS tren Web. Build:

```bash
cd offline/mobile_flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build web --release
```

Workflow **Build ATC Exam PWA** se analyze, test, build va tao artifact.

## 7) Backend production tren Render

File `render.yaml` tao dong bo:

- Django API tai `https://atc-exam-api.onrender.com`.
- PostgreSQL tai region Singapore, chi cho phep ket noi noi bo.
- Secret key ngau nhien, HTTPS, CORS cho GitHub Pages.
- Import du lieu tu `dev.sqlite3` sang PostgreSQL (lan dau day du; cac lan sau sync ngan hang cau hoi theo nhom lech, gom ACC HAN / SUP ACS HAN).

Tren Render Dashboard, chon **New Blueprint Instance**, ket noi repository nay
va ap dung `render.yaml`. Sau khi API hoat dong, dat GitHub Actions variable:

```text
ATC_API_BASE_URL=https://atc-exam-api.onrender.com/api
```

Roi chay lai workflow **Deploy ATC Exam PWA to GitHub Pages**.

## 8) Luu y

- Bo file cu `app_thi_thu_full.html`, `data.js` de doi chieu du lieu.
- He thong moi luu cau hoi trong PostgreSQL, khong hard-code vao frontend.
