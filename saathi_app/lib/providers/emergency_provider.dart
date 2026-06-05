import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

import '../models/chat_message.dart';
import '../models/emergency.dart';
import '../models/responder.dart';
import '../models/user.dart';
import '../services/panic_trigger_service.dart';
import '../services/chat_service.dart';
import '../services/emergency_service.dart';
import '../utils/emergency_timer.dart';

class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider(this._emergencyService, this._chatService);

  final EmergencyService _emergencyService;
  final ChatService _chatService;
  final PanicTriggerService _panicTriggerService = PanicTriggerService();
  final EmergencyTimer _timer = EmergencyTimer();

  EmergencyEvent? _currentEmergency;
  List<ResponderAssignment> _responders = const [];
  List<ChatMessage> _messages = const [];
  Duration _remaining = const Duration(minutes: 10);
  String _panicStatus = 'Tap once to arm silent mode, then tap once for police + contacts or twice for ambulance + responders.';
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  EmergencyEvent? get currentEmergency => _currentEmergency;
  List<ResponderAssignment> get responders => _responders;
  List<ChatMessage> get messages => _messages;
  Duration get remaining => _remaining;
  String get panicStatus => _panicStatus;
  List<String> get activityLog => _emergencyService.activityLog;

  bool get hasActiveEmergency => _currentEmergency != null && _currentEmergency!.status == EmergencyStatus.active;

  String roleLabel(ResponderRole role) => _emergencyService.buildResponderRoleText(role);

  Future<void> registerSilentPress({required SaathiUser victim}) async {
    final result = _panicTriggerService.recordPress();
    _panicStatus = result.message;

    if (result.shouldVibrate) {
      final canVibrate = await Vibration.hasVibrator() ?? false;
      if (canVibrate) {
        await Vibration.vibrate(duration: 80);
      }
    }

    if (result.shouldStartEmergency && _currentEmergency == null) {
      await startEmergency(dangerLevel: '4', victim: victim);
    }

    if (result.shouldNotifyContacts) {
      await _emergencyService.notifyEmergencyContacts(reason: 'Emergency contacts notified via silent trigger');
    }

    if (result.shouldBroadcastOffline) {
      await _emergencyService.broadcastEncryptedChain();
    }

    if (result.shouldCallPolice) {
      await _emergencyService.dispatchPoliceCall();
    }

    if (result.shouldCallAmbulance) {
      await _emergencyService.dispatchAmbulanceAndSafety();
    }

    notifyListeners();
  }

  Future<void> startEmergency({required String dangerLevel, required SaathiUser victim}) async {
    final emergency = await _emergencyService.startEmergency(dangerLevel: dangerLevel, victim: victim);
    _currentEmergency = emergency;
    _responders = _emergencyService.responders;
    await _chatService.createChatRoom(emergency.id);
    await _chatService.sendMessage(
      emergencyId: emergency.id,
      senderId: victim.id,
      senderName: victim.name,
      text: 'Emergency activated. Location shared with nearby Saathi users.',
      type: 'system',
    );
    _bindMessages(emergency.id);
    _timer.start(
      (remaining) {
        _remaining = remaining;
        notifyListeners();
      },
      onCompleted: () {
        endEmergency();
      },
    );
    notifyListeners();
  }

  Future<void> cancelEmergency() async {
    if (_currentEmergency == null) {
      return;
    }
    final emergencyId = _currentEmergency!.id;
    _currentEmergency = await _emergencyService.cancelEmergency(emergencyId);
    await _chatService.sendMessage(
      emergencyId: emergencyId,
      senderId: _currentEmergency!.userId,
      senderName: 'System',
      text: 'Emergency cancelled by the victim.',
      type: 'system',
    );
    _timer.stop();
    notifyListeners();
  }

  Future<void> endEmergency() async {
    if (_currentEmergency == null) {
      return;
    }
    final emergencyId = _currentEmergency!.id;
    await _emergencyService.markResolved();
    _timer.stop();
    _currentEmergency = _currentEmergency!.copyWith(status: EmergencyStatus.resolved);
    await _chatService.sendMessage(
      emergencyId: emergencyId,
      senderId: _currentEmergency!.userId,
      senderName: 'System',
      text: 'Emergency resolved. Thank you for responding.',
      type: 'system',
    );
    notifyListeners();
  }

  Future<void> assignResponder(String responderId) async {
    if (_currentEmergency == null) {
      return;
    }
    await _emergencyService.assignResponder(responderId);
    _responders = _emergencyService.responders;
    final responder = _responders.firstWhere((item) => item.userId == responderId);
    await _chatService.sendMessage(
      emergencyId: _currentEmergency!.id,
      senderId: responder.userId,
      senderName: responder.name,
      text: '[${_emergencyService.buildResponderRoleText(responder.role)}] I\'m coming.',
      type: 'system',
    );
    notifyListeners();
  }

  Future<void> sendMessage({required String senderId, required String senderName, required String text}) async {
    if (_currentEmergency == null) {
      return;
    }
    await _chatService.sendMessage(
      emergencyId: _currentEmergency!.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );
    notifyListeners();
  }

  void _bindMessages(String emergencyId) {
    _chatSubscription?.cancel();
    _chatSubscription = _chatService.getChatMessages(emergencyId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer.stop();
    _chatSubscription?.cancel();
    super.dispose();
  }
}
