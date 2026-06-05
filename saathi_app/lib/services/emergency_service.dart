import 'dart:math' as math;

import '../models/emergency.dart';
import '../models/responder.dart';
import '../models/user.dart';
import '../utils/distance_calculator.dart';
import 'bluetooth_mesh_service.dart';
import 'emergency_contact_service.dart';
import 'location_service.dart';
import 'notification_service.dart';

class EmergencyService {
  EmergencyService({
    required LocationService locationService,
    required NotificationService notificationService,
    required BluetoothMeshService bluetoothMeshService,
    required EmergencyContactService emergencyContactService,
  })  : _locationService = locationService,
        _notificationService = notificationService,
        _bluetoothMeshService = bluetoothMeshService,
        _emergencyContactService = emergencyContactService;

  final LocationService _locationService;
  final NotificationService _notificationService;
  final BluetoothMeshService _bluetoothMeshService;
  final EmergencyContactService _emergencyContactService;

  EmergencyEvent? _currentEmergency;
  final List<ResponderAssignment> _responders = [];
  final List<String> _activityLog = [];

  EmergencyEvent? get currentEmergency => _currentEmergency;
  List<ResponderAssignment> get responders => List.unmodifiable(_responders);
  List<String> get activityLog => List.unmodifiable(_activityLog);

  Future<EmergencyEvent> startEmergency({required String dangerLevel, required SaathiUser victim}) async {
    final location = await _locationService.getCurrentLocation();
    final id = 'emergency_${DateTime.now().millisecondsSinceEpoch}';
    final level = int.tryParse(dangerLevel) ?? 3;
    final nearbyResponders = _buildDemoResponders(location.latitude, location.longitude);
    _responders
      ..clear()
      ..addAll(nearbyResponders);

    _currentEmergency = EmergencyEvent(
      id: id,
      userId: victim.id,
      location: location,
      dangerLevel: level.clamp(1, 5),
      status: EmergencyStatus.active,
      createdAt: DateTime.now(),
      nearbyResponderIds: nearbyResponders.map((responder) => responder.userId).toList(),
    );

    _activityLog
      ..clear()
      ..add('Emergency created at ${DateTime.now().toIso8601String()}')
      ..add('Nearby responders identified: ${nearbyResponders.length}');

    await _notificationService.showEmergencyNotification(
      'Saathi in Distress',
      'Emergency ${_currentEmergency!.dangerLevel}/5, 500m away',
    );
    _activityLog.add('Local alert sent to nearby Saathi users');
    await _bluetoothMeshService.startBroadcast(
      userId: victim.id,
      payload: _currentEmergency!.toJson(),
    );
    _activityLog.add('Offline mesh broadcast started');
    final contactMessages = await _emergencyContactService.notifyContacts(id, location.latitude, location.longitude);
    _activityLog.addAll(contactMessages);

    return _currentEmergency!;
  }

  Future<EmergencyEvent> cancelEmergency(String emergencyId) async {
    if (_currentEmergency == null || _currentEmergency!.id != emergencyId) {
      throw StateError('Emergency not found');
    }
    _currentEmergency = _currentEmergency!.copyWith(status: EmergencyStatus.cancelled);
    _activityLog.add('Emergency cancelled');
    await _bluetoothMeshService.stopBroadcast();
    _activityLog.add('Offline mesh broadcast stopped');
    return _currentEmergency!;
  }

  Future<String> dispatchPoliceCall() async {
    _activityLog.add(_currentEmergency == null ? 'Police dispatch requested via silent trigger' : 'Police dispatch requested');
    final result = await _emergencyContactService.contactPolice();
    return result;
  }

  Future<void> notifyEmergencyContacts({required String reason}) async {
    final location = await _locationService.getCurrentLocation();
    final id = _currentEmergency?.id ?? 'silent_${DateTime.now().millisecondsSinceEpoch}';
    final messages = await _emergencyContactService.notifyContacts(id, location.latitude, location.longitude);
    _activityLog.add(reason);
    _activityLog.addAll(messages);
  }

