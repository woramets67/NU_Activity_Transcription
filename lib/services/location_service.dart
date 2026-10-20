import 'package:geolocator/geolocator.dart';

// อ่านตำแหน่ง GPS ของเครื่อง
class LocationService {
  // คืนตำแหน่งปัจจุบัน หรือ null ถ้าปิด GPS หรือผู้ใช้ไม่อนุญาต
  static Future<Position?> getCurrentPosition() async {
    // 1. เปิด GPS อยู่ไหม
    final gpsOn = await Geolocator.isLocationServiceEnabled();
    if (!gpsOn) return null;

    // 2. ขออนุญาตใช้ตำแหน่ง
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3. อ่านตำแหน่ง
    return await Geolocator.getCurrentPosition();
  }

  // ระยะห่างระหว่าง 2 จุด หน่วยเป็นเมตร
  static double distanceInMeters(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
