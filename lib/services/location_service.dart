import 'package:geolocator/geolocator.dart';

// GPS
class LocationService {
  static Future<Position?> getCurrentPosition() async {
    final gpsOn = await Geolocator.isLocationServiceEnabled();
    if (!gpsOn) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 15)),
      );
    } catch (e) {
      return null;
    }
  }

  static double distanceInMeters(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
