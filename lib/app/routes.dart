import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/claim_result.dart';
import '../screens/student/activity_detail_screen.dart';
import '../screens/student/claim_result_screen.dart';
import '../screens/student/scan_screen.dart';
import '../screens/supervisor/activity_editor_screen.dart';
import '../screens/supervisor/manage_screen.dart';
import '../screens/supervisor/qr_presenter_screen.dart';
import '../screens/supervisor/sup_home_screen.dart';
import '../screens/supervisor/sup_login_screen.dart';

// ชื่อหน้าทั้งหมดของแอพ (named routes บทที่ 9)
class Routes {
  static const activityDetail = '/activity'; // ส่ง id ของกิจกรรม (String)
  static const scan = '/scan';
  static const claimResult = '/claim-result'; // ส่ง ClaimResult
  static const supLogin = '/sup-login';
  static const supHome = '/sup-home';
  static const activityEditor = '/activity-editor'; // ส่ง id ถ้าแก้ไข ส่ง null ถ้าสร้างใหม่
  static const manage = '/manage'; // ส่ง id ของกิจกรรม (String)
  static const qrPresenter = '/qr'; // ส่ง Activity
}

// onGenerateRoute: ดูชื่อหน้าแล้วส่งข้อมูล (arguments) เข้าหน้าจอให้ถูกต้อง
Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  Widget page;

  if (settings.name == Routes.activityDetail) {
    page = ActivityDetailScreen(activityId: args as String);
  } else if (settings.name == Routes.scan) {
    page = const ScanScreen();
  } else if (settings.name == Routes.claimResult) {
    page = ClaimResultScreen(result: args as ClaimResult);
  } else if (settings.name == Routes.supLogin) {
    page = const SupLoginScreen();
  } else if (settings.name == Routes.supHome) {
    page = const SupHomeScreen();
  } else if (settings.name == Routes.activityEditor) {
    page = ActivityEditorScreen(activityId: args as String?);
  } else if (settings.name == Routes.manage) {
    page = ManageScreen(activityId: args as String);
  } else if (settings.name == Routes.qrPresenter) {
    page = QrPresenterScreen(activity: args as Activity);
  } else {
    page = Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('ไม่พบหน้า ${settings.name}')),
    );
  }

  return MaterialPageRoute(builder: (context) => page);
}
