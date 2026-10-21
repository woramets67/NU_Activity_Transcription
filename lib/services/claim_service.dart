import '../helpers/database_helper.dart';
import '../models/app_notice.dart';
import '../models/claim_result.dart';
import '../models/credit.dart';
import '../models/student.dart';
import '../utils/constants.dart';
import '../utils/thai_date.dart';
import 'location_service.dart';
import 'qr_service.dart';

// ตรวจการสแกน
class ClaimService {
  final db = DatabaseHelper.instance;

  Future<ClaimResult> checkAndSave(String qrText, Student student) async {
    // 1. ลายเซ็น
    final data = QrService.readQrText(qrText);
    if (data == null) {
      return ClaimResult(success: false, message: 'QR นี้ใช้รับชั่วโมงไม่ได้');
    }
    final String activityId = data['activityId'];

    // 2. อายุ QR
    final age = QrService.qrAgeInSeconds(data['time']);
    if (age > kQrMaxAge) {
      return ClaimResult(success: false, message: 'QR หมดอายุแล้ว ให้สแกนจากจอผู้คุมอีกครั้ง');
    }

    // 3. สแกนซ้ำ
    if (await db.hasCredit(activityId, student.studentId)) {
      return ClaimResult(success: false, message: 'คุณได้รับชั่วโมงกิจกรรมนี้ไปแล้ว');
    }

    // 4. ลงทะเบียน
    if (!await db.isRegistered(activityId, student.studentId)) {
      return ClaimResult(success: false, message: 'คุณยังไม่ได้ลงทะเบียนกิจกรรมนี้ ติดต่อผู้คุมให้เพิ่มชื่อ');
    }

    // 5. ระยะ
    final position = await LocationService.getCurrentPosition();
    if (position == null) {
      return ClaimResult(success: false, message: 'กรุณาเปิด GPS และอนุญาตตำแหน่งก่อนสแกน');
    }
    final distance = LocationService.distanceInMeters(
      position.latitude,
      position.longitude,
      (data['lat'] as num).toDouble(),
      (data['lng'] as num).toDouble(),
    );
    if (distance > kMaxDistance) {
      return ClaimResult(
        success: false,
        message: 'อยู่ห่างจากผู้คุม ${distance.round()} ม. ต้องอยู่ในระยะ ${kMaxDistance.round()} ม.',
      );
    }

    final activity = await db.getActivity(activityId);
    final credit = Credit(
      activityId: activityId,
      activityTitle: activity?.title ?? 'กิจกรรม',
      studentId: student.studentId,
      hours: (data['hours'] as num).toDouble(),
      kind: data['kind'],
      method: kByQr,
      distance: distance,
      ref: data['sign'].toString().substring(0, 8).toUpperCase(),
      verifiedAt: DateTime.now(),
    );
    await db.insertCredit(credit);

    await db.insertNotice(AppNotice(
      studentId: student.studentId,
      activityId: activityId,
      title: 'ได้รับ ${hoursText(credit.hours)} ${credit.kind}',
      body: credit.activityTitle,
      createdAt: DateTime.now(),
    ));

    return ClaimResult(success: true, message: 'รับชั่วโมงสำเร็จ', credit: credit);
  }
}
