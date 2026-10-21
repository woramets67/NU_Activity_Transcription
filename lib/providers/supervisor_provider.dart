import 'package:flutter/foundation.dart';

import '../helpers/database_helper.dart';
import '../models/activity.dart';
import '../models/announcement.dart';
import '../models/app_notice.dart';
import '../models/credit.dart';
import '../models/registration.dart';
import '../utils/constants.dart';

// 1 แถวในรายชื่อ
class RosterItem {
  final Registration registration;
  final Credit? credit;

  RosterItem(this.registration, this.credit);

  bool get hasCredit => credit != null;
}

// ฝั่งผู้คุม
class SupervisorProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<Activity> activities = [];
  Map<String, int> registeredCount = {};
  List<RosterItem> roster = [];
  String searchText = '';
  String rosterFilter = 'ทั้งหมด';

  Future<void> loadActivities(String orgCode) async {
    activities = await db.getActivitiesOfOrg(orgCode);
    registeredCount = {};
    for (final a in activities) {
      registeredCount[a.id] = await db.countRegistrations(a.id);
    }
    notifyListeners();
  }

  Activity? findById(String id) {
    for (final a in activities) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> saveActivity(Activity a, bool isNew) async {
    if (isNew) {
      await db.insertActivity(a);
    } else {
      await db.updateActivity(a);
    }
    await loadActivities(a.orgCode);
  }

  // รายชื่อ

  Future<void> loadRoster(String activityId) async {
    final registrations = await db.getRegistrationsOfActivity(activityId);
    final credits = await db.getCreditsOfActivity(activityId);

    roster = [];
    for (final r in registrations) {
      Credit? found;
      for (final c in credits) {
        if (c.studentId == r.studentId) found = c;
      }
      roster.add(RosterItem(r, found));
    }
    notifyListeners();
  }

  int get creditedCount => roster.where((item) => item.hasCredit).length;

  void setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  void setRosterFilter(String filter) {
    rosterFilter = filter;
    notifyListeners();
  }

  List<RosterItem> get filteredRoster {
    return roster.where((item) {
      final r = item.registration;
      final matchSearch = r.studentName.contains(searchText) || r.studentId.contains(searchText);
      if (!matchSearch) return false;
      if (rosterFilter == 'ได้ชั่วโมงแล้ว') return item.hasCredit;
      if (rosterFilter == 'ยังไม่ได้') return !item.hasCredit;
      return true;
    }).toList();
  }

  Credit _creditBySupervisor(Activity a, String studentId) {
    return Credit(
      activityId: a.id,
      activityTitle: a.title,
      studentId: studentId,
      hours: a.hours,
      kind: a.kind,
      method: kBySupervisor,
      distance: 0,
      ref: 'M${DateTime.now().millisecondsSinceEpoch % 10000000}',
      verifiedAt: DateTime.now(),
    );
  }

  // เพิ่มชื่อเอง เช่น มือถือนิสิตแบตหมด
  Future<void> addStudentManually(Activity a, String studentId, String name, String faculty) async {
    await db.insertRegistration(Registration(
      activityId: a.id,
      studentId: studentId,
      studentName: name.trim(),
      faculty: faculty,
      registeredAt: DateTime.now(),
    ));
    await db.insertCredit(_creditBySupervisor(a, studentId));
    await loadRoster(a.id);
    await loadActivities(a.orgCode);
  }

  Future<void> giveCredit(Activity a, RosterItem item) async {
    await db.insertCredit(_creditBySupervisor(a, item.registration.studentId));
    await loadRoster(a.id);
  }

  Future<void> removeCredit(Activity a, RosterItem item) async {
    await db.deleteCredit(a.id, item.registration.studentId);
    await loadRoster(a.id);
  }

  Future<void> removeFromRoster(Activity a, RosterItem item) async {
    await db.deleteCredit(a.id, item.registration.studentId);
    await db.deleteRegistration(a.id, item.registration.studentId);
    await loadRoster(a.id);
    await loadActivities(a.orgCode);
  }

  // ประกาศ

  Future<int> postAnnouncement(Activity a, String text) async {
    await db.insertAnnouncement(Announcement(
      activityId: a.id,
      text: text.trim(),
      createdAt: DateTime.now(),
    ));
    for (final item in roster) {
      await db.insertNotice(AppNotice(
        studentId: item.registration.studentId,
        activityId: a.id,
        title: 'ประกาศจาก ${a.title}',
        body: text.trim(),
        createdAt: DateTime.now(),
      ));
    }
    return roster.length;
  }
}
