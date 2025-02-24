import 'dart:typed_data';
import 'package:consent_visualisation_tool/model/chat_interface_model.dart';
import 'package:flutter/material.dart';


class SimulationController {
  final SimulationModel model;
  final BuildContext context;

  SimulationController(this.model, this.context);

void updateMessageSettings(SimulationMessage message, Map<String, dynamic> newSettings) {
  if (message.additionalData != null) {
    message.additionalData!.addAll(newSettings);
    model.notifyListeners();
  }
}


  Future<bool> sendMessage(String? text, {Uint8List? imageBytes, bool recipientRequested = false}) async {
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
          additionalData: {'requiresRecipientConsent': !recipientRequested,}
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
  final List<Map<String, dynamic>> _riskItems = [
    {
      'title': 'Digital Permanence',
      'description': 'Once shared, images can persist indefinitely in digital spaces',
      'icon': Icons.cloud_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Distribution Risks',
      'description': 'Images can be copied, saved, or redistributed without direct control',
      'icon': Icons.share_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Control Limitations',
      'description': 'Limited ability to control the spread of shared images',
      'icon': Icons.lock_open_outlined,
      'color': Colors.red,
    },
    {
      'title': 'Future Impact',
      'description': 'Potential long-term consequences for personal and professional life',
      'icon': Icons.timeline_outlined,
      'color': Colors.purple,
    },
    {
      'title': 'Security Risks',
      'description': 'Potential for third-party interception or unauthorized access',
      'icon': Icons.security_outlined,
      'color': Colors.green,
    }
  ];

  // Checkbox state for each risk
  late List<bool> _riskAcknowledged;

  @override
  void initState() {
    super.initState();
    _riskAcknowledged = List.filled(_riskItems.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Informed Consent for Image Sharing',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please carefully review and acknowledge the following risks:',
              style: TextStyle(
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            
            // Risk Disclosure Cards
            ...List.generate(_riskItems.length, (index) {
              final risk = _riskItems[index];
              return _buildRiskCard(
                title: risk['title'],
                description: risk['description'],
                icon: risk['icon'],
                color: risk['color'],
                value: _riskAcknowledged[index],
                onChanged: (value) {
                  setState(() {
                    _riskAcknowledged[index] = value ?? false;
                  });
                },
              );
            }),
            
            SizedBox(height: 16),
            
            // Key Implications Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Key Implications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Images may be stored indefinitely\n'
                    '• Content can be shared without your explicit consent\n'
                    '• Potential future reputational risks',
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
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
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _allRisksAcknowledged()
            ? () => Navigator.of(context).pop(true)
            : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _allRisksAcknowledged() ? Colors.deepPurple : Colors.grey,
          ),
          child: Text('I Understand All Risks'),
        ),
      ],
    );
  }

  Widget _buildRiskCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: value ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        activeColor: color,
        checkColor: Colors.white,
      ),
    );
  }

  bool _allRisksAcknowledged() {
    return _riskAcknowledged.every((acknowledged) => acknowledged);
  }
}


class AffirmativeConsentDialog extends StatelessWidget {
  final bool isSender;
  
  const AffirmativeConsentDialog({Key? key, required this.isSender}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildDialogTitle(context),
      content: _buildDialogContent(context),
      actions: _buildDialogActions(context),
      contentPadding: EdgeInsets.all(24),
      actionsPadding: EdgeInsets.only(bottom: 16, right: 16, left: 16),
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSender ? Icons.send_outlined : Icons.visibility_outlined, 
              color: Colors.deepPurple,
              size: 32,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                isSender ? 'Request to Share Image' : 'Request to View Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConsentSection(context),
        SizedBox(height: 16),
        _buildRiskAcknowledgementSection(context),
      ],
    );
  }

  Widget _buildConsentSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSender 
              ? 'Confirming Intention to Share' 
              : 'Confirming Willingness to Receive',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            isSender
              ? 'You are about to share an intimate image. This requires explicit, enthusiastic agreement from you.'
              : 'An intimate image has been sent to you. You have the right to decline to view the image.',
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAcknowledgementSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'Important Considerations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• This is a voluntary action\n'
            '• No explanation is required for declining',
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[800],
        ),
        child: Text('Decline'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isSender ? 'Confirm Sharing' : 'Accept Image',
        ),
      ),
    ];
  }
}

