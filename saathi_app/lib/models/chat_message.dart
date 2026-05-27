class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.type,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String type;

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    String? type,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
