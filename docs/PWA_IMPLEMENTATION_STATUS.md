# Trạng thái triển khai ATC Exam PWA offline-first

Tài liệu nguồn: `Huong_dan_phat_trien_ATC_EXAM_PWA_offline.md`.

## Đã triển khai

### Django REST API

- JWT: đăng nhập, refresh token, thông tin người dùng.
- Health check có thời gian máy chủ.
- Danh sách môn học, danh mục và gói câu hỏi.
- Gói luyện tập có phiên bản, kích thước và SHA-256 checksum.
- Gói thi chính thức không trả đáp án đúng hoặc giải thích.
- API luyện tập, bắt đầu/autosave/nộp bài thi, kết quả.
- API sync nhận `operation_id`; cùng một tác vụ gửi lại không tạo bản ghi trùng.
- CORS giới hạn theo biến môi trường, không bật allow-all trong production.
- SQLite tiếp tục là mặc định của lệnh local; Docker tiếp tục dùng PostgreSQL.

### Flutter Web / PWA

- Một codebase Flutter cho Web, Android và iOS.
- Manifest standalone, metadata iOS và biểu tượng maskable.
- Service worker riêng cache app shell, Flutter engine, font, icon và WASM.
- Drift lưu SQLite native; trên Web dùng IndexedDB/OPFS qua SQLite WASM.
- Các bảng local: subjects, packages, questions, answers, attempts,
  sync queue, settings và user profile.
- Tải/cập nhật/xóa từng gói câu hỏi trong một transaction.
- Luyện tập hoàn toàn offline, xem đáp án và giải thích sau khi nộp.
- Lịch sử local và hàng đợi đồng bộ có retry.
- Không tự reload khi service worker có bản mới; worker mới chờ tới khi đóng
  các phiên cũ, vì vậy không cắt ngang bài đang làm.
- Giao diện responsive có trạng thái online/offline và số tác vụ chờ.

### CI

Workflow `.github/workflows/build-pwa.yml` thực hiện:

1. Cài package.
2. Sinh mã Drift.
3. Chuẩn bị SQLite WASM và web worker.
4. `flutter analyze`.
5. `flutter test`.
6. `flutter build web --release`.
7. Upload artifact `atc-exam-pwa`.

## Chạy local

Backend:

```powershell
.\.venv\Scripts\python.exe manage.py migrate --settings=config.sqlite_settings
.\.venv\Scripts\python.exe manage.py runserver 127.0.0.1:8000 --settings=config.sqlite_settings
```

PWA:

```powershell
cd offline\mobile_flutter
flutter pub get
dart run build_runner build
flutter build web --release --dart-define=ATC_API_BASE_URL=http://127.0.0.1:8000/api
python -m http.server 8080 --directory build\web
```

Mở `http://127.0.0.1:8080`. Không mở bằng `file://`.

## Việc cần hoàn tất trước production

- Đặt `DJANGO_DEBUG=0`, secret key ngẫu nhiên, host và CORS đúng tên miền.
- Triển khai cả PWA và API bằng HTTPS.
- Chọn chính sách lưu refresh token phù hợp với thiết bị/tổ chức.
- Thực hiện kiểm thử thủ công Add to Home Screen trên iPhone/iPad và Android
  thật; môi trường Windows hiện tại chỉ xác minh bằng Chromium.
- Bổ sung UI thi chính thức, đồng hồ server và chính sách mất mạng theo quy
  chế thi cụ thể trước khi dùng cho kỳ thi được giám sát.
- Khi thay đổi schema Drift, tăng `schemaVersion` và viết migration; không xóa
  IndexedDB trong một bản cập nhật thông thường.
