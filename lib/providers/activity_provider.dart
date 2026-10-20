import 'package:flutter/foundation.dart';

import '../helpers/database_helper.dart';
import '../models/activity.dart';
import '../models/announcement.dart';
import '../models/registration.dart';
import '../models/student.dart';

// รายการกิจกรรม การลงทะเบียน และการยกเลิก ฝั่งนิสิต (R1)
class ActivityProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<Activity> activities = [];
  Map<String, int> registeredCount = {}; // id กิจกรรม : จำนวนคนที่ลงทะเบียน
  List<String> myActivityIds = []; // กิจกรรมที่นิสิตคนนี้ลงทะเบียนไว้
  String filter = 'ทั้งหมด'; // 'ทั้งหมด' 'จิตอาสา' หรือ 'กิจกรรมคณะ'

  Future<void> loadActivities(String studentId) async {
    activities = await db.getActivities();

    registeredCount = {};
    for (final a in activities) {
      registeredCount[a.id] = await db.countRegistrations(a.id);
    }

    final myRegistrations = await db.getRegistrationsOfStudent(studentId);
    myActivityIds = myRegistrations.map((r) => r.activityId).toList();

    notifyListeners();
  }

  void setFilter(String newFilter) {
    filter = newFilter;
    notifyListeners();
  }

  // กิจกรรมที่ยังไม่จบ และตรงกับตัวกรอง ใช้ในหน้าแรก
  List<Activity> get openActivities {
    return activities.where((a) {
      if (a.isPast()) return false;
      if (filter == 'ทั้งหมด') return true;
      return a.kind == filter;
    }).toList();
  }

  // กิจกรรมที่ลงทะเบียนไว้ ใช้ในหน้ากิจกรรมของฉัน
  List<Activity> get myActivities {
    return activities.where((a) => myActivityIds.contains(a.id)).toList();
  }

  Activity? findById(String id) {
    for (final a in activities) {
      if (a.id == id) return a;
    }
    return null;
  }

  bool isRegistered(String activityId) => myActivityIds.contains(activityId);

  int seatsLeft(Activity a) => a.capacity - (registeredCount[a.id] ?? 0);

  bool isFull(Activity a) => seatsLeft(a) <= 0;

  // ลงทะเบียน คืนข้อความผิดพลาด หรือ null ถ้าสำเร็จ
  Future<String?> register(Activity a, Student student) async {
    // เช็คจากฐานข้อมูลอีกครั้ง เผื่อมีคนลงทะเบียนเต็มไปก่อน
    final count = await db.countRegistrations(a.id);
    if (count >= a.capacity) {
      return 'กิจกรรมนี้เต็มแล้ว';
    }
    await db.insertRegistration(Registration(
      activityId: a.id,
      studentId: student.studentId,
      studentName: student.name,
      faculty: student.faculty,
      registeredAt: DateTime.now(),
    ));
    await loadActivities(student.studentId);
    return null;
  }

  // ยกเลิกได้ก่อนกิจกรรมเริ่ม ที่นั่งจะคืนทันที
  Future<String?> cancel(Activity a, Student student) async {
    if (DateTime.now().isAfter(a.startAt)) {
      return 'กิจกรรมเริ่มแล้ว ยกเลิกไม่ได้';
    }
    await db.deleteRegistration(a.id, student.studentId);
    await loadActivities(student.studentId);
    return null;
  }

  Future<List<Announcement>> getAnnouncements(String activityId) {
    return db.getAnnouncements(activityId);
  }
}
