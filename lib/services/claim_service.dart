import '../helpers/database_helper.dart';
import '../models/app_notice.dart';
import '../models/claim_result.dart';
import '../models/credit.dart';
import '../models/student.dart';
import '../utils/constants.dart';
import '../utils/thai_date.dart';
import 'location_service.dart';
import 'qr_service.dart';

// ตรวจ QR ที่นิสิตสแกน ผ่านครบ 5 ข้อแล้วจึงบันทึกชั่วโมง (R2)
class ClaimService {
  final db = DatabaseHelper.instance;

  Future<ClaimResult> checkAndSave(String qrText, Student student) async {
    // ข้อ 1: เป็น QR ของผู้คุมจริง (ลายเซ็นถูก)
    final data = QrService.readQrText(qrText);
    if (data == null) {
      return ClaimResult(success: false, message: 'QR นี้ใช้รับชั่วโมงไม่ได้');
    }
    final String activityId = data['activityId'];

    // ข้อ 2: QR ยังไม่หมดอายุ (ไม่เก่ากว่า 15 วินาที)
    final age = QrService.qrAgeInSeconds(data['time']);
    if (age > kQrMaxAge) {
      return ClaimResult(success: false, message: 'QR หมดอายุแล้ว ให้สแกนจากจอผู้คุมอีกครั้ง');
    }

    // ข้อ 3: ยังไม่เคยได้ชั่วโมงกิจกรรมนี้ (กันสแกนซ้ำ)
    if (await db.hasCredit(activityId, student.studentId)) {
      return ClaimResult(success: false, message: 'คุณได้รับชั่วโมงกิจกรรมนี้ไปแล้ว');
    }

    // ข้อ 4: ลงทะเบียนกิจกรรมนี้ไว้แล้ว
    if (!await db.isRegistered(activityId, student.studentId)) {
      return ClaimResult(success: false, message: 'คุณยังไม่ได้ลงทะเบียนกิจกรรมนี้ ติดต่อผู้คุมให้เพิ่มชื่อ');
    }

    // ข้อ 5: อยู่ห่างผู้คุมไม่เกิน 200 เมตร
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

    // ผ่านครบ บันทึกชั่วโมง
    final activity = await db.getActivity(activityId);
    final credit = Credit(
      activityId: activityId,
      activityTitle: activity?.title ?? 'กิจกรรม',
      studentId: student.studentId,
      hours: (data['hours'] as num).toDouble(),
      kind: data['kind'],
      method: kByQr,
      distance: distance,
      ref: data['sign'].toString().substring(0, 8).toUpperCase(), // เลขอ้างอิง 8 ตัวจากลายเซ็น
      verifiedAt: DateTime.now(),
    );
    await db.insertCredit(credit);

    // แจ้งเตือนว่าได้ชั่วโมง
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
