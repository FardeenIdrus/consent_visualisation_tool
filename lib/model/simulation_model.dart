import 'dart:typed_data';
import 'dart:async';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:flutter/material.dart';
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
  Timer? _consentCheckTimer;
  final _messageController = StreamController<List<SimulationMessage>>.broadcast();
  final BuildContext context;

  SimulationModel(this.context) {
    // Check for expired messages every second
    _expiryTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkExpiredMessages();
    });
    
    // Check dynamic consent every minute
    _consentCheckTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkDynamicConsent();
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

    if (hasExpired) {
      _messageController.add(messages);
    }
  }

  void _checkDynamicConsent() async {
    for (var message in messages) {
      if (message.consentModel?.name == 'Dynamic Consent' &&
          message.additionalData != null &&
          message.additionalData!['isVisible'] == true) {
        
        final lastConsentTime = DateTime.parse(message.additionalData!['lastConsentTime']);
        final hours = message.additionalData!['consentIntervalHours'] as int;
        final minutes = message.additionalData!['consentIntervalMinutes'] as int;
        final nextConsentTime = lastConsentTime.add(
          Duration(hours: hours, minutes: minutes)
        );

        if (DateTime.now().isAfter(nextConsentTime)) {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Consent Reconfirmation'),
              content: Text('Would you like to continue sharing this image?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Revoke Consent'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Continue Sharing'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            message.additionalData!['lastConsentTime'] = DateTime.now().toIso8601String();
          } else {
            message.additionalData!['isVisible'] = false;
          }
          _messageController.add(messages);
        }
      }
    }
  }

  void addMessage(SimulationMessage message) {
    messages.add(message);
    _messageController.add(messages);
  }

  void deleteMessage(SimulationMessage message) {
    messages.remove(message);
    _messageController.add(messages);
  }

  void clearMessages() {
    messages.clear();
    _messageController.add(messages);
  }

  void dispose() {
    _expiryTimer?.cancel();
    _consentCheckTimer?.cancel();
    _messageController.close();
  }
}