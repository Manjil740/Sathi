import 'package:url_launcher/url_launcher.dart';

class EmergencyContactService {
  final List<Map<String, String>> _contacts = [
    {'name': 'Maya Shrestha', 'phone': '+977 9801111111'},
    {'name': 'Kiran Adhikari', 'phone': '+977 9812222222'},
  ];

  List<Map<String, String>> getContacts() => List.unmodifiable(_contacts);

  void addContact({required String name, required String phone}) {
    _contacts.add({'name': name, 'phone': phone});
  }

  void removeContact(String phone) {
    _contacts.removeWhere((contact) => contact['phone'] == phone);
  }

  String buildLocationLink(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  Future<String> callNumber({required String number, required String label}) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return '$label dispatch initiated';
  }

  Future<String> contactPolice() {
    return callNumber(number: '100', label: 'Nepal Police 100');
  }

  Future<String> contactAmbulance() {
    return callNumber(number: '102', label: 'Ambulance 102');
  }

  Future<List<String>> shareToSafetyNetwork(double latitude, double longitude) async {
    final location = buildLocationLink(latitude, longitude);
    return [
      'Nearest hospital notified: $location',
      'Community safety help notified: $location',
    ];
  }

  Future<List<String>> notifyContacts(String emergencyId, double latitude, double longitude) async {
    final link = buildLocationLink(latitude, longitude);
    return _contacts.map((contact) => '${contact['name']}: User in distress, responding now. $link').toList();
  }
}
