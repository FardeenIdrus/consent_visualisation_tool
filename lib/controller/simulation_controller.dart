import 'dart:typed_data';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/simulation_model.dart';
import 'package:flutter/material.dart';

class SimulationController {
  final SimulationModel model;
  final BuildContext context;

  SimulationController(this.model, this.context);

  Future<bool> sendMessage(String? text, {Uint8List? imageBytes}) async {
    if (model.currentModel == null) return false;

    switch (model.currentModel!.name) {
      case 'Granular Consent':
        final settings = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => GranularConsentDialog(),
        );
        
        // If settings is null, user cancelled
        if (settings == null) return false;
        
        return _addMessage(text, imageBytes, additionalData: settings);

      case 'Informed Consent':
        // Implement informed consent dialog
        return _addMessage(text, imageBytes);

      case 'Dynamic Consent':
        // Implement dynamic consent dialog
        return _addMessage(text, imageBytes);

      case 'Affirmative Consent':
        // Implement affirmative consent dialog
        return _addMessage(text, imageBytes);

      case 'Implied Consent':
        return _addMessage(text, imageBytes);

      default:
        return false;
    }
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
class InformedConsentDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Informed Consent'),
      content: Text('This is an informed consent dialog.'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
class GranularConsentDialog extends StatefulWidget {
  @override
  _GranularConsentDialogState createState() => _GranularConsentDialogState();
}

class _GranularConsentDialogState extends State<GranularConsentDialog> {
  final Map<String, dynamic> settings = {
    'allowSaving': false,
    'allowForwarding': false,
    'timeLimit': false,
    'timeLimitMinutes': 60,  // Default 60 minutes
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Sharing Permissions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control how your content can be accessed:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            
            // Permission switches
            SwitchListTile(
              title: Text('Allow Saving'),
              subtitle: Text('Recipient can save the content'),
              value: settings['allowSaving'],
              onChanged: (value) {
                setState(() {
                  settings['allowSaving'] = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Allow Forwarding'),
              subtitle: Text('Recipient can forward the content'),
              value: settings['allowForwarding'],
              onChanged: (value) {
                setState(() {
                  settings['allowForwarding'] = value;
                });
              },
            ),
            
            // Time limit settings
            SwitchListTile(
              title: Text('Enable Time Limit'),
              subtitle: Text('Content will be automatically deleted'),
              value: settings['timeLimit'],
              onChanged: (value) {
                setState(() {
                  settings['timeLimit'] = value;
                });
              },
            ),
            
            if (settings['timeLimit'])
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Limit (minutes):', 
                      style: Theme.of(context).textTheme.titleSmall
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: settings['timeLimitMinutes'].toDouble(),
                            min: 1,
                            max: 180,  // Max 3 hours in minutes
                            divisions: 179,
                            label: '${settings['timeLimitMinutes']} min',
                            onChanged: (value) {
                              setState(() {
                                settings['timeLimitMinutes'] = value.round();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 50,
                          child: Text(
                            '${settings['timeLimitMinutes']}m',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Message will be deleted after ${settings['timeLimitMinutes']} minutes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(settings),
          child: Text('Confirm Settings'),
        ),
      ],
    );
  }
}