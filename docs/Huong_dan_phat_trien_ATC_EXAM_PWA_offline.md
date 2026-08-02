# HƯỚNG DẪN PHÁT TRIỂN ỨNG DỤNG ATC EXAM THEO HƯỚNG PWA

## 1. Mục tiêu

Xây dựng ứng dụng **ATC EXAM** theo mô hình **Progressive Web App (PWA)**, cho phép:

- Chạy trên iPhone, iPad, Android, Windows và các thiết bị có trình duyệt hiện đại.
- Không cần phát hành qua App Store hoặc Google Play trong giai đoạn đầu.
- Không cần ký ứng dụng iOS.
- Người dùng truy cập ứng dụng lần đầu khi có Internet.
- Ứng dụng tự lưu giao diện, mã chương trình và dữ liệu cần thiết xuống thiết bị.
- Những lần sử dụng sau có thể mở và làm bài khi không có Internet.
- Khi có mạng trở lại, ứng dụng có thể đồng bộ kết quả, tài khoản và dữ liệu câu hỏi mới với máy chủ Django.
- Có thể thêm biểu tượng ATC EXAM vào màn hình chính của iPhone và Android.

Kiến trúc tổng thể:

```text
Người dùng
   │
   ├── iPhone / iPad
   ├── Android
   └── Windows / macOS
          │
          ▼
Flutter Web / PWA
          │
          ├── Cache Storage: lưu giao diện và tài nguyên ứng dụng
          ├── IndexedDB: lưu câu hỏi, bài thi, kết quả, hàng đợi đồng bộ
          └── Service Worker: điều phối hoạt động offline
          │
          ▼
Django REST API
          │
          ├── SQLite khi chạy local
          └── PostgreSQL khi triển khai máy chủ
```

---

## 2. Công nghệ đề xuất

### 2.1. Backend

Giữ nguyên nền tảng Django hiện có:

- Django 5.x.
- SQLite cho môi trường local.
- PostgreSQL cho môi trường triển khai.
- Django Admin để quản trị ngân hàng câu hỏi.
- OpenPyXL để import dữ liệu CSV/XLSX.
- Django REST Framework để cung cấp API cho PWA.
- JWT để xác thực người dùng.
- CORS Headers để cho phép frontend gọi API.

Bổ sung vào `requirements.txt`:

```txt
Django>=5.0,<6.0
djangorestframework>=3.15
djangorestframework-simplejwt>=5.3
django-cors-headers>=4.3
psycopg[binary]>=3.1
openpyxl>=3.1
python-dotenv>=1.0
```

Cài đặt:

```bash
pip install -r requirements.txt
```

### 2.2. Frontend

Sử dụng Flutter Web để phát triển một codebase có thể dùng cho:

- PWA trên iOS.
- PWA trên Android.
- Web trên máy tính.
- Có thể mở rộng thành Flutter Android native hoặc Flutter iOS native về sau.

Các package Flutter nên sử dụng:

```yaml
dependencies:
  flutter:
    sdk: flutter

  dio: ^5.7.0
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  drift: ^2.26.0
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.32
  shared_preferences: ^2.5.3
  connectivity_plus: ^6.1.4
  flutter_secure_storage: ^9.2.4
  json_annotation: ^4.9.0
  uuid: ^4.5.1
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.15
  drift_dev: ^2.26.0
  json_serializable: ^6.9.4
  flutter_lints: ^5.0.0
```

Lưu ý:

- Đối với Flutter Web, Drift có thể sử dụng IndexedDB thông qua WebAssembly.
- Có thể dùng Isar hoặc Hive thay cho Drift, nhưng Drift phù hợp hơn với dữ liệu bài thi có quan hệ rõ ràng.
- Không lưu mật khẩu trực tiếp trên thiết bị.
- Token đăng nhập cần có thời hạn và cơ chế refresh.

---

## 3. Cấu trúc thư mục đề xuất

