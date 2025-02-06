import 'dart:typed_data';
import 'package:consent_visualisation_tool/controller/simulation_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/simulation_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

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
  
  final List<ConsentModel> _availableModels = ConsentModelList.getAvailableModels();

  @override
  void initState() {
    super.initState();
    _model = SimulationModel();
    _controller = SimulationController(_model, context);
    _model.currentModel = _availableModels.first;
  }

  void _handleSendMessage(String? text) async {
    final sent = await _controller.sendMessage(
      text,
      imageBytes: _pendingImageBytes,
    );

    if (sent) {
      setState(() {
        _pendingImageBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent Simulation'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Row(
            children: [
              Expanded(child: _buildTabButton('Sender', 0)),
              Expanded(child: _buildTabButton('Recipient', 1)),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        children: [
          _SenderTab(
            model: _model,
            onImagePicked: _pickImage,
            onClearChat: _clearChat,
            pendingImageBytes: _pendingImageBytes,
            onSendMessage: _handleSendMessage,
          ),
          _RecipientTab(model: _model),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pendingImageBytes = bytes;
      });
    }
  }

  void _clearChat() {
    setState(() {
      _model.clearMessages();
      _pendingImageBytes = null;
    });
  }
}

class _SenderTab extends StatefulWidget {
  final SimulationModel model;
  final Function() onImagePicked;
  final Function() onClearChat;
  final Function(String?) onSendMessage;
  final Uint8List? pendingImageBytes;

  const _SenderTab({
    Key? key,
    required this.model,
    required this.onImagePicked,
    required this.onClearChat,
    required this.pendingImageBytes,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  _SenderTabState createState() => _SenderTabState();
}

class _SenderTabState extends State<_SenderTab> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    
    // Set the initial model to Implied Consent
    widget.model.currentModel = ConsentModel.implied();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableModels = ConsentModelList.getAvailableModels();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: widget.model.currentModel?.name,
                  isExpanded: true,
                  items: availableModels.map((modelOption) {
                    return DropdownMenuItem(
                      value: modelOption.name,
                      child: Text(modelOption.name),
                    );
                  }).toList(),
                  onChanged: (selectedModelName) {
                    if (selectedModelName != null) {
                      setState(() {
                        final selectedModel = availableModels.firstWhere(
                          (model) => model.name == selectedModelName
                        );
                        widget.model.currentModel = selectedModel;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: widget.onClearChat,
                tooltip: 'Clear Chat',
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: widget.model.messages.length,
            itemBuilder: (context, index) {
              final message = widget.model.messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        if (widget.pendingImageBytes != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Image.memory(
                widget.pendingImageBytes!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: widget.onClearChat,
              ),
            ],
          ),

        Row(
          children: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: widget.onImagePicked,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                final text = _messageController.text;
                widget.onSendMessage(text.isNotEmpty ? text : null);
                _messageController.clear();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(SimulationMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.consentModel?.name ?? 'Unknown Model',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (message.type == MessageType.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                message.imageData!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.content,
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipientTab extends StatelessWidget {
  final SimulationModel model;

  const _RecipientTab({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: model.messages.length,
      itemBuilder: (context, index) {
        final message = model.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(SimulationMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.consentModel?.name ?? 'Unknown Model',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (message.type == MessageType.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                message.imageData!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.content,
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}

