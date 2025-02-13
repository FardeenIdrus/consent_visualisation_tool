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
        // First show informed consent
        final informedConsent = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => InformedConsentDialog(),
        );
        if (informedConsent != true) return false;

        // Then get affirmative consent
        final affirmativeConsent = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AffirmativeConsentDialog(isSender: true),
        );
        if (affirmativeConsent != true) return false;

        return _addMessage(
          text,
          imageBytes,
          additionalData: {'requiresRecipientConsent': true}
        );

      case 'Dynamic Consent':
        final settings = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => DynamicConsentDialog(),
        );
        
        if (settings == null) return false;
        
        return _addMessage(text, imageBytes, additionalData: settings);

      case 'Implied Consent':
        // Simply send the message without any confirmation
        return _addMessage(text, imageBytes);

      default:
        return false;
    }
  }

  Future<bool> deleteMessage(SimulationMessage message) async {
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
class InformedConsentDialog extends StatefulWidget {
  @override
  _InformedConsentDialogState createState() => _InformedConsentDialogState();
}

class _InformedConsentDialogState extends State<InformedConsentDialog> {
  // Risk understanding checkboxes
  bool _understandPermanence = false;
  bool _understandDistribution = false;
  bool _understandControlRisks = false;
  bool _understandFutureImpact = false;
  bool _understandSecurityRisks = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Informed Consent for Image Sharing',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please carefully review and acknowledge the following risks:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            // Risk Disclosure Sections
            _buildRiskDisclosureSection(
              title: 'Digital Permanence',
              description: 'Once shared, images can persist indefinitely in digital spaces.',
              value: _understandPermanence,
              onChanged: (value) => setState(() => _understandPermanence = value!),
            ),
            
            _buildRiskDisclosureSection(
              title: 'Distribution Risks',
              description: 'Images can be copied, saved, or redistributed without your direct control.',
              value: _understandDistribution,
              onChanged: (value) => setState(() => _understandDistribution = value!),
            ),
            
            _buildRiskDisclosureSection(
              title: 'Control Limitations',
              description: 'You have limited ability to control the spread of shared images.',
              value: _understandControlRisks,
              onChanged: (value) => setState(() => _understandControlRisks = value!),
            ),
            
            _buildRiskDisclosureSection(
              title: 'Future Impact',
              description: 'Shared images may have long-term consequences for personal and professional life.',
              value: _understandFutureImpact,
              onChanged: (value) => setState(() => _understandFutureImpact = value!),
            ),
            
            _buildRiskDisclosureSection(
              title: 'Security Risks',
              description: 'There is a potential for third-party interception or unauthorized access.',
              value: _understandSecurityRisks,
              onChanged: (value) => setState(() => _understandSecurityRisks = value!),
            ),
            
            SizedBox(height: 16),
            
            // Additional Information Section
            Text(
              'Key Implications:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '• Images may be stored indefinitely\n'
                '• Content can be shared without your explicit consent\n'
                '• Potential future reputational risks',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _allRisksAcknowledged()
            ? () => Navigator.of(context).pop(true)
            : null,
          child: Text('I Understand All Risks'),
        ),
      ],
    );
  }

  Widget _buildRiskDisclosureSection({
    required String title,
    required String description,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(color: Colors.grey[700]),
          ),
          value: value,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        Divider(height: 1),
      ],
    );
  }

  bool _allRisksAcknowledged() {
    return _understandPermanence &&
           _understandDistribution &&
           _understandControlRisks &&
           _understandFutureImpact &&
           _understandSecurityRisks;
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

class DynamicConsentDialog extends StatefulWidget {
  @override
  _DynamicConsentDialogState createState() => _DynamicConsentDialogState();
}

class _DynamicConsentDialogState extends State<DynamicConsentDialog> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hoursController.text = '24'; // Default to 24 hours
    _minutesController.text = '0';
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dynamic Consent Interval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set how often you want to reconfirm consent',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoursController,
                  decoration: InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Consent will be reconfirmed every '
            '${_hoursController.text} hours and ${_minutesController.text} minutes',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = int.tryParse(_hoursController.text) ?? 24;
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            
            Navigator.of(context).pop({
              'consentIntervalHours': hours,
              'consentIntervalMinutes': minutes,
              'lastConsentTime': DateTime.now().toIso8601String(),
              'allowDeletion': true,
              'isVisible': true,
            });
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
class GranularConsentDialog extends StatefulWidget {
  const GranularConsentDialog({super.key});

  @override
  _GranularConsentDialogState createState() => _GranularConsentDialogState();
}

class _GranularConsentDialogState extends State<GranularConsentDialog> {
  final Map<String, dynamic> settings = {
    'allowSaving': false,
    'allowForwarding': false,
    'timeLimit': false,
    'timeLimitMinutes': 60,
    'allowScreenshots': false,
    'addWatermark': false,
    'viewingDuration': false,
    'viewingDurationMinutes': 5,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detailed Sharing Permissions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure detailed permissions:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            
            _buildPermissionSection('Content Access'),
            SwitchListTile(
              title: Text('Allow Saving'),
              subtitle: Text('Recipient can save the content locally'),
              value: settings['allowSaving'],
              onChanged: (value) => setState(() => settings['allowSaving'] = value),
            ),
            SwitchListTile(
              title: Text('Allow Screenshots'),
              subtitle: Text('Recipient can capture screenshots'),
              value: settings['allowScreenshots'],
              onChanged: (value) => setState(() => settings['allowScreenshots'] = value),
            ),
            
            _buildPermissionSection('Sharing Controls'),
            SwitchListTile(
              title: Text('Allow Forwarding'),
              subtitle: Text('Recipient can forward the content'),
              value: settings['allowForwarding'],
              onChanged: (value) => setState(() => settings['allowForwarding'] = value),
            ),
            SwitchListTile(
              title: Text('Add Watermark'),
              subtitle: Text('Add recipient identifier watermark'),
              value: settings['addWatermark'],
              onChanged: (value) => setState(() => settings['addWatermark'] = value),
            ),
            
            _buildPermissionSection('Time Restrictions'),
            SwitchListTile(
              title: Text('Content Expiry'),
              subtitle: Text('Content will be deleted after set time'),
              value: settings['timeLimit'],
              onChanged: (value) => setState(() => settings['timeLimit'] = value),
            ),
            if (settings['timeLimit'])
              _buildTimeSlider(
                'Delete after (minutes):',
                'timeLimitMinutes',
                180,
              ),
            
            SwitchListTile(
              title: Text('Viewing Time Limit'),
              subtitle: Text('Limit single viewing session duration'),
              value: settings['viewingDuration'],
              onChanged: (value) => setState(() => settings['viewingDuration'] = value),
            ),
            if (settings['viewingDuration'])
              _buildTimeSlider(
                'Max viewing time (minutes):',
                'viewingDurationMinutes',
                30,
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
          child: Text('Apply Settings'),
        ),
      ],
    );
  }

  Widget _buildPermissionSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTimeSlider(String label, String settingKey, double maxValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: settings[settingKey].toDouble(),
                  min: 1,
                  max: maxValue,
                  divisions: maxValue.toInt() - 1,
                  label: '${settings[settingKey]} min',
                  onChanged: (value) {
                    setState(() => settings[settingKey] = value.round());
                  },
                ),
              ),
              Text('${settings[settingKey]}m'),
            ],
          ),
        ],
      ),
    );
  }
}

