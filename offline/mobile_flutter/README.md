# ATC Exam PWA / Mobile

Ứng dụng Flutter offline-first dùng chung cho Web/PWA, Android và iOS.
Dữ liệu câu hỏi được tải từ Django REST API và lưu bằng Drift:

- Web: IndexedDB/OPFS thông qua SQLite WebAssembly.
- Android/iOS: SQLite trong vùng dữ liệu ứng dụng.
- Kết quả được lưu local trước, sau đó đưa vào `sync_queue`.

## Chạy Web/PWA

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --dart-define=ATC_API_BASE_URL=http://127.0.0.1:8000/api
```

Build production:

```bash
flutter build web --release --dart-define=ATC_API_BASE_URL=https://example.com/api
```

Không mở `build/web/index.html` bằng `file://`; hãy phục vụ qua HTTP/HTTPS.

## Chạy mobile

Trên Windows:

```bat
build_mobile_offline.bat
```

GitHub Actions: chạy workflow **Build Mobile Offline (iOS + Android)**.

## API và dữ liệu

Ngân hàng câu hỏi được lấy từ:

```text
GET /api/question-packages/
GET /api/question-packages/{package_id}/download/
POST /api/sync/
```

File `assets/questions.json` chỉ được giữ để đối chiếu dữ liệu cũ; runtime PWA
không nạp toàn bộ ngân hàng vào service worker.

## Kiểm tra

```bash
flutter analyze
flutter test
flutter build web --release
```
