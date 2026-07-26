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
- rating / RATING (khong bat buoc; APS/ADC/SUP; SUP co the trung APS/ADC, VD: SUP,APS)

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

## 5) Luu y

- Bo file cu `app_thi_thu_full.html`, `data.js` de doi chieu du lieu.
- He thong moi luu cau hoi trong PostgreSQL, khong hard-code vao frontend.
