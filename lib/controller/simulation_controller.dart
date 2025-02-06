import 'dart:typed_data';
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
      final acknowledged = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => InformedConsentDialog(),
      );

      // If acknowledged is null or false, user cancelled or did not acknowledge risks
      if (acknowledged != true) return false;

      return _addMessage(text, imageBytes);

      case 'Dynamic Consent':
        // Implement dynamic consent dialog
        return _addMessage(text, imageBytes);

      case 'Affirmative Consent':
        // First get sender's explicit consent
        final senderConsent = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AffirmativeConsentDialog(isSender: true),
        );

        // If sender didn't consent, cancel sending
        if (senderConsent != true) return false;

        // Add message with pending recipient consent flag
        return _addMessage(
          text,
          imageBytes,
          additionalData: {'requiresRecipientConsent': true}
        );


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
  const InformedConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Informed Consent'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before sending this message, please review the potential risks:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Risk of data being shared with third parties.\n'
              '2. Risk of data being stored indefinitely.\n'
              '3. Risk of data being used for unintended purposes.\n',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'By clicking "I understand the risks", you acknowledge these risks and agree to proceed.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true), // Acknowledge
          child: const Text('I understand the risks'),
        ),
      ],
    );
  }
}

class AffirmativeConsentDialog extends StatelessWidget {
  final bool isSender;
  
  const AffirmativeConsentDialog({super.key, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isSender ? 'Request to Share Image' : 'Request to View Image'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSender 
                ? 'Do you explicitly agree to share this image?' 
                : 'A user wants to share an image with you. Do you explicitly agree to view it?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Building upon informed consent by providing clear information
            Text(
              'By agreeing, you acknowledge:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSender
                ? '• The image will be shared with the recipient\n'
                  '• You have the right to revoke consent\n'
                  '• You have willingly chosen to share this content'
                : '• You will receive an image from the sender\n'
                  '• You can decline to view the content\n'
                  '• You are under no obligation to agree',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No, I Do Not Agree'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes, I Explicitly Agree'),
        ),
      ],
    );
  }
}


class GranularConsentDialog extends StatefulWidget {
  const GranularConsentDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
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