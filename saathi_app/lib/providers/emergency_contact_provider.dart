import 'package:flutter/foundation.dart';

import '../services/emergency_contact_service.dart';

class EmergencyContactProvider extends ChangeNotifier {
  EmergencyContactProvider(this._contactService);

  static const int maxContacts = 3;

  final EmergencyContactService _contactService;

  List<Map<String, String>> get contacts => _contactService.getContacts();

  bool get isFull => contacts.length >= maxContacts;

  bool hasContact(String phone) {
    final normalized = phone.trim();
    return contacts.any((contact) => contact['phone'] == normalized);
  }

  void addContact({required String name, required String phone}) {
    if (isFull) {
      return;
    }
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty || trimmedPhone.isEmpty) {
      return;
    }
    if (hasContact(trimmedPhone)) {
      return;
    }
    _contactService.addContact(name: trimmedName, phone: trimmedPhone);
    notifyListeners();
  }

  void removeContact(String phone) {
    _contactService.removeContact(phone.trim());
    notifyListeners();
  }
}