```text
ATC_EXAM/
├── manage.py
├── requirements.txt
├── docker-compose.yml
├── exam_bank/
│   ├── models.py
│   ├── admin.py
│   ├── services.py
│   ├── serializers.py
│   ├── api_views.py
│   ├── api_urls.py
│   └── management/
│       └── commands/
│           └── import_questions.py
│
├── atc_exam/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
│
├── offline/
│   └── mobile_flutter/
│       ├── lib/
│       │   ├── core/
│       │   │   ├── api/
│       │   │   ├── database/
│       │   │   ├── network/
│       │   │   ├── router/
│       │   │   ├── sync/
│       │   │   └── theme/
│       │   ├── data/
│       │   │   ├── local/
│       │   │   ├── remote/
│       │   │   ├── models/
│       │   │   └── repositories/
│       │   ├── features/
│       │   │   ├── authentication/
│       │   │   ├── dashboard/
│       │   │   ├── subjects/
│       │   │   ├── practice/
│       │   │   ├── examination/
│       │   │   ├── results/
│       │   │   ├── downloads/
│       │   │   └── settings/
│       │   └── main.dart
│       ├── web/
│       │   ├── index.html
│       │   ├── manifest.json
│       │   └── icons/
│       ├── assets/
│       │   ├── images/
│       │   ├── icons/
│       │   └── seed/
│       └── pubspec.yaml
│
└── README.md
```

---

## 4. Nguyên tắc thiết kế offline-first

Ứng dụng phải được thiết kế theo nguyên tắc:

> Mọi chức năng luyện tập cơ bản phải hoạt động được khi mất mạng, sau khi người dùng đã tải dữ liệu cần thiết ít nhất một lần.

Không nên xây dựng ứng dụng theo kiểu mỗi màn hình đều bắt buộc gọi API.

Luồng dữ liệu đúng:

```text
Giao diện
   │
   ▼
Repository
   │
   ├── Kiểm tra dữ liệu local
   │      └── Có dữ liệu: trả về ngay
   │
   └── Nếu có mạng: tải dữ liệu mới từ Django API
          └── Lưu local rồi trả về giao diện
```

Repository phải che giấu sự khác biệt giữa dữ liệu online và offline.

Ví dụ:

```dart
abstract class QuestionRepository {
  Future<List<Question>> getQuestions({
    required String subjectId,
    bool forceRefresh = false,
  });

  Future<void> downloadQuestionPackage(String packageId);

  Future<void> removeQuestionPackage(String packageId);
}
```

---

## 5. Dữ liệu cần lưu offline

### 5.1. Dữ liệu ứng dụng

Lưu bằng Cache Storage thông qua service worker:

- `index.html`.
- JavaScript đã biên dịch.
- Flutter Web engine.
- Fonts.
- Icons.
- CSS.
- Hình ảnh giao diện.
- File cấu hình cần thiết.

### 5.2. Dữ liệu nghiệp vụ

Lưu bằng IndexedDB:

```text
subjects
categories
question_packages
questions
answers
practice_sessions
exam_attempts
attempt_answers
sync_queue
app_settings
user_profile
download_metadata
```

### 5.3. Bảng hàng đợi đồng bộ

Nên có bảng `sync_queue`:

```text
id
entity_type
entity_id
action
payload_json
created_at
retry_count
last_error
status
```

Ví dụ:

```json
{
  "entity_type": "exam_attempt",
  "entity_id": "local-9f4c",
  "action": "submit",
  "payload_json": {
    "subject_id": 3,
    "score": 82,
    "started_at": "2026-07-29T12:00:00Z",
    "completed_at": "2026-07-29T12:45:00Z"
  },
  "status": "pending"
}
```

Khi có mạng, ứng dụng đọc các bản ghi `pending`, gửi lên Django API rồi chuyển trạng thái sang `completed`.

---

## 6. Phân loại chế độ sử dụng

### 6.1. Luyện tập offline

Có thể hỗ trợ đầy đủ:

