import 'dart:async';
import 'dart:typed_data';
import 'package:consent_visualisation_tool/components/chat_input.dart';
import 'package:consent_visualisation_tool/components/message_bubble.dart';
import 'package:consent_visualisation_tool/controller/chat_interface_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/chat_interface_model.dart';
import 'package:consent_visualisation_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({Key? key}) : super(key: key);

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  late SimulationModel _model;
  late SimulationController _controller;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _pendingImageBytes;
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;
  final _messageController = TextEditingController();
  Timer? _countdownTimer;


  @override
  void initState() {
    super.initState();
    _model = SimulationModel();
    _controller = SimulationController(_model);
    _model.currentModel = ConsentModelList.getAvailableModels().first;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
  if (mounted) {
    setState(() {});
    // Call your expiry check (if it exists in your model)
    // _model._checkExpiredMessages(); // if you need it for granular consent
    _checkDynamicConsent();
  }
});

  }

  @override
  void dispose() {
    _model.dispose();
    _pageController.dispose();
    _messageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _model.clearMessages();
                _pendingImageBytes = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
  Future<void> _checkDynamicConsent() async {
  // Loop over a copy of messages to avoid modifying the list during iteration.
  for (var message in List<SimulationMessage>.from(_model.messages)) {
    if (message.consentModel?.name == 'Dynamic Consent' &&
        message.additionalData != null &&
        message.additionalData!['isVisible'] == true) {
      // Parse the last consent time (make sure it's set when the message was created)
      final lastConsentTime = DateTime.parse(message.additionalData!['lastConsentTime']);
      // Read the user-set duration (in seconds) or default to 0 if not set
      final totalSeconds = message.additionalData!['totalSeconds'] as int? ?? 0;
      final nextConsentTime = lastConsentTime.add(Duration(seconds: totalSeconds));
      if (DateTime.now().isAfter(nextConsentTime)) {
        // Show the dynamic consent dialog
        final result = await showDialog<Map<String, dynamic>>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) => _DynamicConsentReassessmentDialog(),
);

        if (result != null) {
          if (result['continue'] == true) {
            // Update the last consent time (and optionally the interval)
            message.additionalData!['lastConsentTime'] = DateTime.now().toIso8601String();
            if (result.containsKey('newTotalSeconds')) {
              message.additionalData!['totalSeconds'] = result['newTotalSeconds'];
            }
          } else {
            // Remove the message if consent is revoked
            _model.deleteMessage(message);
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
    }
  }
}


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _pendingImageBytes = bytes);
    }
  }

  Future<void> _handleSendMessage(String text, {bool recipientRequested = false}) async {
    if (text.isEmpty && _pendingImageBytes == null) return;
    final sent = await _controller.sendMessage(
      text.isNotEmpty ? text : null,
      imageBytes: _pendingImageBytes,
      recipientRequested: recipientRequested,
      context: context,
    );
    if (sent) {
      setState(() {
        _messageController.clear();
        _pendingImageBytes = null;
      });
    }
  }

  /// Displays an animated overlay popup with the provided message.
void _showAnimatedPopup(String message) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: AnimatedPopup(
        message: message,
        onDismiss: () => overlayEntry.remove(),
      ),
    ),
  );
  Overlay.of(context)?.insert(overlayEntry);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildConsentModelSelector(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentTabIndex = index),
              children: [
                _buildChatView(isSender: true),
                _buildChatView(isSender: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Consent Simulation'),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildTabButton('Sender', 0),
              _buildTabButton('Recipient', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentModelSelector() {
    final models = ConsentModelList.getAvailableModels();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _model.currentModel?.name,
              decoration: InputDecoration(
                labelText: 'Consent Model',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: models
                  .map((model) => DropdownMenuItem(
                        value: model.name,
                        child: Text(model.name),
                      ))
                  .toList(),
              onChanged: (name) {
                if (name != null) {
                  setState(() {
                    _model.currentModel = models.firstWhere((m) => m.name == name);
                  });
                }
              },
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            label: Text('Clear Chat'),
            onPressed: _clearChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView({required bool isSender}) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<SimulationMessage>>(
            stream: _model.messageStream,
            initialData: _model.messages,
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              if (isSender) {
                final imageRequestMessage = messages.firstWhereOrNull(
                  (message) =>
                      message.additionalData?['imageRequest'] == true &&
                      !(message.additionalData?['processed'] ?? false),
                );
                if (imageRequestMessage != null) {
                  imageRequestMessage.additionalData?['processed'] = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        title: Text('Image Request'),
                        content: Text('The recipient has requested an image. Would you like to share?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _model.deleteMessage(imageRequestMessage);
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text('Decline'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              _model.deleteMessage(imageRequestMessage);
                              await _pickImage();
                              if (_pendingImageBytes != null) {
                                await _handleSendMessage('', recipientRequested: true);
                              }
                            },
                            child: Text('Share Image'),
                          ),
                        ],
                      ),
                    );
                  });
                }
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (message.additionalData?['imageRequest'] == true) return Container();
                  return MessageBubble(
                    message: message,
                    isReceiver: !isSender,
                    controller: _controller,
                    onConsentRequest: () async {
                      final consentGranted = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AffirmativeConsentDialog(isSender: false),
                      );
                      if (consentGranted == true) {
                        setState(() {
                          message.additionalData?['requiresRecipientConsent'] = false;
                        });
                      }
                    },
                    onSave: (context) => _showAnimatedPopup('Content saved'),
                    onForward: (context) => _showAnimatedPopup('Content forwarded'),
                    onDelete: message.consentModel?.name == 'Dynamic Consent'
                        ? (context) => _controller.deleteMessage(message, context)
                        : null,
                    canSave: message.additionalData?['allowSaving'] ?? true,
                    canForward: message.additionalData?['allowForwarding'] ?? true,
                  );
                },
              );
            },
          ),
        ),
        if (!isSender && _model.currentModel?.name == 'Affirmative Consent')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.image_search),
              label: Text('Request Image'),
              onPressed: () {
                _model.addMessage(SimulationMessage(
                  content: 'Image Request: Would you like to share an image?',
                  type: MessageType.text,
                  consentModel: _model.currentModel,
                  additionalData: {'imageRequest': true, 'processed': false},
                ));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        if (isSender)
          ChatInput(
            controller: _messageController,
            onImagePick: _pickImage,
            onSend: () => _handleSendMessage(_messageController.text),
            pendingImage: _pendingImageBytes,
            onClearImage: () => setState(() => _pendingImageBytes = null),
          ),
      ],
    );
  }
}

