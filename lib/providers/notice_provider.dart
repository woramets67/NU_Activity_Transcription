import 'package:flutter/foundation.dart';

import '../helpers/database_helper.dart';
import '../models/app_notice.dart';

// แจ้งเตือน
class NoticeProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<AppNotice> notices = [];
  String _studentId = '';

  int get unreadCount => notices.where((n) => !n.isRead).length;

  Future<void> loadNotices(String studentId) async {
    _studentId = studentId;
    notices = await db.getNotices(studentId);
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadNotices(_studentId);
  }

  Future<void> markRead(AppNotice n) async {
    if (n.isRead) return;
    await db.markNoticeRead(n.id!);
    await refresh();
  }

  Future<void> markAllRead() async {
    await db.markAllNoticesRead(_studentId);
    await refresh();
  }
}
