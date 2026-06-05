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
    required this.shouldNotifyContacts,
    required this.shouldStartEmergency,
    required this.shouldCallPolice,
    required this.shouldCallAmbulance,
    required this.shouldBroadcastOffline,
  });

  final PanicTriggerPhase phase;
  final int pressCount;
  final String message;
  final bool shouldVibrate;
  final bool shouldNotifyContacts;
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

    if (_pressCount == 1 && !_vibrationSent) {
      _vibrationSent = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.armed,
        pressCount: _pressCount,
        message: 'Silent mode armed. Tap once to call police + contacts, twice for ambulance + nearby help.',
        shouldVibrate: true,
        shouldNotifyContacts: false,
        shouldStartEmergency: false,
        shouldCallPolice: false,
        shouldCallAmbulance: false,
        shouldBroadcastOffline: false,
      );
    }

    if (_pressCount == 2 && !_policeDispatched) {
      _policeDispatched = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.policeDispatched,
        pressCount: _pressCount,
        message: 'Police and close contacts alerted. Tap once more for ambulance + nearby responders.',
        shouldVibrate: false,
        shouldNotifyContacts: true,
        shouldStartEmergency: false,
        shouldCallPolice: true,
        shouldCallAmbulance: false,
        shouldBroadcastOffline: false,
      );
    }

    if (_pressCount >= 3 && !_ambulanceDispatched) {
      _ambulanceDispatched = true;
      return PanicTriggerResult(
        phase: PanicTriggerPhase.ambulanceDispatched,
        pressCount: _pressCount,
        message: 'Ambulance, police, and nearby Saathi responders are being connected.',
        shouldVibrate: false,
        shouldNotifyContacts: false,
        shouldStartEmergency: true,
        shouldCallPolice: true,
        shouldCallAmbulance: true,
        shouldBroadcastOffline: true,
      );
    }

    return PanicTriggerResult(
      phase: PanicTriggerPhase.ambulanceDispatched,
      pressCount: _pressCount,
      message: 'Silent response is already active.',
      shouldVibrate: false,
      shouldNotifyContacts: false,
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