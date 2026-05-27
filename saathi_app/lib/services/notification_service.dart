class NotificationService {
  bool _initialized = false;
  String? _lastNotification;

  bool get initialized => _initialized;
  String? get lastNotification => _lastNotification;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<void> requestPermission() async {}

  Future<String> getFcmToken() async {
    return 'demo-fcm-token';
  }

  Future<void> storeToken(String userId, String token) async {}

  Future<void> showEmergencyNotification(String title, String body) async {
    _lastNotification = '$title: $body';
  }
}