class DynamicConsentDialog extends StatefulWidget {
  @override
  _DynamicConsentDialogState createState() => _DynamicConsentDialogState();
}

class _DynamicConsentDialogState extends State<DynamicConsentDialog> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hoursController.text = '0';
    _minutesController.text = '0';
    _secondsController.text = '0';
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
      title: Text('Set Consent Re-evaluation Interval'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How often should consent be re-evaluated?',
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
                      helperText: '0-48',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hours = int.tryParse(value) ?? 0;
                      if (hours > 48) {
                        _hoursController.text = '48';
                        _hoursController.selection = TextSelection.fromPosition(
                          TextPosition(offset: 2)
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    decoration: InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                      helperText: '0-59',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minutes = int.tryParse(value) ?? 0;
                      if (minutes > 59) {
                        _minutesController.text = '59';
                        _minutesController.selection = TextSelection.fromPosition(
                          TextPosition(offset: 2)
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    decoration: InputDecoration(
                      labelText: 'Seconds',
                      border: OutlineInputBorder(),
                      helperText: '0-59',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final seconds = int.tryParse(value) ?? 0;
                      if (seconds > 59) {
                        _secondsController.text = '59';
                        _secondsController.selection = TextSelection.fromPosition(
                          TextPosition(offset: 2)
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What this means:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• You\'ll be asked to review your consent after the set time\n'
                    '• You can choose to continue sharing or revoke access\n'
                    '• The image can be deleted at any time',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
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
          onPressed: () {
            final hours = int.tryParse(_hoursController.text) ?? 0;
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            final seconds = int.tryParse(_secondsController.text) ?? 0;
            
            Navigator.of(context).pop({
              'totalSeconds': hours * 3600 + minutes * 60 + seconds,
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
// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
class GranularConsentDialog extends StatefulWidget {
  final Map<String, dynamic>? initialSettings;
  final bool isModification;
  final Function(Map<String, dynamic>)? onSettingsUpdated;

  const GranularConsentDialog({
    super.key, 
    this.initialSettings,
    this.isModification = false,
    this.onSettingsUpdated,
  });

  @override
  _GranularConsentDialogState createState() => _GranularConsentDialogState();
}

class _GranularConsentDialogState extends State<GranularConsentDialog> {
  late Map<String, dynamic> settings;

  @override
  void initState() {
    super.initState();
    settings = widget.initialSettings?.cast<String, dynamic>() ?? {
      'allowSaving': false,
      'allowForwarding': false,
      'timeLimit': false,
      'timeLimitMinutes': 60,
      'allowScreenshots': false,
      'viewingDuration': false,
      'viewingDurationMinutes': 5,
    };
  }

  @override
Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isModification 
        ? 'Modify Sharing Permissions' 
        : 'Set Sharing Permissions'),
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
            
            _buildPermissionSection('Sharing Controls'),
            SwitchListTile(
              title: Text('Allow Forwarding'),
              subtitle: Text('Recipient can share the content to other users'),
              value: settings['allowForwarding'],
              onChanged: (value) => setState(() => settings['allowForwarding'] = value),
            ),
            
            _buildPermissionSection('Time Restrictions'),
            SwitchListTile(
              title: Text('Set Time Limit'),
              subtitle: Text('Content will be automatically deleted after the set time'),
              value: settings['timeLimit'],
              onChanged: (value) => setState(() => settings['timeLimit'] = value),
            ),
            if (settings['timeLimit'])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Access duration (minutes):'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: settings['timeLimitMinutes'].toDouble(),
                            min: 1,
                            max: 180,
                            divisions: 179,
                            label: '${settings['timeLimitMinutes']} min',
                            onChanged: (value) {
                              setState(() => settings['timeLimitMinutes'] = value.round());
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('${settings['timeLimitMinutes']}m'),
                      ],
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
          onPressed: () {
            if (widget.isModification) {
              widget.onSettingsUpdated?.call(settings);
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop(settings);
            }
          },
          child: Text(widget.isModification ? 'Update Settings' : 'Apply Settings'),
        ),
      ],
    );
  }

// In simulation_controller.dart, add this to the SimulationController class:

// In simulation_controller.dart add the updateMessageSettings method:


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
}

