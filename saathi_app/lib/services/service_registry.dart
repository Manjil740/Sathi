import 'auth_service.dart';
import 'bluetooth_mesh_service.dart';
import 'chat_service.dart';
import 'emergency_contact_service.dart';
import 'emergency_service.dart';
import 'location_service.dart';
import 'notification_service.dart';

class ServiceRegistry {
  ServiceRegistry()
      : locationService = LocationService(),
        notificationService = NotificationService(),
        bluetoothMeshService = BluetoothMeshService(),
        emergencyContactService = EmergencyContactService(),
        authService = AuthService(),
        chatService = ChatService() {
    emergencyService = EmergencyService(
      locationService: locationService,
      notificationService: notificationService,
      bluetoothMeshService: bluetoothMeshService,
      emergencyContactService: emergencyContactService,
    );
  }

  final LocationService locationService;
  final NotificationService notificationService;
  final BluetoothMeshService bluetoothMeshService;
  final EmergencyContactService emergencyContactService;
  final AuthService authService;
  final ChatService chatService;
  late final EmergencyService emergencyService;
}
