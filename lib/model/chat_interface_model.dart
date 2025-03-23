import 'dart:typed_data';
import 'dart:async';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:flutter/material.dart';

/// Represents a message within the chat simulation.
/// Contains content, metadata, and consent-related information.
class SimulationMessage {
  final String content;
  final MessageType type;
  final Uint8List? imageData;
  final ConsentModel? consentModel;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;
  final SimulationMessage? forwardedFrom;

  SimulationMessage({
    required this.content,
    required this.type,
    this.imageData,
    this.consentModel,
    this.additionalData,
    this.forwardedFrom,
  }) : timestamp = DateTime.now();
}

/// Defines the types of messages that can be exchanged in the simulation.
enum MessageType { text, image }

/// Model that manages the state of the chat simulation.
/// Handles messages, consent reassessment, and expiry timers.
class SimulationModel {
  List<SimulationMessage> messages = [];
  ConsentModel? currentModel;
  Timer? _expiryTimer;
  final _messageController = StreamController<List<SimulationMessage>>.broadcast();
  final BuildContext context;
  bool _isShowingDialog = false;  // Add flag to prevent multiple dialogs
  List<SimulationMessage> forwardedMessages = [];
  final Function isSenderActive;

  /// Creates a new SimulationModel with the given context and tab state function.
  /// @param context The BuildContext for showing dialogs
  /// @param isSenderActive Function that returns true when on the sender tab
SimulationModel(this.context, this.isSenderActive) {

    // Check every second for both expired messages and consent re-evaluation
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpiredMessages();
      _checkDynamicConsent();
    });
}

/// Adds a message to the forwarded messages list to simulate sharing with a third party.
void addForwardedMessage(SimulationMessage message) {
    forwardedMessages.add(message);
    // Notify listeners that a new message has been forwarded
    _messageController.add(messages);
  }

  /// Stream of messages that listeners can subscribe to for updates.
  Stream<List<SimulationMessage>> get messageStream => _messageController.stream;

/// Notifies listeners that the message data has changed.
   void notifyListeners() {
    _messageController.add(messages);
  }

 /// Checks for and removes messages that have expired due to time limits.
void _checkExpiredMessages() {
  bool hasExpired = false;
  final now = DateTime.now();
  
  messages.removeWhere((message) {
    if (message.consentModel?.name == 'Granular Consent' &&
        message.additionalData?['timeLimit'] == true) {
      final minutes = message.additionalData!['timeLimitMinutes'] as int? ?? 0;
      final seconds = message.additionalData!['timeLimitSeconds'] as int? ?? 0;
      
      // Ensure at least 1 second total duration
      int totalSeconds = (minutes * 60) + seconds;
      if (totalSeconds <= 0) totalSeconds = 1;
      
      final expiryTime = message.timestamp.add(Duration(seconds: totalSeconds));
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

/// Public method to trigger a dynamic consent check manually.
/// Used when switching tabs to ensure proper consent state.
 void checkDynamicConsent() {
    _checkDynamicConsent();
  }

  /// Checks for messages that need consent reassessment and handles dialog display.
  /// When consent reassessment time has elapsed:
  /// 1. Hides the image for recipients
  /// 2. Shows a reassessment dialog to the sender (if on sender tab)
  /// 3. Updates visibility based on sender's decision
Future<void> _checkDynamicConsent() async {
  if (_isShowingDialog) return;
  
  final now = DateTime.now();

  for (var message in List<SimulationMessage>.from(messages)) {
    if (message.consentModel?.name == 'Dynamic Consent' &&
        message.additionalData != null) {
      
      final lastConsentTime = DateTime.parse(message.additionalData!['lastConsentTime']);
      final totalSeconds = message.additionalData!['totalSeconds'] as int;
      final nextConsentTime = lastConsentTime.add(Duration(seconds: totalSeconds));

      if (now.isAfter(nextConsentTime)) {
        // If it's still marked as visible, update it to not visible
        if (message.additionalData!['isVisible'] == true) {
          message.additionalData!['isVisible'] = false;
          _messageController.add(messages); // Notify listeners that visibility changed
        }
        
        // Only show the dialog if on the sender tab
        if (context.mounted && !_isShowingDialog && isSenderActive()) {
          _isShowingDialog = true;

          try {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              barrierDismissible: false,
              useRootNavigator: true,
              builder: (dialogContext) => _DynamicConsentReassessmentDialog(
                totalSeconds: totalSeconds,
              ),
            );

            if (result != null) {
              if (result['continue'] == true) {
                // Use the moment of user confirmation as the new last consent time
                final confirmationTime = DateTime.now();
                message.additionalData!['lastConsentTime'] = confirmationTime.toIso8601String();
                
                // Make the image visible again since consent was continued
                message.additionalData!['isVisible'] = true;
                
                // If a new total seconds is provided, update it
                if (result.containsKey('newTotalSeconds') && result['newTotalSeconds'] != null) {
                  message.additionalData!['totalSeconds'] = result['newTotalSeconds'];
                }
              } else {
                deleteMessage(message);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image has been deleted'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            }
          } finally {
            _isShowingDialog = false;
            _messageController.add(messages); // Notify listeners of state change
          }
        }
      }
    }
  }
}


 /// Adds a new message to the chat and notifies listeners.
  void addMessage(SimulationMessage message) {
    messages.add(message);
    _messageController.add(messages);
  }

/// Removes a message from the chat and notifies listeners.
  void deleteMessage(SimulationMessage message) {
    messages.remove(message);
    _messageController.add(messages);
  }

/// Clears all messages from the simulation including forwarded messages.
 void clearMessages() {
    messages.clear();
    forwardedMessages.clear(); // Clear forwarded messages as well
    _messageController.add(messages);
  }

 /// Releases resources when the model is no longer needed.
  void dispose() {
    _expiryTimer?.cancel();
    _messageController.close();
  }

  
}

/// Dialog displayed when dynamic consent requires reassessment.
/// Allows the user to continue sharing or revoke consent.
class _DynamicConsentReassessmentDialog extends StatefulWidget {
  final int totalSeconds;

  const _DynamicConsentReassessmentDialog({required this.totalSeconds});

  @override
  _DynamicConsentReassessmentDialogState createState() =>
      _DynamicConsentReassessmentDialogState();
}

class _DynamicConsentReassessmentDialogState
    extends State<_DynamicConsentReassessmentDialog> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    
    // Calculate hours, minutes, and seconds from total seconds
    final hours = widget.totalSeconds ~/ 3600;
    final minutes = (widget.totalSeconds % 3600) ~/ 60;
    final seconds = widget.totalSeconds % 60;

    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
    _secondsController = TextEditingController(text: seconds.toString());
  }

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
      title: const Text('Consent Re-evaluation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Would you like to continue sharing this image?'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoursController,
                  decoration: const InputDecoration(labelText: 'Hours'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  decoration: const InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _secondsController,
                  decoration: const InputDecoration(labelText: 'Seconds'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Adjust the time for the next reassessment, or leave it unchanged.',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop({'continue': false}),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Revoke Consent'),
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
          child: const Text('Continue Sharing'),
        ),
      ],
    );
  }
}

