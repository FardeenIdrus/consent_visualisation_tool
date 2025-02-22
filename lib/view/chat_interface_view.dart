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
    _model = SimulationModel(context);
    _controller = SimulationController(_model, context);
    _model.currentModel = ConsentModelList.getAvailableModels().first;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
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
void _showImageRequestDialog(SimulationMessage requestMessage) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) => AlertDialog(
      title: Text('Image Request'),
      content: Text('The recipient has requested an image. Would you like to share?'),
      actions: [
        TextButton(
          onPressed: () {
            // Remove the request message and close dialog
            _model.deleteMessage(requestMessage);
            Navigator.of(context).pop();
          },
          child: Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Close the dialog immediately
            Navigator.of(context).pop();

            // Remove the request message 
            _model.deleteMessage(requestMessage);
            
            // Trigger image pick
            await _pickImage();
            
            // If an image was actually selected, send it
            if (_pendingImageBytes != null) {
              await _handleSendMessage('');
            }
          },
          child: Text('Share Image'),
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

  Future<void> _handleSendMessage(String text) async {
    if (text.isEmpty && _pendingImageBytes == null) return;

    final sent = await _controller.sendMessage(
      text.isNotEmpty ? text : null,
      imageBytes: _pendingImageBytes,
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

// Fix for the Affirmative Consent dialog issue
Widget _buildChatView({required bool isSender}) {
  return Column(
    children: [
      Expanded(
        child: StreamBuilder<List<SimulationMessage>>(
          stream: _model.messageStream,
          initialData: _model.messages,
          builder: (context, snapshot) {
            final messages = snapshot.data ?? [];
            
            // Handle image request message only once per message
            if (isSender) {
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
                              await _handleSendMessage('');
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
                      builder: (context) => AffirmativeConsentDialog(isSender: false),
                    );
                    
                    if (consentGranted == true) {
                      setState(() {
                        message.additionalData?['requiresRecipientConsent'] = false;
                      });
                    }
                  },
                  canSave: message.additionalData?['allowSaving'] ?? true,
                  canForward: message.additionalData?['allowForwarding'] ?? true,
                  onSave: (context) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Content saved')),
                  ),
                  onForward: (context) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Content forwarded')),
                  ),
                  onDelete: message.consentModel?.name == 'Dynamic Consent' 
                    ? (context) => _controller.deleteMessage(message)
                    : null,
                );
              },
            );
          },
        ),
      ),
      
      // Image request button for recipient
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
                additionalData: {
                  'imageRequest': true,
                  'processed': false
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
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
}