  Future<String> dispatchAmbulanceAndSafety() async {
    if (_currentEmergency == null) {
      final location = await _locationService.getCurrentLocation();
      _activityLog.add('Ambulance and hospital safety response requested via silent trigger');
      await _bluetoothMeshService.relayEncryptedSignal(
        payload: {
          'user_id': 'silent_trigger',
          'location': location.toJson(),
          'danger_level': 4,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
          'recipient': 'nearest_hospital',
          'support': 'ambulance_and_safety',
        },
        hopCount: 10,
        recipient: 'nearest_hospital',
      );
      final result = await _emergencyContactService.contactAmbulance();
      final safetyMessages = await _emergencyContactService.shareToSafetyNetwork(
        location.latitude,
        location.longitude,
      );
      _activityLog.addAll(safetyMessages);
      return result;
    }
    _activityLog.add('Ambulance and hospital safety response requested');
    await _bluetoothMeshService.relayEncryptedSignal(
      payload: {
        ..._currentEmergency!.toJson(),
        'recipient': 'nearest_hospital',
        'support': 'ambulance_and_safety',
      },
      hopCount: 10,
      recipient: 'nearest_hospital',
    );
    final result = await _emergencyContactService.contactAmbulance();
    final safetyMessages = await _emergencyContactService.shareToSafetyNetwork(
      _currentEmergency!.location.latitude,
      _currentEmergency!.location.longitude,
    );
    _activityLog.addAll(safetyMessages);
    return result;
  }

  Future<String> broadcastEncryptedChain() async {
    if (_currentEmergency == null) {
      throw StateError('No active emergency');
    }
    await _bluetoothMeshService.relayEncryptedSignal(
      payload: {
        ..._currentEmergency!.toJson(),
        'recipient': 'offline_mesh_chain',
        'support': 'relay_only',
      },
      hopCount: 10,
      recipient: 'offline_mesh_chain',
    );
    _activityLog.add('Encrypted offline mesh relay propagated');
    return 'Encrypted offline mesh relay active';
  }

  Future<ResponderAssignment> assignResponder(String responderId) async {
    final index = _responders.indexWhere((responder) => responder.userId == responderId);
    if (index == -1) {
      throw StateError('Responder not found');
    }
    final updated = _responders[index].copyWith(isComing: true);
    final role = _roleForIndex(_responders.indexWhere((responder) => responder.userId == responderId));
    _responders[index] = updated.copyWith(role: role);
    _activityLog.add('${updated.name} accepted role ${role.name}');
    return _responders[index];
  }

  Future<void> markResolved() async {
    if (_currentEmergency == null) {
      return;
    }
    _currentEmergency = _currentEmergency!.copyWith(status: EmergencyStatus.resolved);
    _activityLog.add('Emergency resolved');
    await _bluetoothMeshService.stopBroadcast();
    _activityLog.add('Offline mesh broadcast stopped');
  }

  List<ResponderAssignment> _buildDemoResponders(double victimLat, double victimLng) {
    final demos = [
      ('Rupa Lama', 0.0012),
      ('Suman Rai', 0.0018),
      ('Prakash K.C.', 0.0026),
    ];

    return List.generate(demos.length, (index) {
      final name = demos[index].$1;
      final offset = demos[index].$2;
      final responderLat = victimLat + offset;
      final responderLng = victimLng + (index.isEven ? offset : -offset / 2);
      final distance = DistanceCalculator.distanceMeters(victimLat, victimLng, responderLat, responderLng);
      return ResponderAssignment(
        userId: 'responder_${index + 1}',
        name: name,
        distanceMeters: distance,
        role: _roleForIndex(index),
        isComing: false,
      );
    });
  }

  ResponderRole _roleForIndex(int index) {
    switch (index) {
      case 0:
        return ResponderRole.approach;
      case 1:
        return ResponderRole.callPolice;
      default:
        return ResponderRole.document;
    }
  }

  String buildResponderRoleText(ResponderRole role) {
    switch (role) {
      case ResponderRole.approach:
        return 'Approach & Verify';
      case ResponderRole.callPolice:
        return 'Call 100';
      case ResponderRole.document:
        return 'Document';
    }
  }

  double estimatedMetersAway(String responderId) {
    final responder = _responders.firstWhere((item) => item.userId == responderId, orElse: () => _responders.isNotEmpty ? _responders.first : ResponderAssignment(userId: 'none', name: 'None', distanceMeters: 0, role: ResponderRole.approach, isComing: false));
    return responder.distanceMeters;
  }

  String randomEmergencyCode() => (math.Random().nextInt(9000) + 1000).toString();
}
