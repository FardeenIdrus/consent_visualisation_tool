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
  final _messageController = StreamController<List<SimulationMessage>>.broadcast();
  final BuildContext context;
  bool _isShowingDialog = false;  // Add flag to prevent multiple dialogs

  SimulationModel(this.context) {
    // Check every second for both expired messages and consent re-evaluation
    _expiryTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkExpiredMessages();
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

Future<void> _checkDynamicConsent() async {
    if (_isShowingDialog) return;

    final now = DateTime.now();
    
    for (var message in List<SimulationMessage>.from(messages)) {
      if (message.consentModel?.name == 'Dynamic Consent' &&
          message.additionalData != null &&
          message.additionalData!['isVisible'] == true) {
        
        final lastConsentTime = DateTime.parse(message.additionalData!['lastConsentTime']);
        final totalSeconds = message.additionalData!['totalSeconds'] as int;
        final nextConsentTime = lastConsentTime.add(Duration(seconds: totalSeconds));

        // Debug print
        print('Current time: $now');
        print('Next consent time: $nextConsentTime');
        print('Time until next consent: ${nextConsentTime.difference(now)}');

        if (now.isAfter(nextConsentTime) && context.mounted && !_isShowingDialog) {
          _isShowingDialog = true;
          
          try {
            final confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              useRootNavigator: true,
              builder: (dialogContext) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Text('Consent Re-evaluation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Would you like to continue sharing this image?'),
                      SizedBox(height: 12),
                      Text(
                        _formatTimeSinceLastConsent(now.difference(lastConsentTime)),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text('Revoke Consent'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text('Continue Sharing'),
                    ),
                  ],
                ),
              ),
            );

            if (confirmed == true) {
              message.additionalData!['lastConsentTime'] = now.toIso8601String();
            } else {
              // Remove the message instead of just setting isVisible to false
              deleteMessage(message);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image has been deleted'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          } catch (e) {
            print('Error showing dialog: $e');
          } finally {
            _isShowingDialog = false;
          }
        }
      }
    }
  }

  String _formatTimeSinceLastConsent(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return 'Time since last consent: $hours hours, $minutes minutes, $seconds seconds';
    } else if (minutes > 0) {
      return 'Time since last consent: $minutes minutes, $seconds seconds';
    } else {
      return 'Time since last consent: $seconds seconds';
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
    _messageController.close();
  }
}
