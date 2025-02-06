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

  SimulationModel() {
    // Start a timer to check for expired messages every minute
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpiredMessages();
    });
  }

  void _checkExpiredMessages() {
    final now = DateTime.now();
    messages.removeWhere((message) {
      if (message.additionalData?['timeLimit'] == true) {
        final hours = message.additionalData!['timeLimitHours'] as int;
        final expiryTime = message.timestamp.add(Duration(hours: hours));
        return now.isAfter(expiryTime);
      }
      return false;
    });
  }

  void addMessage(SimulationMessage message) {
    messages.add(message);
  }

  void clearMessages() {
    messages.clear();
  }

  void dispose() {
    _expiryTimer?.cancel();
  }
}