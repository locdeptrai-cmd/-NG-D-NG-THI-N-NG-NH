# HUONG DAN SU DUNG HE THONG THI THU (CAP NHAT 2026-06-02)

Tai lieu nay huong dan van hanh he thong theo 4 nhom cong viec:
1) Tao user theo tung lop tinh nang
2) Import/quan tri cau hoi + dap an
3) Duyet cau hoi va mo thi thu
4) Dua cau hoi vao de thi chinh thuc

---

## 1. Trang va luong su dung

- Dang nhap: `http://127.0.0.1:8000/login/`
- Dashboard quan tri: `http://127.0.0.1:8000/management/`
- Django Admin: `http://127.0.0.1:8000/admin/`
- Trang thi hoc vien: `http://127.0.0.1:8000/start/`

Dieu huong:
- `admin`, `endteacher` -> vao `/management/`
- `enduser` -> vao `/start/`

---

## 2. Tai khoan mac dinh va vai tro

### 2.1. He thong
- `admin` (superuser): quan tri toan bo

### 2.2. Giao vien/quan tri ngan hang cau hoi
- `endteacher`
- Quyen: them/sua/xoa/xem `Question`, `Answer`, `Category`, `Subject`, `Document`
- Co `is_staff=True`, thuoc group `question_teachers`

### 2.3. Hoc vien thi
- `enduser`
- Quyen: vao lam bai thi, xem ket qua

Mat khau mac dinh hien tai:
- `123456` (khuyen nghi doi ngay sau ban giao)

---

## 3. Tao user theo tung lop tinh nang

### Cach A - Bang Django Admin
1. Vao `/admin/` bang `admin`
2. `Users` -> `Add user`
3. Gan theo vai tro:
   - Hoc vien: `is_staff=False`, role=`enduser`
   - Giao vien: `is_staff=True`, them group `question_teachers`, role=`endteacher`

### Cach B - Bang shell
```bash
python manage.py shell --settings=config.sqlite_settings
```

```python
from exam_bank.models import User, Role
from django.contrib.auth.models import Group

role_user = Role.objects.get(code='enduser')
role_teacher = Role.objects.get(code='endteacher')
g = Group.objects.get(name='question_teachers')

u = User.objects.create_user(username='hocvien01', password='123456')
u.role = role_user
u.is_staff = False
u.save()

t = User.objects.create_user(username='giaovien01', password='123456')
t.role = role_teacher
t.is_staff = True
t.save()
t.groups.add(g)
```

---

## 4. Import cau hoi theo dung mau file dinh kem

Dashboard da ho tro format cac file:
- `8. LTCS_TSN APP RADA_2022.xlsx`
- `9. LTCS_TSN APP NON Rada 2022.xlsx`
- `10. LTCS TWR GCU TSN.xlsx`

### 4.1. Form import tren `/management/`
1. Dang nhap `endteacher`
2. Muc `Form import theo mau file de thi`
3. Chon `Nhom mac dinh` (APS/ADC/ACC HAN/SUP)
4. Chon file `.xlsx/.xlsm/.csv`
5. Bam `Import ngay`

### 4.2. Mapping cot Excel -> DB (dang render tren dashboard)
- `Loại kiến thức (Chuyên môn/nghiệp vụ)` -> `category`
- `TT` -> so thu tu nguon
- `QUESTION` -> `question.content`
- `A/B/C/D` -> dap an
- `ANS` -> dap an dung
  - Ho tro `1/2/3/4` va `A/B/C/D`
- `rating` / `RATING` -> nhom `APS/ADC/ACC HAN/SUP` (khong bat buoc; co the nhieu nhom)

Luu y:
- Cot `rating` khong bat buoc.
- Neu dong co `rating` hop le (APS/ADC/ACC HAN/SUP), sau khi phan loai kien thuc he thong tu do cau hoi vao DB dung nhom do.
- SUP co the trung voi APS/ADC: ghi nhieu gia tri trong 1 o, VD `SUP,APS`, `ADC/SUP`, `APS ADC SUP`.
  He thong tao ban ghi rieng cho tung nhom (cung noi dung cau hoi/dap an).
- Nhom `ACC HAN` dung cho bo cau hoi Area/Approach Control (rating=`ACC HAN`; alias `ACC`/`ACC_HAN`).
- Neu `rating` thieu/sai, he thong fallback theo nhom ban chon tren form (hoac suy ra tu ten file).
- Sau import, cau hoi vao `draft`.

---

## 5. Duyet cau hoi de mo thi thu

### 5.1. Duyet nhanh theo nhom (moi them)
Tren `/management/`, muc `Duyet nhanh cau hoi thi thu`:
1. Chon nhom `APS`, `ADC`, `ACC HAN` hoac `SUP`
2. Bam `Duyet nhanh theo nhom`
3. He thong chuyen cau `draft/review` (co dap an) -> `approved`

### 5.2. Duyet thu cong trong Admin
- Vao `/admin/exam_bank/question/`
- Loc theo `status`
- Chinh `status=approved` cho cau dat yeu cau

