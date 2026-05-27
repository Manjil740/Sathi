import 'dart:async';

import '../models/chat_message.dart';

class ChatService {
  final Map<String, List<ChatMessage>> _messagesByEmergencyId = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  Future<String> createChatRoom(String emergencyId) async {
    _messagesByEmergencyId.putIfAbsent(emergencyId, () => <ChatMessage>[]);
    _controllers.putIfAbsent(
      emergencyId,
      () => StreamController<List<ChatMessage>>.broadcast(
        onListen: () {
          _controllers[emergencyId]?.add(List.unmodifiable(_messagesByEmergencyId[emergencyId] ?? []));
        },
      ),
    );
    return emergencyId;
  }

  Stream<List<ChatMessage>> getChatMessages(String emergencyId) {
    _messagesByEmergencyId.putIfAbsent(emergencyId, () => <ChatMessage>[]);
    return _controllers.putIfAbsent(
      emergencyId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    ).stream;
  }

  Future<void> sendMessage({
    required String emergencyId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
  }) async {
    final message = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
      type: type,
    );
    final messages = _messagesByEmergencyId.putIfAbsent(emergencyId, () => <ChatMessage>[]);
    messages.add(message);
    _controllers.putIfAbsent(emergencyId, () => StreamController<List<ChatMessage>>.broadcast()).add(List.unmodifiable(messages));
  }
}
