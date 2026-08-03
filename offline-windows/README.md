# Bản Windows offline

## Chạy từ mã nguồn

Cần có `dist/offline_exam.db` (dựng bằng `online/scripts/build_offline_db.py`):

```bash
python offline_exam.py
```

## Đóng gói một file .exe

```bat
build_exe.bat
```

Kết quả: `dist/ATC_Offline_Exam_Windows.exe` (đã nhúng DB).

## Cập nhật ngân hàng câu hỏi

```bash
..\.venv\Scripts\python.exe ..\online\scripts\build_offline_db.py
build_exe.bat
```
