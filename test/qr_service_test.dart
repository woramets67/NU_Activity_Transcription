import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nu_activity_transcript/helpers/seed_data.dart';
import 'package:nu_activity_transcript/services/qr_service.dart';

void main() {
  final activity = seedActivities().first;

  test('QR ที่สร้างจากแอพอ่านกลับได้ และข้อมูลครบ', () {
    final qrText = QrService.createQrText(activity, 16.7464, 100.1953);
    final data = QrService.readQrText(qrText);

    expect(data, isNotNull);
    expect(data!['activityId'], activity.id);
    expect(data['hours'], activity.hours);
  });

  test('แก้ชั่วโมงใน QR แล้วลายเซ็นไม่ตรง อ่านไม่ผ่าน', () {
    final qrText = QrService.createQrText(activity, 16.7464, 100.1953);
    final data = jsonDecode(qrText);
    data['hours'] = 100;

    expect(QrService.readQrText(jsonEncode(data)), null);
  });

  test('QR ที่ไม่ใช่ของแอพ อ่านไม่ผ่าน', () {
    expect(QrService.readQrText('https://example.com'), null);
  });

  test('QR ที่สร้างเมื่อ 20 วินาทีก่อน มีอายุ 20 วินาที', () {
    final twentySecondsAgo = DateTime.now().subtract(const Duration(seconds: 20));
    expect(QrService.qrAgeInSeconds(twentySecondsAgo.millisecondsSinceEpoch), 20);
  });
}
