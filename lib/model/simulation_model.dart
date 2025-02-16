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

      if (now.isAfter(nextConsentTime) && context.mounted && !_isShowingDialog) {
        _isShowingDialog = true;

        try {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            barrierDismissible: false,
            useRootNavigator: true,
            builder: (dialogContext) => _DynamicConsentReassessmentDialog(),
          );

          if (result != null) {
            if (result['continue'] == true) {
              message.additionalData!['lastConsentTime'] = now.toIso8601String();
              if (result.containsKey('newTotalSeconds')) {
                message.additionalData!['totalSeconds'] = result['newTotalSeconds'];
              }
            } else {
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

  // In simulation_model.dart, add this method to the SimulationModel class:

// In simulation_model.dart add:

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

class _DynamicConsentReassessmentDialog extends StatefulWidget {
  @override
  _DynamicConsentReassessmentDialogState createState() =>
      _DynamicConsentReassessmentDialogState();
}

class _DynamicConsentReassessmentDialogState
    extends State<_DynamicConsentReassessmentDialog> {
  final TextEditingController _hoursController = TextEditingController(text: '0');
  final TextEditingController _minutesController = TextEditingController(text: '0');
  final TextEditingController _secondsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Consent Re-evaluation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Would you like to continue sharing this image?'),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoursController,
                  decoration: InputDecoration(labelText: 'Hours'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  decoration: InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _secondsController,
                  decoration: InputDecoration(labelText: 'Seconds'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Adjust the time for the next reassessment, or leave it unchanged.',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop({'continue': false}),
          child: Text('Revoke Consent'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = int.tryParse(_hoursController.text) ?? 0;
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            final seconds = int.tryParse(_secondsController.text) ?? 0;
            final newTotalSeconds = hours * 3600 + minutes * 60 + seconds;

            Navigator.of(context).pop({
              'continue': true,
              'newTotalSeconds': newTotalSeconds > 0 ? newTotalSeconds : null
            });
          },
          child: Text('Continue Sharing'),
        ),
      ],
    );
  }
}