- Chọn môn học.
- Chọn chủ đề.
- Tạo đề ngẫu nhiên từ dữ liệu đã tải.
- Làm bài.
- Xem đáp án.
- Xem giải thích.
- Đánh dấu câu hỏi.
- Lưu lịch sử luyện tập.
- Thống kê kết quả.
- Đồng bộ khi có mạng.

### 6.2. Thi chính thức

Không nên cho phép hoạt động hoàn toàn offline nếu yêu cầu chống gian lận hoặc quản lý chặt thời gian.

Thi chính thức nên:

- Yêu cầu có mạng khi bắt đầu.
- Server tạo đề thi.
- Server trả về mã phiên thi.
- Không gửi đáp án đúng xuống thiết bị.
- Ghi nhận thời điểm bắt đầu từ server.
- Tự động lưu câu trả lời định kỳ.
- Cho phép tiếp tục tạm thời khi mất mạng.
- Đồng bộ ngay khi có mạng trở lại.
- Nộp bài cuối cùng phải được server xác nhận.

Phân biệt rõ:

```text
Luyện tập: offline hoàn toàn
Thi chính thức: online ưu tiên, offline tạm thời
```

---

## 7. Xây dựng API Django

### 7.1. Cấu hình Django REST Framework

Trong `settings.py`:

```python
INSTALLED_APPS = [
    # Django apps
    "rest_framework",
    "rest_framework_simplejwt",
    "corsheaders",
    "exam_bank",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    # các middleware khác
]

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
}

CORS_ALLOWED_ORIGINS = [
    "https://ten-mien-pwa.example.com",
]
```

Khi phát triển local:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
]
```

Không nên sử dụng `CORS_ALLOW_ALL_ORIGINS = True` trong môi trường production.

### 7.2. API tối thiểu

```text
POST   /api/auth/login/
POST   /api/auth/refresh/
GET    /api/auth/me/

GET    /api/subjects/
GET    /api/categories/
GET    /api/question-packages/
GET    /api/question-packages/{id}/
GET    /api/question-packages/{id}/download/

POST   /api/practice/start/
POST   /api/practice/submit/

POST   /api/exams/start/
GET    /api/exams/{attempt_id}/
POST   /api/exams/{attempt_id}/autosave/
POST   /api/exams/{attempt_id}/submit/

GET    /api/results/
GET    /api/results/{id}/

