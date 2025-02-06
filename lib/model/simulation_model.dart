import 'dart:typed_data';
import 'dart:async';
import 'package:consent_visualisation_tool/model/consent_models.dart';

class SimulationMessage {
  final String content;
  final MessageType type;
  final Uint8List? imageData;
  final ConsentModel? consentModel;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  SimulationMessage({
    required this.content,
    required this.type,
    this.imageData,
    this.consentModel,
    this.additionalData,
  }) : timestamp = DateTime.now();
}

enum MessageType { text, image }

class SimulationModel {
  List<SimulationMessage> messages = [];
  ConsentModel? currentModel;
  Timer? _expiryTimer;
  final _messageController = StreamController<List<SimulationMessage>>.broadcast();

  SimulationModel() {
    // Check for expired messages more frequently (every second)
    _expiryTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkExpiredMessages();
    });
  }

  Stream<List<SimulationMessage>> get messageStream => _messageController.stream;

  void _checkExpiredMessages() {
    bool hasExpired = false;
    final now = DateTime.now();
    
    messages.removeWhere((message) {
      if (message.consentModel?.name == 'Granular Consent' &&
          message.additionalData?['timeLimit'] == true) {
        final minutes = message.additionalData!['timeLimitMinutes'] as int;
        final expiryTime = message.timestamp.add(Duration(minutes: minutes));
        final isExpired = now.isAfter(expiryTime);
        if (isExpired) hasExpired = true;
        return isExpired;
      }
      return false;
    });

    // Notify listeners if any messages were removed
    if (hasExpired) {
      _messageController.add(messages);
    }
  }

  void addMessage(SimulationMessage message) {
    messages.add(message);
    _messageController.add(messages);
  }

  void clearMessages() {
    messages.clear();
    _messageController.add(messages);
  }

  void dispose() {
    _expiryTimer?.cancel();
    _messageController.close();
  }
}