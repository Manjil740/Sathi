import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/emergency_contact_provider.dart';
import '../utils/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<EmergencyContactProvider>();
    final contacts = contactProvider.contacts;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Emergency Contacts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (contacts.isEmpty) const Text('No contacts added yet.'),
            ...contacts.map(
              (contact) => Card(
                child: ListTile(
                  leading: const Icon(Icons.contact_phone),
                  title: Text(contact['name'] ?? ''),
                  subtitle: Text(contact['phone'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context.read<EmergencyContactProvider>().removeContact(contact['phone'] ?? ''),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Contact name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Contact phone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (contactProvider.isFull) {
                  NotificationHelper.showSnackBar(context, 'Maximum of ${EmergencyContactProvider.maxContacts} contacts reached.');
                  return;
                }
                if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                  NotificationHelper.showSnackBar(context, 'Add a name and phone number first.');
                  return;
                }
                if (contactProvider.hasContact(_phoneController.text.trim())) {
                  NotificationHelper.showSnackBar(context, 'This contact is already saved.');
                  return;
                }
                context.read<EmergencyContactProvider>().addContact(
                      name: _nameController.text,
                      phone: _phoneController.text,
                    );
                _nameController.clear();
                _phoneController.clear();
              },
              child: const Text('Add contact'),
            ),
            const SizedBox(height: 24),
            const Text('Prototype toggles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Offline BLE mesh'),
              subtitle: const Text('Demo placeholder for flutter_blue_plus relay mode'),
            ),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Silent panic mode'),
              subtitle: const Text('Demo placeholder for locked-screen activation'),
            ),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Fake incoming call'),
              subtitle: const Text('Demo placeholder for callkit integration'),
            ),
          ],
        ),
      ),
    );
  }
}
