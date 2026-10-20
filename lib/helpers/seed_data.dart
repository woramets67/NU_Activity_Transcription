import '../models/activity.dart';
import '../models/registration.dart';
import '../utils/constants.dart';

// ข้อมูลตัวอย่างที่ใส่ลงฐานข้อมูลตอนเปิดแอพครั้งแรก
// ทุกเครื่องได้ id ชุดเดียวกัน QR จึงสแกนข้ามเครื่องได้

// กิจกรรมนี้จะถูกเลื่อนเวลาให้ "กำลังจัดอยู่" ทุกครั้งที่เปิดแอพ ไว้สาธิตการสแกน
const String demoActivityId = 'a-blood';

// หน่วยงานและรหัสสำหรับเข้าโหมดผู้คุม
const Map<String, String> seedOrgs = {
  'NUVOL26': 'ชมรมอาสาพัฒนา มน.',
  'SCI2569': 'สโมสรนิสิตคณะวิทยาศาสตร์',
  'NUSA69': 'กองกิจการนิสิต',
};

// สร้างวันเวลา โดยนับจากวันนี้ไป day วัน
DateTime _day(int day, int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + day, hour);
}

List<Activity> seedActivities() {
  final now = DateTime.now();
  return [
    Activity(
      id: demoActivityId,
      title: 'จิตอาสางานบริจาคโลหิต ครั้งที่ 4/2569',
      kind: kVolunteer,
      orgCode: 'NUVOL26',
      orgName: seedOrgs['NUVOL26']!,
      startAt: now.subtract(const Duration(hours: 1)),
      endAt: now.add(const Duration(hours: 4)),
      place: 'หอประชุมมหาวิทยาลัยนเรศวร',
      hours: 4,
      capacity: 40,
      detail: 'ช่วยงานหน่วยรับบริจาคโลหิตร่วมกับสภากาชาดไทย ดูแลจุดลงทะเบียน แจกน้ำและขนมให้ผู้บริจาค',
      poster: 'assets/posters/blood.jpg',
    ),
    Activity(
      id: 'a-river',
      title: 'เก็บขยะริมแม่น้ำน่าน หน้าวัดใหญ่',
      kind: kVolunteer,
      orgCode: 'NUVOL26',
      orgName: seedOrgs['NUVOL26']!,
      startAt: _day(1, 7),
      endAt: _day(1, 11),
      place: 'ริมแม่น้ำน่าน หน้าวัดพระศรีรัตนมหาธาตุ',
      hours: 4,
      capacity: 30,
      detail: 'เก็บขยะและคัดแยกขยะริมฝั่งแม่น้ำ เตรียมถุงมือและหมวกมาเอง มีน้ำดื่มให้',
      poster: 'assets/posters/river.jpg',
    ),
    Activity(
      id: 'a-teach',
      title: 'สอนการบ้านน้อง โรงเรียนบ้านท่าโพธิ์',
      kind: kVolunteer,
      orgCode: 'NUVOL26',
      orgName: seedOrgs['NUVOL26']!,
      startAt: _day(3, 13),
      endAt: _day(3, 16),
      place: 'โรงเรียนบ้านท่าโพธิ์',
      hours: 3,
      capacity: 12,
      detail: 'สอนการบ้านคณิตศาสตร์และภาษาอังกฤษให้นักเรียนชั้นประถม',
      poster: 'assets/posters/teach.jpg',
    ),
    Activity(
      id: 'a-tree',
      title: 'ปลูกป่าต้นน้ำ เขื่อนแควน้อยบำรุงแดน',
      kind: kVolunteer,
      orgCode: 'NUSA69',
      orgName: seedOrgs['NUSA69']!,
      startAt: _day(6, 6),
      endAt: _day(6, 16),
      place: 'เขื่อนแควน้อยบำรุงแดน',
      hours: 8,
      capacity: 60,
      detail: 'เดินทางด้วยรถมหาวิทยาลัย ออกจากหน้าอาคารกองกิจการนิสิต 06:00 น.',
      poster: 'assets/posters/tree.jpg',
    ),
    Activity(
      id: 'a-grad',
      title: 'จิตอาสางานพิธีพระราชทานปริญญาบัตร',
      kind: kVolunteer,
      orgCode: 'NUSA69',
      orgName: seedOrgs['NUSA69']!,
      startAt: _day(10, 6),
      endAt: _day(10, 18),
      place: 'หอประชุมมหาวิทยาลัยนเรศวร',
      hours: 10,
      capacity: 3,
      detail: 'ช่วยจัดแถวบัณฑิตและดูแลจุดลงทะเบียน รับจำนวนจำกัด',
      poster: 'assets/posters/grad.jpg',
    ),
    Activity(
      id: 'a-wai',
      title: 'พิธีไหว้ครูคณะวิทยาศาสตร์ ประจำปีการศึกษา 2569',
      kind: kFacultyActivity,
      orgCode: 'SCI2569',
      orgName: seedOrgs['SCI2569']!,
      startAt: _day(2, 9),
      endAt: _day(2, 12),
      place: 'อาคารเรียนรวมคณะวิทยาศาสตร์',
      hours: 3,
      capacity: 200,
      detail: 'นิสิตชั้นปีที่ 1 ถึง 4 แต่งกายชุดนิสิตถูกระเบียบ',
      poster: 'assets/posters/wai.jpg',
    ),
    Activity(
      id: 'a-open',
      title: 'Open House คณะวิทยาศาสตร์ ผู้ช่วยประจำบูธ',
      kind: kFacultyActivity,
      orgCode: 'SCI2569',
      orgName: seedOrgs['SCI2569']!,
      startAt: _day(5, 8),
      endAt: _day(5, 16),
      place: 'อาคารเรียนรวมคณะวิทยาศาสตร์',
      hours: 6,
      capacity: 25,
      detail: 'ช่วยประจำบูธแนะนำหลักสูตรให้นักเรียนมัธยม',
      poster: 'assets/posters/openhouse.jpg',
    ),
    Activity(
      id: 'a-dorm',
      title: 'Big Cleaning Day หอพักนิสิต',
      kind: kVolunteer,
      orgCode: 'NUVOL26',
      orgName: seedOrgs['NUVOL26']!,
      startAt: _day(-5, 8),
      endAt: _day(-5, 12),
      place: 'หอพักนิสิต มน.',
      hours: 4,
      capacity: 50,
      detail: 'ทำความสะอาดพื้นที่ส่วนกลางของหอพัก',
      poster: 'assets/posters/dorm.jpg',
    ),
  ];
}

