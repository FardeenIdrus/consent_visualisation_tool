import 'dart:typed_data';
import 'dart:async';
import 'package:consent_visualisation_tool/model/consent_models.dart';

/// Data class representing a chat message in the simulation.
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

/// Enumeration of message types.
enum MessageType { text, image }

/// Model that holds the list of messages and manages expiry logic.
class SimulationModel {
  List<SimulationMessage> messages = [];
  ConsentModel? currentModel;
  Timer? _expiryTimer;
  final _messageController = StreamController<List<SimulationMessage>>.broadcast();

  SimulationModel() {
    _expiryTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkExpiredMessages();
    });
  }

  Stream<List<SimulationMessage>> get messageStream => _messageController.stream;

  void notifyListeners() {
    _messageController.add(messages);
  }

  void _checkExpiredMessages() {
    bool hasExpired = false;
    final now = DateTime.now();
    messages.removeWhere((message) {
      if (message.consentModel?.name == 'Granular Consent' &&
          message.additionalData?['timeLimit'] == true) {
        final minutes = message.additionalData!['timeLimitMinutes'] as int;
        final expiryTime = message.timestamp.add(Duration(minutes: minutes));
        if (now.isAfter(expiryTime)) {
          hasExpired = true;
          return true;
        }
      }
      return false;
    });
    if (hasExpired) {
      notifyListeners();
    }
  }

  void addMessage(SimulationMessage message) {
    messages.add(message);
    notifyListeners();
  }

  void deleteMessage(SimulationMessage message) {
    messages.remove(message);
    notifyListeners();
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  void dispose() {
    _expiryTimer?.cancel();
    _messageController.close();
  }
}




