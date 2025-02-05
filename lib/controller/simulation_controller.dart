import 'dart:typed_data';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/simulation_model.dart';
import 'package:flutter/material.dart';


class SimulationController {
  final SimulationModel model;
  final BuildContext context;

  SimulationController(this.model, this.context);

  Future<bool> sendMessage(String? text, {Uint8List? imageBytes}) async {
    // Implement consent-specific logic here
    if (model.currentModel?.name == 'Informed Consent' && imageBytes != null) {
      final consented = await _showConsentDialog(imageBytes);
      if (!consented) return false;
    }

    final message = SimulationMessage(
      content: text ?? '',
      type: imageBytes != null ? MessageType.image : MessageType.text,
      imageData: imageBytes,
      consentModel: model.currentModel,
    );

    model.addMessage(message);
    return true;
  }

  Future<bool> _showConsentDialog(Uint8List imageBytes) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informed Consent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Potential Risks:'),
            ...risksForInformedConsent.map((risk) => 
              Text('• $risk')
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('I Understand'),
          ),
        ],
      ),
    ) ?? false;
  }

  void selectModel(ConsentModel model) {
    this.model.currentModel = model;
  }

  static final List<String> risksForInformedConsent = [
    'Images can be copied',
    'Permanent digital record',
    'Potential misuse',
    'Third-party interception',
  ];
}