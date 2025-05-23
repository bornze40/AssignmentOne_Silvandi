import 'package:geolocator/geolocator.dart';
import 'package:h8_fli_geo_maps_starter/model/geo.dart';

class GeoService {
  Future<bool> handlePermission() async {
    final isServiceAvailable = await Geolocator.isLocationServiceEnabled();
    if (!isServiceAvailable) {
      throw Exception('Location service is not available.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever.');
    }

    return true;
  }

  Future<Geo> getLocation() async {
    try {
      // Pastikan izin sudah diberikan
      await handlePermission();

      // Ambil posisi terkini dengan timeout agar tidak hang
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Location request timed out");
        },
      );

      return Geo(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      throw Exception("Failed to get current location: $e");
    }
  }

  Stream<Geo> getLocationStream() {
    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).map((position) {
        return Geo(latitude: position.latitude, longitude: position.longitude);
      });
    } catch (e) {
      // Kamu bisa log atau throw error juga di sini
      throw Exception("Failed to get location stream: $e");
    }
  }
}
