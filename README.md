# NU Activity Transcript (Flutter)

แอพเก็บชั่วโมงจิตอาสาและกิจกรรมคณะของนิสิต มหาวิทยาลัยนเรศวร โครงงานวิชา 273387 Mobile Application Development หน่วยงานเจ้าของโจทย์คือกองกิจการนิสิต

## ความต้องการ

| ข้อ | ความต้องการ | ตรวจที่ |
| --- | --- | --- |
| R1 | นิสิตเห็นกิจกรรมทั้งหมดในที่เดียวและลงทะเบียนเองได้ | หน้าแรก, หน้ากิจกรรม |
| R2 | ผู้คุมยืนยันการเข้าร่วมด้วย QR ที่เปลี่ยนทุก 10 วินาที ตรวจอายุ QR 15 วินาที สแกนซ้ำ และระยะ 200 ม. | หน้า QR ผู้คุม, หน้าสแกน |
| R3 | นิสิตดูชั่วโมงสะสมแยกประเภทได้ | แท็บ Transcript |
| R4 | ผู้คุมค้นหา เพิ่ม ลบชื่อ และ export Excel | หน้าจัดการกิจกรรม |
| R5 | ประกาศจากผู้คุมขึ้นในกล่องแจ้งเตือนพร้อมตัวเลขยังไม่อ่าน | หน้าจัดการกิจกรรม, แท็บแจ้งเตือน |

## วิธีรัน

```bash
flutter pub get
flutter run
```

ทดสอบบน Android (ต้องมีกล้องและ GPS) รหัสหน่วยงานสำหรับทดลองเข้าโหมดผู้คุม: `NUVOL26`, `SCI2569`, `NUSA69`

สาธิต R2 ข้ามเครื่อง: เครื่อง A เข้าโหมดผู้คุม `NUVOL26` เปิดกิจกรรม "จิตอาสางานบริจาคโลหิต" แล้วกด "เปิด QR รับชั่วโมง" เครื่อง B สมัครนิสิต ลงทะเบียนกิจกรรมเดียวกัน แล้วกดปุ่มสแกนตรงกลางแถบล่าง

```bash
flutter analyze
flutter test
```

## โครงสร้าง

```
lib/
  main.dart           MultiProvider + MaterialApp
  app/                routes (onGenerateRoute) และ theme
  models/             class ข้อมูล มี toMap / fromMap
  helpers/            DatabaseHelper (SQLite ทุกตาราง) และข้อมูลตัวอย่าง
  providers/          ChangeNotifier ของแต่ละส่วน
  services/           QR, GPS, ตรวจการรับชั่วโมง, Excel
  screens/student/    หน้าจอนิสิต
  screens/supervisor/ หน้าจอผู้คุม
  widgets/            widget ที่ใช้ซ้ำ
  utils/              ค่าคงที่ วันที่ไทย validator
test/                 unit test และ widget test
```

หน้าจอไม่เรียก `DatabaseHelper` ตรง ให้เรียกผ่าน Provider (แบบบทที่ 15)

## หน้าที่ของสมาชิก

| สมาชิก | ขอบเขตงาน | ไฟล์หลัก |
| --- | --- | --- |
| คนที่ 1 | โครงสร้างแอพ ฐานข้อมูล และระบบสมาชิก | `main.dart`, `app/`, `models/`, `helpers/`, `utils/`, `auth_provider`, `credit_provider`, `notice_provider`, welcome, student_shell, profile, inbox |
| คนที่ 2 | สแกน QR Code และตรวจ GPS | `qr_service`, `location_service`, `claim_service`, scan, claim_result, qr_presenter |
| คนที่ 3 | จัดการกิจกรรมและส่งออกรายชื่อเป็น Excel (ฝั่งผู้คุม) | `supervisor_provider`, `excel_export_service`, sup_login, sup_home, activity_editor, manage |
| คนที่ 4 | แสดงและลงทะเบียนกิจกรรม (ฝั่งนิสิต) | `activity_provider`, `activity_card`, home, activity_detail, mine |

## ข้อจำกัดที่รู้อยู่

- ข้อมูลเก็บใน SQLite ของแต่ละเครื่อง เมื่อนิสิตสแกนจากมือถือตัวเอง รายชื่อบนเครื่องผู้คุมไม่อัปเดตตาม (ผู้คุมกดให้ชั่วโมงเองได้)
- กุญแจเซ็น QR อยู่ในแอพ ใช้ได้สำหรับต้นแบบเท่านั้น
- ยังไม่มี push notification ตอนปิดแอพ แจ้งเตือนอยู่ในกล่องแจ้งเตือนของแอพ
