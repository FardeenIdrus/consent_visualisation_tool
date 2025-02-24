import 'dart:async';
import 'dart:typed_data';
import 'package:consent_visualisation_tool/components/chat_input.dart';
import 'package:consent_visualisation_tool/components/message_bubble.dart';
import 'package:consent_visualisation_tool/controller/chat_interface_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/chat_interface_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'package:collection/collection.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    _model = SimulationModel(context);
    _controller = SimulationController(_model, context);
    _model.currentModel = ConsentModelList.getAvailableModels().first;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
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
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Clear'),
          ),
        ],
      ),
    );
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
    recipientRequested: recipientRequested, // Pass the flag to the controller
  );

    if (sent) {
      setState(() {
        _messageController.clear();
        _pendingImageBytes = null;
      });
    }
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
                 _buildChatView(isSender: false, isRecipient2: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Consent Simulation'),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
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
               _buildTabButton('Recipient 2', 2),
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
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
              items: models.map((model) => DropdownMenuItem(
                value: model.name,
                child: Text(model.name),
              )).toList(),
              onChanged: (name) {
                if (name != null) {
                  setState(() {
                    _model.currentModel = models.firstWhere((m) => m.name == name);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            label: const Text('Clear Chat'),
            onPressed: _clearChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Fix for the Affirmative Consent dialog issue
Widget _buildChatView({required bool isSender, bool isRecipient2 = false}) {
  return Column(
    children: [
      Expanded(
        child: StreamBuilder<List<SimulationMessage>>(
          stream: _model.messageStream,
          initialData: isRecipient2 ? _model.forwardedMessages : _model.messages,
          builder: (context, snapshot) {
            final messages = isRecipient2 ? _model.forwardedMessages : snapshot.data ?? [];
            
            // Handle image request message only once per message (only for sender view)
            if (isSender && !isRecipient2) {
              final imageRequestMessage = messages.firstWhereOrNull(
                (message) => message.additionalData?['imageRequest'] == true && 
                           !message.additionalData?['processed'] == true
              );
              
              if (imageRequestMessage != null) {
                // Mark message as processed to prevent multiple dialogs
                imageRequestMessage.additionalData?['processed'] = true;
                
                // Show dialog on next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Image Request'),
                      content: const Text('The recipient has requested an image. Would you like to share?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _model.deleteMessage(imageRequestMessage);
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Decline'),
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
                          child: const Text('Share Image'),
                        ),
                      ],
                    ),
                  );
                });
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                // Don't show image request messages in the chat
                if (message.additionalData?['imageRequest'] == true) {
                  return Container();
                }
                
                return MessageBubble(
                  message: message,
                  isReceiver: !isSender,
                  controller: _controller,
                  onConsentRequest: () async {
                    final consentGranted = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AffirmativeConsentDialog(isSender: false),
                    );
                    
                    if (consentGranted == true) {
                      setState(() {
                        message.additionalData?['requiresRecipientConsent'] = false;
                      });
                    }
                  },
                  canSave: message.additionalData?['allowSaving'] ?? true,
                  canForward: message.additionalData?['allowForwarding'] ?? true,
                  onSave: (context) {
                    _showActionAnimation(context, 'save');
                  },
                  onForward: (context) {
                    // Create a new message for Recipient 2
                    final forwardedMessage = SimulationMessage(
                      content: message.content,
                      type: message.type,
                      imageData: message.imageData,
                      consentModel: message.consentModel,
                      additionalData: message.additionalData != null 
                          ? Map<String, dynamic>.from(message.additionalData!) 
                          : null,
                    );
                    
                    // Add the forwarded message to Recipient 2's list
                    _model.addForwardedMessage(forwardedMessage);
                    
                    // Show forwarding animation
                    _showActionAnimation(context, 'forward');
                  },
                  onDelete: message.consentModel?.name == 'Dynamic Consent' 
                    ? (context) => _controller.deleteMessage(message)
                    : null,
                );
              },
            );
          },
        ),
      ),
      
      // Image request button for recipient (not for sender or recipient 2)
      if (!isSender && !isRecipient2 && _model.currentModel?.name == 'Affirmative Consent')
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.image_search),
            label: const Text('Request Image'),
            onPressed: () {
              _model.addMessage(SimulationMessage(
                content: 'Image Request: Would you like to share an image?',
                type: MessageType.text,
                consentModel: _model.currentModel,
                additionalData: {
                  'imageRequest': true,
                  'processed': false
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      
      // Recipient 2 label to show it's forwarded content
      if (isRecipient2 && _model.forwardedMessages.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forward_to_inbox, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Forwarded messages will appear here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      
      // Chat input for sender
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

void _showActionAnimation(BuildContext context, String action) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.5 + (value * 0.5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action == 'save' ? Icons.check_circle : Icons.forward,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      action == 'save' ? 'Image saved!' : 'Image forwarded!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(seconds: 1), () {
    overlayEntry.remove();
  });
}
}