POST   /api/sync/
GET    /api/sync/changes/?since=<timestamp>
```

### 7.3. API tải gói câu hỏi

Ví dụ:

```json
{
  "package_id": "ADC-2026-01",
  "version": 5,
  "subject": {
    "id": 1,
    "code": "ADC",
    "name": "Aerodrome Control"
  },
  "updated_at": "2026-07-29T10:00:00Z",
  "questions": [
    {
      "id": 1001,
      "code": "ADC-001",
      "content": "Nội dung câu hỏi",
      "question_type": "single_choice",
      "category_id": 10,
      "difficulty": "medium",
      "answers": [
        {
          "id": 1,
          "label": "A",
          "content": "Phương án A"
        },
        {
          "id": 2,
          "label": "B",
          "content": "Phương án B"
        }
      ],
      "correct_answer": ["B"],
      "explanation": "Giải thích đáp án",
      "reference": "Tài liệu tham chiếu"
    }
  ]
}
```

Gói dùng cho luyện tập có thể chứa đáp án đúng.

Gói dùng cho thi chính thức không được chứa:

```text
correct_answer
explanation
```

---

## 8. Xây dựng cơ sở dữ liệu local trên Flutter

Ví dụ định nghĩa bảng bằng Drift:

```dart
class LocalQuestions extends Table {
  IntColumn get id => integer()();
  TextColumn get code => text()();
  TextColumn get content => text()();
  TextColumn get questionType => text()();
  IntColumn get subjectId => integer()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get reference => text().nullable()();
  IntColumn get packageVersion => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

Bảng câu trả lời:

```dart
class LocalAnswers extends Table {
  IntColumn get id => integer()();
  IntColumn get questionId => integer()();
  TextColumn get label => text()();
  TextColumn get content => text()();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

Bảng phiên làm bài:

```dart
class LocalAttempts extends Table {
  TextColumn get id => text()();
  IntColumn get subjectId => integer()();
  TextColumn get mode => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant("pending"))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 9. Kiểm tra trạng thái mạng

Sử dụng `connectivity_plus` để phát hiện thay đổi kết nối:

```dart
final connectivity = Connectivity();

connectivity.onConnectivityChanged.listen((results) {
  final online = results.any(
    (result) => result != ConnectivityResult.none,
  );

  if (online) {
    syncService.processPendingItems();
  }
});
```

Lưu ý:

Có kết nối Wi-Fi không đồng nghĩa chắc chắn có Internet. Khi cần xác nhận, nên gọi API kiểm tra:

```text
GET /api/health/
```

Ví dụ phản hồi:

```json
{
  "status": "ok",
  "server_time": "2026-07-29T13:00:00Z"
}
```

---

## 10. Service Worker và cơ chế cache

Khi build Flutter Web, Flutter tạo service worker để cache tài nguyên ứng dụng.

Build:

```bash
flutter build web --release
```

Kết quả:

```text
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_bootstrap.js
├── manifest.json
├── icons/
└── assets/
```

Service worker có nhiệm vụ:

- Tải tài nguyên ứng dụng khi truy cập lần đầu.
- Lưu tài nguyên xuống cache.
- Phục vụ tài nguyên từ cache khi mất mạng.
- Tải phiên bản mới khi ứng dụng được cập nhật.

Không nên đưa toàn bộ ngân hàng câu hỏi lớn vào service worker cache. Ngân hàng câu hỏi nên tải riêng và lưu vào IndexedDB.

---

## 11. Cấu hình PWA

### 11.1. File `web/manifest.json`

Ví dụ:

```json
{
  "name": "ATC Exam",
  "short_name": "ATC Exam",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#123B5D",
  "description": "Ứng dụng luyện thi và quản lý ngân hàng câu hỏi ATC",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

### 11.2. Cấu hình iOS trong `web/index.html`

Thêm vào phần `<head>`:

```html
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="ATC Exam">

<link rel="apple-touch-icon" href="icons/Icon-192.png">
```

---

## 12. Luồng cài đặt lần đầu

### 12.1. Trên iPhone/iPad

1. Kết nối Internet.
2. Mở Safari.
3. Truy cập địa chỉ PWA.
4. Chờ ứng dụng tải xong.
5. Đăng nhập nếu cần.
6. Tải gói câu hỏi cần sử dụng offline.
7. Nhấn nút Chia sẻ.
8. Chọn **Thêm vào Màn hình chính**.
9. Chọn **Thêm**.
10. Mở ATC Exam từ biểu tượng trên màn hình chính.
11. Kiểm tra bằng cách bật chế độ máy bay và mở lại ứng dụng.

### 12.2. Trên Android

1. Kết nối Internet.
2. Mở Chrome.
3. Truy cập địa chỉ PWA.
4. Chọn **Cài đặt ứng dụng** hoặc **Thêm vào màn hình chính**.
5. Tải gói câu hỏi offline.
6. Tắt mạng để kiểm tra.

---

## 13. Luồng sử dụng offline

```text
Người dùng mở ATC Exam
        │
        ▼
Service Worker kiểm tra mạng
        │
        ├── Có mạng
        │     ├── mở ứng dụng từ cache
        │     ├── kiểm tra phiên bản mới
        │     └── đồng bộ dữ liệu
        │
        └── Không có mạng
              ├── mở giao diện từ cache
              ├── đọc câu hỏi từ IndexedDB
              ├── tạo bài luyện tập
              ├── lưu kết quả local
              └── thêm tác vụ vào sync_queue
```

---

## 14. Đồng bộ dữ liệu

### 14.1. Nguyên tắc

- Đồng bộ theo từng tác vụ.
- Mỗi tác vụ có ID duy nhất.
- Gửi nhiều lần không được tạo kết quả trùng.
- Server phải hỗ trợ idempotency.
- Nếu lỗi, tăng `retry_count`.
- Không xóa dữ liệu local trước khi server xác nhận thành công.

### 14.2. Ví dụ request đồng bộ

```json
{
  "client_id": "device-123",
  "operations": [
    {
      "operation_id": "op-001",
      "type": "submit_practice_attempt",
      "payload": {
        "local_attempt_id": "local-a123",
        "subject_id": 1,
        "score": 85,
        "answers": []
      }
    }
  ]
}
```

Phản hồi:

```json
{
  "results": [
    {
      "operation_id": "op-001",
      "status": "success",
      "server_id": 7788
    }
  ]
}
```

---

## 15. Quản lý phiên bản ngân hàng câu hỏi

Mỗi gói câu hỏi cần có:

```text
package_id
version
checksum
updated_at
minimum_app_version
```

Khi có mạng:

```text
Ứng dụng gửi version hiện tại
        │
        ▼
Server trả về version mới nhất
        │
        ├── Không thay đổi: không tải lại
        └── Có thay đổi: tải delta hoặc toàn bộ gói
```

Ví dụ metadata:

```json
{
  "package_id": "ADC-2026-01",
  "current_version": 5,
  "latest_version": 6,
  "download_required": true,
  "checksum": "sha256:..."
}
```

Sau khi tải xong:

1. Kiểm tra checksum.
2. Ghi dữ liệu vào transaction.
3. Chỉ thay version khi transaction thành công.
4. Không để bộ dữ liệu ở trạng thái nửa cũ, nửa mới.

---

## 16. Bảo mật

### 16.1. Không lưu dữ liệu nhạy cảm không cần thiết

Không lưu:

- Mật khẩu.
- Khóa bí mật của server.
- Chuỗi kết nối PostgreSQL.
- Certificate.
- Token không giới hạn thời gian.

### 16.2. Token

- Access token có thời hạn ngắn.
- Refresh token có thời hạn dài hơn.
- Khi offline, cho phép dùng dữ liệu đã tải nếu chính sách cho phép.
- Khi token hết hạn và không có mạng, không nên xóa toàn bộ dữ liệu offline ngay.
- Khi có mạng, yêu cầu đăng nhập lại nếu refresh token không còn hợp lệ.

### 16.3. Dữ liệu câu hỏi

Đối với luyện tập:

- Có thể lưu đáp án đúng local.

Đối với thi chính thức:

- Không lưu sẵn đáp án đúng.
- Không tải toàn bộ ngân hàng câu hỏi.
- Chỉ tải nội dung đề thi được cấp.
- Server chấm bài.

---

## 17. Build ứng dụng Flutter Web

### 17.1. Kiểm tra môi trường

```bash
flutter doctor
flutter config --enable-web
flutter devices
```

### 17.2. Chạy thử

```bash
cd flutter
flutter pub get
flutter run -d chrome
```

### 17.3. Build production

```bash
flutter build web --release
```

Nếu triển khai tại đường dẫn con:

```bash
flutter build web --release --base-href "/atc-exam/"
```

Ví dụ:

```text
https://example.com/atc-exam/
```

thì `--base-href` phải đúng là:

```text
/atc-exam/
```

---

## 18. Chạy thử offline trên Windows

Không mở trực tiếp bằng `file://`.

Sau khi build:

```bash
cd build/web
python -m http.server 8080
```

Truy cập:

```text
http://localhost:8080
```

Các bước kiểm tra:

1. Mở ứng dụng khi có mạng.
2. Mở DevTools.
3. Chọn tab Application.
4. Kiểm tra Service Workers.
5. Kiểm tra Cache Storage.
6. Kiểm tra IndexedDB.
7. Chọn Network → Offline.
8. Reload ứng dụng.
9. Thử làm bài và lưu kết quả.
10. Bật mạng lại và kiểm tra đồng bộ.

---

## 19. Triển khai miễn phí

Có thể sử dụng:

- Cloudflare Pages.
- Firebase Hosting.
- GitHub Pages.
- Netlify.
- Vercel.

Khuyến nghị:

- Flutter PWA: Cloudflare Pages hoặc Firebase Hosting.
- Django API: máy chủ riêng, Render, Railway, Fly.io hoặc hạ tầng nội bộ.
- Production cần HTTPS.

### 19.1. Triển khai lên Cloudflare Pages

Thiết lập:

```text
Build command:
flutter build web --release

Output directory:
build/web
```

Nếu Cloudflare không có Flutter sẵn, nên dùng GitHub Actions để build rồi deploy thư mục `build/web`.

### 19.2. Triển khai bằng Firebase Hosting

Cài Firebase CLI:

```bash
npm install -g firebase-tools
firebase login
```

Khởi tạo:

```bash
firebase init hosting
```

Chọn thư mục public:

```text
build/web
```

Build và deploy:

```bash
flutter build web --release
firebase deploy
```

---

## 20. GitHub Actions build PWA

Tạo file:

```text
.github/workflows/build-pwa.yml
```

Nội dung:

```yaml
name: Build ATC Exam PWA

on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Install Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        working-directory: flutter
        run: flutter pub get

      - name: Analyze
        working-directory: flutter
        run: flutter analyze

      - name: Test
        working-directory: flutter
        run: flutter test

      - name: Build web
        working-directory: flutter
        run: flutter build web --release

      - name: Upload PWA artifact
        uses: actions/upload-artifact@v4
        with:
          name: atc-exam-pwa
          path: flutter/build/web
          retention-days: 14
```

Workflow này:

- Không cần macOS runner.
- Không cần Apple Developer Account.
- Không cần ký ứng dụng.
- Tạo bản PWA chạy được trên iOS, Android và máy tính.

---

## 21. Kiểm thử bắt buộc

### 21.1. Kiểm thử lần đầu online

- Mở ứng dụng lần đầu.
- Tải đầy đủ giao diện.
- Đăng nhập.
- Tải gói câu hỏi.
- Cài vào màn hình chính.
- Kiểm tra dữ liệu IndexedDB.
- Kiểm tra service worker active.

### 21.2. Kiểm thử offline

- Bật chế độ máy bay.
- Mở ứng dụng từ màn hình chính.
- Chọn môn học đã tải.
- Tạo bài luyện tập.
- Làm bài.
- Xem đáp án và giải thích.
- Lưu kết quả.
- Đóng ứng dụng và mở lại.
- Kiểm tra bài làm vẫn còn.

### 21.3. Kiểm thử đồng bộ lại

- Bật mạng.
- Mở ứng dụng.
- Kiểm tra hàng đợi đồng bộ.
- Kiểm tra kết quả xuất hiện trên Django.
- Kiểm tra không phát sinh bản ghi trùng.
- Kiểm tra lỗi mạng giữa chừng.

### 21.4. Kiểm thử cập nhật ứng dụng

- Triển khai phiên bản PWA mới.
- Mở bản cũ.
- Kiểm tra ứng dụng phát hiện bản mới.
- Cho người dùng chủ động tải lại.
- Không làm mất bài đang làm.
- Không xóa dữ liệu IndexedDB ngoài ý muốn.

---

## 22. Các màn hình nên có

```text
1. Splash / kiểm tra khởi tạo
2. Đăng nhập
3. Trang chủ
4. Danh sách môn học
5. Danh sách gói câu hỏi
6. Quản lý tải offline
7. Tạo bài luyện tập
8. Màn hình làm bài
9. Màn hình kết quả
10. Xem giải thích
11. Lịch sử làm bài
12. Trạng thái đồng bộ
13. Cài đặt
14. Thông tin phiên bản
15. Hướng dẫn cài PWA
```

Trang quản lý tải offline cần hiển thị:

```text
Tên gói câu hỏi
Phiên bản
Dung lượng
Ngày cập nhật
Trạng thái đã tải/chưa tải
Nút tải
Nút cập nhật
Nút xóa
```

---

## 23. Xử lý cập nhật PWA

Khi phát hiện phiên bản mới, không nên tự reload khi người dùng đang làm bài.

Nên hiển thị:

```text
Đã có phiên bản ATC Exam mới.
Bản cập nhật sẽ được áp dụng sau khi bạn hoàn thành bài hiện tại.
```

Quy tắc:

- Không reload giữa lúc thi.
- Không xóa cache trước khi bản mới tải xong.
- Không xóa IndexedDB khi nâng phiên bản thông thường.
- Thực hiện migration database local nếu cấu trúc thay đổi.

---

## 24. Lộ trình phát triển đề xuất

### Giai đoạn 1: PWA offline cơ bản

- Tạo Flutter Web project.
- Thiết kế giao diện responsive.
- Cấu hình manifest.
- Build PWA.
- Lưu câu hỏi mẫu vào IndexedDB.
- Làm bài offline.
- Lưu kết quả local.
- Kiểm tra trên iPhone và Android.

### Giai đoạn 2: Kết nối Django API

- Bổ sung Django REST Framework.
- Xây dựng API đăng nhập.
- API danh mục môn học.
- API tải gói câu hỏi.
- API đồng bộ kết quả.
- Quản lý phiên bản dữ liệu.

### Giai đoạn 3: Hoàn thiện đồng bộ

- `sync_queue`.
- Tự động retry.
- Kiểm tra xung đột.
- Nhật ký đồng bộ.
- Đồng bộ thay đổi theo timestamp.
- Xử lý dữ liệu trùng.

### Giai đoạn 4: Thi chính thức

- Server tạo đề.
- Quản lý phiên thi.
- Autosave.
- Đồng hồ server.
- Nộp bài.
- Audit log.
- Chính sách mất mạng.

### Giai đoạn 5: Mở rộng native

Khi cần:

- Build APK Android.
- Phát hành Google Play.
- Mua Apple Developer Account.
- Build IPA.
- Phát hành TestFlight/App Store.

Phần lớn source Flutter, models, repository và API có thể tiếp tục sử dụng.

---

## 25. Phương án triển khai khuyến nghị

```text
Frontend:
Flutter Web / PWA

Backend:
Django REST Framework

Database server:
PostgreSQL

Database offline:
IndexedDB thông qua Drift

Hosting PWA:
Cloudflare Pages hoặc Firebase Hosting

API:
HTTPS

Build:
GitHub Actions Ubuntu Runner

Cài đặt iPhone:
Safari → Chia sẻ → Thêm vào Màn hình chính

Cài đặt Android:
Chrome → Cài đặt ứng dụng / Thêm vào màn hình chính
```

---

## 26. Kết luận

ATC EXAM nên được phát triển theo hướng:

> **Flutter Web PWA + Django REST API + IndexedDB offline-first.**

Ứng dụng được tải lần đầu qua Internet, sau đó service worker và IndexedDB cho phép người dùng mở ứng dụng, làm bài và lưu kết quả khi không có mạng.

Khi kết nối Internet trở lại, ứng dụng đồng bộ các kết quả chưa gửi và kiểm tra phiên bản ngân hàng câu hỏi mới.

Phương án này đáp ứng:

- Một codebase chạy trên iOS, Android và máy tính.
- Không cần ký ứng dụng iOS.
- Không cần MacBook.
- Không cần Apple Developer Account.
- Có thể dùng hosting miễn phí.
- Hỗ trợ luyện tập offline.
- Có khả năng mở rộng thành ứng dụng native về sau.
