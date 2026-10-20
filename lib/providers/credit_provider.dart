import 'package:flutter/foundation.dart';

import '../helpers/database_helper.dart';
import '../models/credit.dart';

// ชั่วโมงสะสมของนิสิต ใช้ในหน้า Transcript (R3)
class CreditProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<Credit> credits = [];

  Future<void> loadCredits(String studentId) async {
    credits = await db.getCreditsOfStudent(studentId);
    notifyListeners();
  }

  // ชั่วโมงรวมทุกประเภท
  double get totalHours {
    double sum = 0;
    for (final c in credits) {
      sum += c.hours;
    }
    return sum;
  }

  // ชั่วโมงรวมของประเภทที่ส่งมา เช่น 'จิตอาสา'
  double hoursOfKind(String kind) {
    double sum = 0;
    for (final c in credits) {
      if (c.kind == kind) sum += c.hours;
    }
    return sum;
  }

  // จำนวนกิจกรรมของประเภทที่ส่งมา
  int countOfKind(String kind) {
    return credits.where((c) => c.kind == kind).length;
  }

  bool hasCredit(String activityId) {
    return credits.any((c) => c.activityId == activityId);
  }
}
