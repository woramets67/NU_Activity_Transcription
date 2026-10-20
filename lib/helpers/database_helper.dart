import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/activity.dart';
import '../models/announcement.dart';
import '../models/app_notice.dart';
import '../models/credit.dart';
import '../models/registration.dart';
import '../models/student.dart';
import 'seed_data.dart';

// จัดการฐานข้อมูล SQLite ทั้งหมดของแอพ (แบบเดียวกับบทที่ 13 และ 15)
// หน้าจอไม่เรียกไฟล์นี้ตรงๆ ให้เรียกผ่าน Provider
class DatabaseHelper {
  // ใช้ตัวเดียวทั้งแอพ (singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDB();
    return _database!;
  }

  Future<Database> _openDB() async {
    final path = join(await getDatabasesPath(), 'nuat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _moveDemoActivity,
    );
  }

  // สร้างตารางตอนเปิดแอพครั้งแรก
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        student_id TEXT PRIMARY KEY,
        name TEXT,
        faculty TEXT,
        pin_hash TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE orgs (
        code TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        title TEXT,
        kind TEXT,
        org_code TEXT,
        org_name TEXT,
        start_at INTEGER,
        end_at INTEGER,
        place TEXT,
        hours REAL,
        capacity INTEGER,
        detail TEXT,
        poster TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE registrations (
        activity_id TEXT,
        student_id TEXT,
        student_name TEXT,
        faculty TEXT,
        registered_at INTEGER,
        PRIMARY KEY (activity_id, student_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE credits (
        activity_id TEXT,
        activity_title TEXT,
        student_id TEXT,
        hours REAL,
        kind TEXT,
        method TEXT,
        distance REAL,
        ref TEXT,
        verified_at INTEGER,
        PRIMARY KEY (activity_id, student_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id TEXT,
        text TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE notices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT,
        activity_id TEXT,
        title TEXT,
        body TEXT,
        created_at INTEGER,
        is_read INTEGER
      )
    ''');

    // ใส่ข้อมูลตัวอย่าง
    for (final code in seedOrgs.keys) {
      await db.insert('orgs', {'code': code, 'name': seedOrgs[code]});
    }
    for (final a in seedActivities()) {
      await db.insert('activities', a.toMap());
    }
    for (final r in seedRegistrations()) {
      await db.insert('registrations', r.toMap());
    }
  }

  // เลื่อนกิจกรรมสาธิตให้กำลังจัดอยู่เสมอ
  Future<void> _moveDemoActivity(Database db) async {
    final now = DateTime.now();
    await db.update(
      'activities',
      {
        'start_at': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        'end_at': now.add(const Duration(hours: 4)).millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [demoActivityId],
    );
  }

  // ---------- นิสิต ----------

  Future<void> insertStudent(Student s) async {
    final db = await database;
    await db.insert('students', s.toMap());
  }

  Future<Student?> getStudent(String studentId) async {
    final db = await database;
    final rows = await db.query('students', where: 'student_id = ?', whereArgs: [studentId]);
    if (rows.isEmpty) return null;
    return Student.fromMap(rows.first);
  }

  // ---------- หน่วยงาน ----------

  // คืนชื่อหน่วยงาน หรือ null ถ้าไม่มีรหัสนี้
  Future<String?> getOrgName(String code) async {
    final db = await database;
    final rows = await db.query('orgs', where: 'code = ?', whereArgs: [code]);
    if (rows.isEmpty) return null;
    return rows.first['name'] as String;
  }

  // ---------- กิจกรรม ----------

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final rows = await db.query('activities', orderBy: 'start_at');
    return rows.map((row) => Activity.fromMap(row)).toList();
  }

  Future<List<Activity>> getActivitiesOfOrg(String orgCode) async {
    final db = await database;
    final rows = await db.query('activities',
        where: 'org_code = ?', whereArgs: [orgCode], orderBy: 'start_at');
    return rows.map((row) => Activity.fromMap(row)).toList();
  }

  Future<Activity?> getActivity(String id) async {
    final db = await database;
    final rows = await db.query('activities', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Activity.fromMap(rows.first);
  }

  Future<void> insertActivity(Activity a) async {
    final db = await database;
    await db.insert('activities', a.toMap());
  }

  Future<void> updateActivity(Activity a) async {
    final db = await database;
    await db.update('activities', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  // ---------- การลงทะเบียน ----------

  Future<List<Registration>> getRegistrationsOfActivity(String activityId) async {
    final db = await database;
    final rows = await db.query('registrations',
        where: 'activity_id = ?', whereArgs: [activityId], orderBy: 'registered_at');
    return rows.map((row) => Registration.fromMap(row)).toList();
  }

  Future<List<Registration>> getRegistrationsOfStudent(String studentId) async {
    final db = await database;
    final rows = await db.query('registrations', where: 'student_id = ?', whereArgs: [studentId]);
    return rows.map((row) => Registration.fromMap(row)).toList();
  }

  Future<int> countRegistrations(String activityId) async {
    final db = await database;
    final rows = await db.query('registrations', where: 'activity_id = ?', whereArgs: [activityId]);
    return rows.length;
  }

  Future<bool> isRegistered(String activityId, String studentId) async {
    final db = await database;
    final rows = await db.query('registrations',
        where: 'activity_id = ? AND student_id = ?', whereArgs: [activityId, studentId]);
    return rows.isNotEmpty;
  }

  Future<void> insertRegistration(Registration r) async {
    final db = await database;
    // ถ้าลงทะเบียนซ้ำ ให้ข้ามไป
    await db.insert('registrations', r.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteRegistration(String activityId, String studentId) async {
    final db = await database;
    await db.delete('registrations',
        where: 'activity_id = ? AND student_id = ?', whereArgs: [activityId, studentId]);
  }

  // ---------- ชั่วโมง ----------

  Future<List<Credit>> getCreditsOfStudent(String studentId) async {
    final db = await database;
    final rows = await db.query('credits',
        where: 'student_id = ?', whereArgs: [studentId], orderBy: 'verified_at DESC');
    return rows.map((row) => Credit.fromMap(row)).toList();
  }

  Future<List<Credit>> getCreditsOfActivity(String activityId) async {
    final db = await database;
    final rows = await db.query('credits', where: 'activity_id = ?', whereArgs: [activityId]);
    return rows.map((row) => Credit.fromMap(row)).toList();
  }

  Future<bool> hasCredit(String activityId, String studentId) async {
    final db = await database;
    final rows = await db.query('credits',
        where: 'activity_id = ? AND student_id = ?', whereArgs: [activityId, studentId]);
    return rows.isNotEmpty;
  }

  Future<void> insertCredit(Credit c) async {
    final db = await database;
    await db.insert('credits', c.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteCredit(String activityId, String studentId) async {
    final db = await database;
    await db.delete('credits',
        where: 'activity_id = ? AND student_id = ?', whereArgs: [activityId, studentId]);
  }

  // ---------- ประกาศ ----------

  Future<List<Announcement>> getAnnouncements(String activityId) async {
    final db = await database;
    final rows = await db.query('announcements',
        where: 'activity_id = ?', whereArgs: [activityId], orderBy: 'created_at DESC');
    return rows.map((row) => Announcement.fromMap(row)).toList();
  }

  Future<void> insertAnnouncement(Announcement a) async {
    final db = await database;
    await db.insert('announcements', a.toMap());
  }

  // ---------- แจ้งเตือน ----------

  Future<List<AppNotice>> getNotices(String studentId) async {
    final db = await database;
    final rows = await db.query('notices',
        where: 'student_id = ?', whereArgs: [studentId], orderBy: 'created_at DESC');
    return rows.map((row) => AppNotice.fromMap(row)).toList();
  }

  Future<void> insertNotice(AppNotice n) async {
    final db = await database;
    await db.insert('notices', n.toMap());
  }

  Future<void> markNoticeRead(int id) async {
    final db = await database;
    await db.update('notices', {'is_read': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNoticesRead(String studentId) async {
    final db = await database;
    await db.update('notices', {'is_read': 1}, where: 'student_id = ?', whereArgs: [studentId]);
  }
}
