# Hướng dẫn nhanh - Bản Windows offline

## Chạy trực tiếp từ mã nguồn
```bash
python offline_exam.py
```

## Đóng gói thành một file duy nhất
```bash
build_exe.bat
```

Sau khi build xong, file chạy duy nhất nằm tại:
- `offline\dist\ATC_Offline_Exam_Windows.exe`

File `.exe` này đã nhúng sẵn DB `offline_exam.db`, người dùng cuối chỉ cần chạy đúng file `.exe`.

## DB offline
Khi chạy từ mã nguồn, ứng dụng đọc dữ liệu từ:
- `..\data\offline_exam.db`

Khi chạy từ file `.exe` đã đóng gói, DB được nhúng trong chính file `.exe`.

Khi cập nhật ngân hàng câu hỏi từ web DB, chạy lại:
```bash
python ..\\build_offline_db.py
build_exe.bat
```
