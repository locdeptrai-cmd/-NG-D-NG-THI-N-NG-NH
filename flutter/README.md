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

## GitHub Pages

Workflow **Deploy ATC Exam PWA to GitHub Pages** build với base path:

```text
/-NG-D-NG-THI-N-NG-NH/
```

Địa chỉ xuất bản:

```text
https://locdeptrai-cmd.github.io/-NG-D-NG-THI-N-NG-NH/
```

Khai báo repository variable `ATC_API_BASE_URL` bằng URL API HTTPS trước khi
deploy production. Nếu chưa có biến này, người dùng có thể chọn **Máy chủ** tại
màn hình đăng nhập để nhập URL. Backend phải cho phép CORS origin
`https://locdeptrai-cmd.github.io`.

## Chạy mobile

Trên Windows:

```bat
build_mobile_offline.bat
```

GitHub Actions: dùng **Build Android Offline** cho APK và
**Build iOS Offline App** cho gói iOS.

## API và dữ liệu

Ngân hàng câu hỏi được lấy từ:

```text
GET /api/question-packages/
GET /api/question-packages/{package_id}/download/
POST /api/sync/
```

Database nhúng duy nhất là `assets/offline_exam.db`; không duy trì thêm bản
JSON song song để tránh lệch dữ liệu.

## Kiểm tra

```bash
flutter analyze
flutter test
flutter build web --release
```
