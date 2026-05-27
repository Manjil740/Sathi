import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/live_location_map.dart';

class EmergencyChatScreen extends StatefulWidget {
  const EmergencyChatScreen({super.key});

  @override
  State<EmergencyChatScreen> createState() => _EmergencyChatScreenState();
}

class _EmergencyChatScreenState extends State<EmergencyChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final emergency = context.watch<EmergencyProvider>();
    final current = emergency.currentEmergency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Chat'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${emergency.remaining.inMinutes.toString().padLeft(2, '0')}:${(emergency.remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: current == null
          ? const Center(child: Text('No active emergency'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: LiveLocationMap(emergencyLocation: current.location, responders: emergency.responders),
                ),
                if (emergency.responders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('[${emergency.roleLabel(emergency.responders.first.role)}] You\'re assigned to approach.'),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: emergency.messages.length,
                    itemBuilder: (context, index) {
                      final message = emergency.messages[index];
                      final isMe = auth.user?.id == message.senderId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFDDF8EE) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message.senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(message.text),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          if (_messageController.text.trim().isEmpty) return;
                          await emergency.sendMessage(
                            senderId: auth.user?.id ?? 'victim_demo',
                            senderName: auth.user?.name ?? 'Aarav Shrestha',
                            text: _messageController.text.trim(),
                          );
                          _messageController.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing live location...'))),
                        child: const Text('Location'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await emergency.endEmergency();
                          if (!context.mounted) return;
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Emergency Over'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
