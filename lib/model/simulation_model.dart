import 'dart:typed_data';
import 'package:consent_visualisation_tool/model/consent_models.dart';

class SimulationMessage {
  final String content;
  final MessageType type;
  final Uint8List? imageData;
  final ConsentModel? consentModel;
  final Map<String, dynamic>? additionalData;  // For storing consent-specific data

  SimulationMessage({
    required this.content,
    required this.type,
    this.imageData,
    this.consentModel,
    this.additionalData,
  });
}

enum MessageType { text, image }

class SimulationModel {
  List<SimulationMessage> messages = [];
  ConsentModel? currentModel;

  void addMessage(SimulationMessage message) {
    messages.add(message);
  }

  void clearMessages() {
    messages.clear();
  }
}