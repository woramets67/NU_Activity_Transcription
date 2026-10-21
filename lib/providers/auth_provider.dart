import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
import '../models/student.dart';

// การเข้าระบบ
class AuthProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  bool isLoading = true;
  Student? student;

  String? supOrgCode;
  String supOrgName = '';
  String supName = '';

  bool get isSupervisor => supOrgCode != null;

  String hashPin(String studentId, String pin) {
    return sha256.convert(utf8.encode('$studentId:$pin')).toString();
  }

  Future<void> loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final savedId = prefs.getString('student_id');
    if (savedId != null) {
      student = await db.getStudent(savedId);
    }

    final savedOrg = prefs.getString('sup_org');
    if (savedOrg != null) {
      supOrgCode = savedOrg;
      supOrgName = await db.getOrgName(savedOrg) ?? '';
      supName = prefs.getString('sup_name') ?? '';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String?> signUp(String studentId, String name, String faculty, String pin) async {
    final existing = await db.getStudent(studentId);
    if (existing != null) {
      return 'รหัสนิสิตนี้มีบัญชีแล้ว ให้เข้าสู่ระบบแทน';
    }
    final newStudent = Student(
      studentId: studentId,
      name: name.trim(),
      faculty: faculty,
      pinHash: hashPin(studentId, pin),
    );
    await db.insertStudent(newStudent);
    await _saveLogin(newStudent);
    return null;
  }

  Future<String?> signIn(String studentId, String pin) async {
    final found = await db.getStudent(studentId);
    if (found == null) {
      return 'ไม่พบบัญชีของรหัสนิสิตนี้';
    }
    if (found.pinHash != hashPin(studentId, pin)) {
      return 'PIN ไม่ถูกต้อง';
    }
    await _saveLogin(found);
    return null;
  }

  Future<void> _saveLogin(Student s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_id', s.studentId);
    student = s;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_id');
    student = null;
    notifyListeners();
  }

  Future<String?> enterSupervisor(String name, String orgCode) async {
    final code = orgCode.trim().toUpperCase();
    final orgName = await db.getOrgName(code);
    if (orgName == null) {
      return 'ไม่พบรหัสหน่วยงานนี้';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sup_org', code);
    await prefs.setString('sup_name', name.trim());
    supOrgCode = code;
    supOrgName = orgName;
    supName = name.trim();
    notifyListeners();
    return null;
  }

  Future<void> exitSupervisor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sup_org');
    await prefs.remove('sup_name');
    supOrgCode = null;
    supOrgName = '';
    supName = '';
    notifyListeners();
  }
}
