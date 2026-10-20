import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/activity.dart';
import '../utils/constants.dart';

// สร้างและอ่านข้อความใน QR
//
// ใน QR เป็นข้อความ JSON เช่น
// {"app":"nuat","activityId":"a-blood","hours":4.0,"kind":"จิตอาสา",
//  "time":1760943600000,"lat":16.74,"lng":100.19,"sign":"8f3a..."}
//
// sign คือลายเซ็น ได้จากเอาข้อมูลทั้งหมดต่อกับรหัสลับแล้วเข้ารหัส sha256
// ถ้ามีคนแก้ข้อมูลใน QR ลายเซ็นจะไม่ตรง แอพจะรู้ทันที
class QrService {
  static String _makeSign(String activityId, double hours, String kind, int time, double lat, double lng) {
    final text = '$activityId|$hours|$kind|$time|$lat|$lng|$kQrSecret';
    return sha256.convert(utf8.encode(text)).toString();
  }

  // ฝั่งผู้คุม: สร้างข้อความใส่ QR ใส่เวลาปัจจุบันและตำแหน่งของผู้คุม
  static String createQrText(Activity activity, double lat, double lng) {
    final time = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'app': 'nuat',
      'activityId': activity.id,
      'hours': activity.hours,
      'kind': activity.kind,
      'time': time,
      'lat': lat,
      'lng': lng,
      'sign': _makeSign(activity.id, activity.hours, activity.kind, time, lat, lng),
    };
    return jsonEncode(data);
  }

  // ฝั่งนิสิต: อ่าน QR ถ้าไม่ใช่ QR ของแอพนี้ หรือลายเซ็นไม่ตรง คืน null
  static Map<String, dynamic>? readQrText(String text) {
    try {
      final data = jsonDecode(text);
      if (data['app'] != 'nuat') return null;

      final correctSign = _makeSign(
        data['activityId'],
        (data['hours'] as num).toDouble(),
        data['kind'],
        data['time'],
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );
      if (data['sign'] != correctSign) return null;

      return data;
    } catch (e) {
      // อ่าน JSON ไม่ได้ แปลว่าไม่ใช่ QR ของแอพนี้
      return null;
    }
  }

  // QR อายุกี่วินาทีแล้ว
  static int qrAgeInSeconds(int qrTime) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((now - qrTime) / 1000).round();
  }
}
