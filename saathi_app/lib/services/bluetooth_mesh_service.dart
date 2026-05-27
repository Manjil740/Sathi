import 'dart:convert';

class BluetoothMeshService {
  bool _isBroadcasting = false;
  final List<Map<String, dynamic>> _relayedSignals = [];
  final List<Map<String, dynamic>> _encryptedRelayChain = [];

  bool get isBroadcasting => _isBroadcasting;
  List<Map<String, dynamic>> get relayedSignals => List.unmodifiable(_relayedSignals);
  List<Map<String, dynamic>> get encryptedRelayChain => List.unmodifiable(_encryptedRelayChain);

  Future<void> startBroadcast({required String userId, required Map<String, dynamic> payload}) async {
    _isBroadcasting = true;
    _relayedSignals.add({'user_id': userId, ...payload});
  }

  Future<Map<String, dynamic>> relayEncryptedSignal({
    required Map<String, dynamic> payload,
    required int hopCount,
    required String recipient,
  }) async {
    final envelope = _buildEncryptedEnvelope(
      payload: payload,
      hopCount: hopCount,
      recipient: recipient,
    );
    _encryptedRelayChain.add(envelope);
    return envelope;
  }

  Future<void> relaySignal(Map<String, dynamic> payload) async {
    _relayedSignals.add(payload);
  }

  Future<void> stopBroadcast() async {
    _isBroadcasting = false;
  }

  Map<String, dynamic> _buildEncryptedEnvelope({
    required Map<String, dynamic> payload,
    required int hopCount,
    required String recipient,
  }) {
    final encoded = base64Encode(utf8.encode(jsonEncode(payload)));
    return {
      'recipient': recipient,
      'hop_count': hopCount,
      'ciphertext': encoded,
      'encryption': 'demo-base64-envelope',
      'relayed_at': DateTime.now().toIso8601String(),
    };
  }
}
