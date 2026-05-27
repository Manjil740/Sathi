enum PanicTriggerPhase {
  idle,
  armed,
  policeDispatched,
  ambulanceDispatched,
}

class PanicTriggerResult {
  const PanicTriggerResult({
    required this.phase,
    required this.pressCount,
    required this.message,
    required this.shouldVibrate,
    required this.shouldStartEmergency,
    required this.shouldCallPolice,
    required this.shouldCallAmbulance,
    required this.shouldBroadcastOffline,
  });

  final PanicTriggerPhase phase;
  final int pressCount;
  final String message;
  final bool shouldVibrate;
  final bool shouldStartEmergency;
  final bool shouldCallPolice;
  final bool shouldCallAmbulance;
  final bool shouldBroadcastOffline;
}

class PanicTriggerService {
  static const Duration _sequenceWindow = Duration(seconds: 5);

  int _pressCount = 0;
  bool _vibrationSent = false;
  bool _policeDispatched = false;
  bool _ambulanceDispatched = false;
  DateTime? _sequenceStartedAt;

  PanicTriggerResult recordPress() {
    final now = DateTime.now();
    if (_sequenceStartedAt == null || now.difference(_sequenceStartedAt!) > _sequenceWindow) {
      reset();
      _sequenceStartedAt = now;
    }

    _pressCount += 1;

    if (_pressCount < 3) {
      return PanicTriggerResult(
        phase: PanicTriggerPhase.idle,
        pressCount: _pressCount,
        message: 'Press power $_pressCount more time(s) to arm silent mode.',
        shouldVibrate: false,
        shouldStartEmergency: false,
        shouldCallPolice: false,
        shouldCallAmbulance: false,
        shouldBroadcastOffline: false,
      );
    }

    if (_pressCount == 3 && !_vibrationSent) {
      _vibrationSent = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.armed,
        pressCount: _pressCount,
        message: 'Silent mode armed. Press once more to call police.',
        shouldVibrate: true,
        shouldStartEmergency: false,
        shouldCallPolice: false,
        shouldCallAmbulance: false,
        shouldBroadcastOffline: false,
      );
    }

    if (_pressCount == 4 && !_policeDispatched) {
      _policeDispatched = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.policeDispatched,
        pressCount: _pressCount,
        message: 'Police dispatch started. Press one more time for ambulance and safety help.',
        shouldVibrate: false,
        shouldStartEmergency: true,
        shouldCallPolice: true,
        shouldCallAmbulance: false,
        shouldBroadcastOffline: true,
      );
    }

    if (_pressCount >= 5 && !_ambulanceDispatched) {
      _ambulanceDispatched = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.ambulanceDispatched,
        pressCount: _pressCount,
        message: 'Ambulance and nearest-hospital support are being added.',
        shouldVibrate: false,
        shouldStartEmergency: true,
        shouldCallPolice: !_policeDispatched,
        shouldCallAmbulance: true,
        shouldBroadcastOffline: true,
      );
    }

    return PanicTriggerResult(
      phase: PanicTriggerPhase.ambulanceDispatched,
      pressCount: _pressCount,
      message: 'Silent response is already active.',
      shouldVibrate: false,
      shouldStartEmergency: false,
      shouldCallPolice: false,
      shouldCallAmbulance: false,
      shouldBroadcastOffline: false,
    );
  }

  void reset() {
    _pressCount = 0;
    _vibrationSent = false;
    _policeDispatched = false;
    _ambulanceDispatched = false;
    _sequenceStartedAt = null;
  }
}