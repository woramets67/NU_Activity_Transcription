import 'package:flutter/foundation.dart';

import '../helpers/database_helper.dart';
import '../models/activity.dart';
import '../models/announcement.dart';
import '../models/registration.dart';
import '../models/student.dart';

// Student activities
class ActivityProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<Activity> activities = [];
  Map<String, int> registeredCount = {};
  List<String> myActivityIds = [];
  String filter = 'ทั้งหมด';
  String searchText = '';

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

  void setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  List<Activity> get openActivities {
    return activities.where((a) {
      if (a.isPast()) return false;
      if (!a.title.toLowerCase().contains(searchText.toLowerCase())) return false;
      if (filter == 'ทั้งหมด') return true;
      return a.kind == filter;
    }).toList();
  }

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

  Future<String?> register(Activity a, Student student) async {
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