// นิสิตตัวอย่าง [รหัส, ชื่อ, คณะ]
const List<List<String>> _people = [
  ['67310011', 'กมลชนก ศรีสุข', 'วิทยาศาสตร์'],
  ['67310024', 'ณัฐวุฒิ แก้วมณี', 'วิศวกรรมศาสตร์'],
  ['67310037', 'ปิยธิดา ทองดี', 'มนุษยศาสตร์'],
  ['67310040', 'ธนกร บุญมา', 'วิทยาศาสตร์'],
  ['67310053', 'ศิริพร จันทร์เพ็ญ', 'พยาบาลศาสตร์'],
  ['67310066', 'อนุชา พรหมมา', 'เกษตรศาสตร์ ทรัพยากรธรรมชาติและสิ่งแวดล้อม'],
  ['67310079', 'วรรณิศา ใจดี', 'ศึกษาศาสตร์'],
  ['67310082', 'ภาณุพงศ์ สายทอง', 'วิทยาศาสตร์'],
  ['67310095', 'ชนิดา มีสุข', 'สหเวชศาสตร์'],
  ['67310108', 'กิตติศักดิ์ อินทร์แก้ว', 'นิติศาสตร์'],
];

// ให้นิสิตตัวอย่างลงทะเบียนไว้ก่อน รายชื่อฝั่งผู้คุมจะได้ไม่ว่าง
List<Registration> seedRegistrations() {
  // กิจกรรม : จำนวนคนที่ลงทะเบียนไว้แล้ว
  const plan = {demoActivityId: 10, 'a-river': 6, 'a-wai': 8, 'a-grad': 3, 'a-dorm': 5};

  final list = <Registration>[];
  plan.forEach((activityId, count) {
    for (int i = 0; i < count; i++) {
      list.add(Registration(
        activityId: activityId,
        studentId: _people[i][0],
        studentName: _people[i][1],
        faculty: _people[i][2],
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      ));
    }
  });
  return list;
}
