import 'package:geolocator/geolocator.dart';

import '../models/emergency.dart';

class LocationService {
  Future<bool> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<EmergencyLocation> getCurrentLocation() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      return const EmergencyLocation(latitude: 27.7172, longitude: 85.3240, accuracy: 25);
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (position.accuracy > 50) {
      return const EmergencyLocation(latitude: 27.7172, longitude: 85.3240, accuracy: 25);
    }

    return EmergencyLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }

  Stream<EmergencyLocation> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map(
      (position) => EmergencyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ),
    );
  }
}
