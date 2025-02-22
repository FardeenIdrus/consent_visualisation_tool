import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:consent_visualisation_tool/model/chat_interface_model.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart'; // For dialog widgets

/// Controller for the chat interface simulation.
class SimulationController {
  final SimulationModel model;
  SimulationController(this.model);

  /// Updates the settings attached to a message.
  void updateMessageSettings(SimulationMessage message, Map<String, dynamic> newSettings) {
    if (message.additionalData != null) {
      message.additionalData!.addAll(newSettings);
      model.notifyListeners();
    }
  }

  /// Sends a new message. Depending on the active consent model, it will invoke the appropriate dialog(s).
  Future<bool> sendMessage(String? text,
      {Uint8List? imageBytes, bool recipientRequested = false, required BuildContext context}) async {
    if (model.currentModel == null) return false;
    switch (model.currentModel!.name) {
      case 'Granular Consent':
        final settings = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => GranularConsentDialog(),
        );
        if (settings == null) return false;
        return _addMessage(text, imageBytes, additionalData: settings);
      case 'Informed Consent':
        final acknowledged = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => InformedConsentDialog(),
        );
        if (acknowledged != true) return false;
        return _addMessage(text, imageBytes);
      case 'Affirmative Consent':
        // First, show informed consent
        final informedConsent = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => InformedConsentDialog(),
        );
        if (informedConsent != true) return false;
        // Then require explicit affirmative consent
        final affirmativeConsent = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AffirmativeConsentDialog(isSender: true),
        );
        if (affirmativeConsent != true) return false;
        return _addMessage(text, imageBytes, additionalData: {'requiresRecipientConsent': !recipientRequested});
      case 'Dynamic Consent':
        final settings = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => DynamicConsentDialog(),
        );
        if (settings == null) return false;
        return _addMessage(text, imageBytes, additionalData: settings);
      case 'Implied Consent':
        return _addMessage(text, imageBytes);
      default:
        return false;
    }
  }

  /// Deletes a message after confirming with the user.
  Future<bool> deleteMessage(SimulationMessage message, BuildContext context) async {
    if (message.additionalData?['allowDeletion'] == true) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        model.deleteMessage(message);
        return true;
      }
    }
    return false;
  }

  bool _addMessage(String? text, Uint8List? imageBytes, {Map<String, dynamic>? additionalData}) {
    final message = SimulationMessage(
      content: text ?? '',
      type: imageBytes != null ? MessageType.image : MessageType.text,
      imageData: imageBytes,
      consentModel: model.currentModel,
      additionalData: additionalData,
    );
    model.addMessage(message);
    return true;
  }
}


