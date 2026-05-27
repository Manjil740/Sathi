import 'package:flutter/foundation.dart';

import '../models/emergency.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider(this._locationService);

  final LocationService _locationService;
  EmergencyLocation? _currentLocation;
  bool _hasPermission = false;

  EmergencyLocation? get currentLocation => _currentLocation;
  bool get hasPermission => _hasPermission;

  Future<void> refreshLocation() async {
    _hasPermission = await _locationService.ensurePermission();
    _currentLocation = await _locationService.getCurrentLocation();
    notifyListeners();
  }
}
