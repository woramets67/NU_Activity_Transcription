import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/activity.dart';
import '../utils/constants.dart';

// QR
class QrService {
  static String _makeSign(String activityId, double hours, String kind, int time, double lat, double lng) {
    final text = '$activityId|$hours|$kind|$time|$lat|$lng|$kQrSecret';
    return sha256.convert(utf8.encode(text)).toString();
  }

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
      return null;
    }
  }

  static int qrAgeInSeconds(int qrTime) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((now - qrTime) / 1000).round();
  }
}