/// --- Animated Popup Widget ---
class AnimatedPopup extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const AnimatedPopup({Key? key, required this.message, required this.onDismiss}) : super(key: key);

  @override
  _AnimatedPopupState createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    Future.delayed(Duration(seconds: 2), () {
      _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Dialog Widgets (View Components) ---
class InformedConsentDialog extends StatefulWidget {
  const InformedConsentDialog({Key? key}) : super(key: key);

  @override
  _InformedConsentDialogState createState() => _InformedConsentDialogState();
}

class _InformedConsentDialogState extends State<InformedConsentDialog> {
  bool _understandPermanence = false;
  bool _understandDistribution = false;
  bool _understandControlRisks = false;
  bool _understandFutureImpact = false;
  bool _understandSecurityRisks = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Informed Consent for Image Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please carefully review and acknowledge the following risks:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[800]),
            ),
            SizedBox(height: 16),
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
            Text('Key Implications:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '• Images may be stored indefinitely\n'
                '• Content can be shared without your explicit consent\n'
                '• Potential future reputational risks',
                style: TextStyle(color: Colors.grey[700]),
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
          onPressed: _allRisksAcknowledged() ? () => Navigator.of(context).pop(true) : null,
          child: Text('I Understand All Risks'),
        ),
      ],
    );
  }

  Widget _buildRiskDisclosureSection({required String title, required String description, required bool value, required Function(bool?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
          subtitle: Text(description, style: TextStyle(color: Colors.grey[700])),
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
  const AffirmativeConsentDialog({Key? key, required this.isSender}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isSender ? 'Request to Share Image' : 'Request to View Image'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSender 
                ? 'Do you explicitly agree to share this image?' 
                : 'A user wants to share an image with you. Do you explicitly agree to view it?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text('By agreeing, you acknowledge:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              isSender
                ? '• The image will be shared with the recipient\n• You are under no obligation to agree\n• You have willingly chosen to share this content'
                : '• You will receive an image from the sender\n• You can decline to view the content\n• You are under no obligation to agree',
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
  const DynamicConsentDialog({Key? key}) : super(key: key);

  @override
  _DynamicConsentDialogState createState() => _DynamicConsentDialogState();
}

class _DynamicConsentDialogState extends State<DynamicConsentDialog> {
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
      title: Text('Set Consent Re-evaluation Interval'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How often should consent be re-evaluated?', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    decoration: InputDecoration(labelText: 'Hours', border: OutlineInputBorder(), helperText: '0-48'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hours = int.tryParse(value) ?? 0;
                      if (hours > 48) {
                        _hoursController.text = '48';
                        _hoursController.selection = TextSelection.fromPosition(TextPosition(offset: 2));
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    decoration: InputDecoration(labelText: 'Minutes', border: OutlineInputBorder(), helperText: '0-59'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minutes = int.tryParse(value) ?? 0;
                      if (minutes > 59) {
                        _minutesController.text = '59';
                        _minutesController.selection = TextSelection.fromPosition(TextPosition(offset: 2));
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    decoration: InputDecoration(labelText: 'Seconds', border: OutlineInputBorder(), helperText: '0-59'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final seconds = int.tryParse(value) ?? 0;
                      if (seconds > 59) {
                        _secondsController.text = '59';
                        _secondsController.selection = TextSelection.fromPosition(TextPosition(offset: 2));
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
                  Text('What this means:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    '• You\'ll be asked to review your consent after the set time\n'
                    '• You can choose to continue sharing or revoke access\n'
                    '• The image can be deleted at any time',
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Would you like to continue sharing this image?'),
            SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _hoursController,
                    decoration: InputDecoration(
                      labelText: 'Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _minutesController,
                    decoration: InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _secondsController,
                    decoration: InputDecoration(
                      labelText: 'Seconds',
                      border: OutlineInputBorder(),
                    ),
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
              'newTotalSeconds': newTotalSeconds > 0 ? newTotalSeconds : null,
            });
          },
          child: Text('Continue Sharing'),
        ),
      ],
    );
  }
}



class GranularConsentDialog extends StatefulWidget {
  final Map<String, dynamic>? initialSettings;
  final bool isModification;
  final Function(Map<String, dynamic>)? onSettingsUpdated;

  const GranularConsentDialog({
    Key? key, 
    this.initialSettings,
    this.isModification = false,
    this.onSettingsUpdated,
  }) : super(key: key);

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
      'timeLimitMinutes': 60, // Duration in minutes using a slider
      'allowScreenshots': false,
      'addWatermark': false,
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
              subtitle: Text('Recipient can forward the content'),
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

  Widget _buildPermissionSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}



