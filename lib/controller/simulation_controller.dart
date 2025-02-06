import 'dart:typed_data';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/simulation_model.dart';
import 'package:flutter/material.dart';

class SimulationController {
  final SimulationModel model;
  final BuildContext context;

  SimulationController(this.model, this.context);

  Future<bool> sendMessage(String? text, {Uint8List? imageBytes}) async {
    // Handle different consent models
    if (model.currentModel == null) return false;

    switch (model.currentModel!.name) {
      case 'Informed Consent':
        return await _handleInformedConsent(text, imageBytes);
      case 'Granular Consent':
        return await _handleGranularConsent(text, imageBytes);
      case 'Dynamic Consent':
        return await _handleDynamicConsent(text, imageBytes);
      case 'Affirmative Consent':
        return await _handleAffirmativeConsent(text, imageBytes);
      case 'Implied Consent':
        return await _handleImpliedConsent(text, imageBytes);
      default:
        return false;
    }
  }

  Future<bool> _handleInformedConsent(String? text, Uint8List? imageBytes) async {
    final consented = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Informed Consent Required'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Before sending this content, please understand the following risks:'),
              SizedBox(height: 16),
              ...informedConsentRisks.map((risk) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text(risk)),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('I Understand and Consent'),
          ),
        ],
      ),
    );

    if (consented ?? false) {
      return _addMessage(text, imageBytes);
    }
    return false;
  }

  Future<bool> _handleGranularConsent(String? text, Uint8List? imageBytes) async {
    final settings = await showDialog<Map<String, bool>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GranularConsentDialog(),
    );

    if (settings != null) {
      // Store consent settings with the message
      return _addMessage(text, imageBytes, additionalData: settings);
    }
    return false;
  }

  Future<bool> _handleDynamicConsent(String? text, Uint8List? imageBytes) async {
    // Implement dynamic consent dialog
    return _addMessage(text, imageBytes);
  }

  Future<bool> _handleAffirmativeConsent(String? text, Uint8List? imageBytes) async {
    // Implement affirmative consent dialog
    return _addMessage(text, imageBytes);
  }

  Future<bool> _handleImpliedConsent(String? text, Uint8List? imageBytes) async {
    // For implied consent, just send the message without any confirmation
    return _addMessage(text, imageBytes);
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

  static const List<String> informedConsentRisks = [
    'Once sent, content can be saved or copied by recipients',
    'Digital content may persist indefinitely',
    'Images can be manipulated or shared without your knowledge',
    'Content may be intercepted during transmission',
    'Storage services may retain copies of your content',
  ];
}

class GranularConsentDialog extends StatefulWidget {
  @override
  _GranularConsentDialogState createState() => _GranularConsentDialogState();
}

class _GranularConsentDialogState extends State<GranularConsentDialog> {
  final Map<String, bool> settings = {
    'allowSaving': false,
    'allowForwarding': false,
    'timeLimit': false,
    'watermark': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Sharing Permissions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: settings.entries.map((entry) => 
          CheckboxListTile(
            title: Text(_getSettingTitle(entry.key)),
            value: entry.value,
            onChanged: (value) {
              setState(() {
                settings[entry.key] = value ?? false;
              });
            },
          ),
        ).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(settings),
          child: Text('Confirm Settings'),
        ),
      ],
    );
  }

  String _getSettingTitle(String key) {
    switch (key) {
      case 'allowSaving':
        return 'Allow Saving';
      case 'allowForwarding':
        return 'Allow Forwarding';
      case 'timeLimit':
        return 'Enable Time Limit';
      case 'watermark':
        return 'Add Watermark';
      default:
        return key;
    }
  }
}