---

## 6. Co che thi thu hien tai (da hoat dong)

Khi `enduser` vao `/start/` va chon APS/ADC/ACC HAN/SUP:
- He thong tu dong rut **ngau nhien 50 cau**
- Dieu kien cau hoi:
  - `status=approved`
  - `is_locked_for_official_exam=False`
- Tao 1 lan thi (attempt), nop bai, cham diem tu dong, xem chi tiet dung/sai

Neu bao loi chua du 50 cau:
- Vao `/management/` -> `Duyet nhanh theo nhom`
- Hoac import them cau hoi

---

## 7. Them/sua/xoa cau hoi va dap an

1. Dang nhap `endteacher` vao `/admin/`
2. Vao `Questions`
3. Them/sua/xoa cau hoi
4. Trong moi cau:
   - Nhap noi dung
   - Chon `subject`, `category`, `topic`
   - Them `Answers` A/B/C/D
   - Danh dau `is_correct`

Metadata nen quan ly chuan:
- `subject` (APS/ADC/ACC HAN/SUP)
- `category`
- `topic`
- `difficulty`
- `reference_document`
- `status`
- `is_locked_for_official_exam`

---

## 8. Dua cau hoi vao de thi chinh thuc

Quy trinh khuyen nghi:
1. Chot bo cau `approved`
2. Tao de chinh thuc theo danh sach duyet
3. Danh dau cau da dua vao ky thi:
   - `is_locked_for_official_exam=True`
   - (tuy quy trinh) `status=locked`
4. Luu truy vet qua `QuestionVersion` va `AuditLog`

Tac dung:
- Cau da lock se khong bi rut vao de thi thu ngau nhien

---

## 9. Huong dan chay app

### 9.1. Chay web app noi bo
```bash
python manage.py runserver --settings=config.sqlite_settings
```

Sau khi server chay, mo trinh duyet:
- `http://127.0.0.1:8000/login/`
- `http://127.0.0.1:8000/management/`
- `http://127.0.0.1:8000/admin/`

Tao superuser:
```bash
python manage.py createsuperuser --settings=config.sqlite_settings
```

Import CLI:
```bash
python manage.py import_questions "8. LTCS_TSN APP RADA_2022.xlsx" --subject APS --settings=config.sqlite_settings
python manage.py import_questions "9. LTCS_TSN APP NON Rada 2022.xlsx" --subject APS --settings=config.sqlite_settings
python manage.py import_questions "10. LTCS TWR GCU TSN.xlsx" --subject ADC --settings=config.sqlite_settings
```

### 9.2. Chay ban Windows offline tu ma nguon
```bash
cd offline/windows
python offline_exam.py
```

Ban nay doc DB offline tai:
- `offline/data/offline_exam.db`

### 9.3. Chay ban mobile offline tu ma nguon
Yeu cau da cai Flutter SDK.

```bash
cd offline/mobile_flutter
flutter pub get
flutter run
```

Ban mobile doc DB offline tu:
- `offline/mobile_flutter/assets/offline_exam.db`

---

## 10. Dong goi 2 phien ban offline thanh file cai dat duy nhat

### 10.1. Tao lai DB offline truoc khi dong goi
Khi ngan hang cau hoi web thay doi, tao lai DB offline:

```bash
python offline/build_offline_db.py
```

DB output:
- `offline/data/offline_exam.db`

### 10.2. Dong goi Windows thanh mot file `.exe`
Chay:

```bash
offline/windows/build_exe.bat
```

File output:
- `offline/dist/ATC_Offline_Exam_Windows.exe`

File `.exe` nay da nhung san DB, nguoi dung Windows chi can chay dung file nay de su dung, khong can mo web va khong can cai database rieng.

### 10.3. Dong goi Android thanh mot file `.apk`
Yeu cau da cai Flutter SDK va Android toolchain.

```bash
cd offline/mobile_flutter
build_android_one_file.bat
```

File output:
- `offline/dist/ATC_Offline_Mobile_Android.apk`

Nguoi dung Android cai truc tiep file `.apk` nay.

### 10.4. Dong goi iOS thanh mot file `.ipa`
Yeu cau bat buoc:
- May macOS
- Xcode
- Apple Developer signing/certificate/provisioning profile
- Flutter SDK

Tren macOS:

```bash
cd offline/mobile_flutter
chmod +x build_ios_one_file.sh
./build_ios_one_file.sh
```

File output:
- `offline/dist/ATC_Offline_Mobile_iOS.ipa`

Luu y: iOS khong cho cai app hop le neu khong co signing cua Apple. Do do file `.ipa` phai duoc build tren macOS voi cau hinh signing dung.

---

## 11. Checklist truoc khi cho thi

- Moi nhom co >= 50 cau `approved`
- Moi cau co dap an hop le va dap an dung
- Cac cau khong dung cho thi thu da duoc `lock`
- Tai khoan thi thu (`enduser`) dang hoat dong
- Tai khoan giao vien (`endteacher`) co quyen cap nhat ngan hang
