import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:consent_visualisation_tool/controller/simulation_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/model/simulation_model.dart';


class SimulationScreen extends StatefulWidget {
  final List<ConsentModel> models;

  const SimulationScreen({Key? key, required this.models}) : super(key: key);

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  late SimulationModel _model;
  late SimulationController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _pendingImageBytes;

  @override
  void initState() {
    super.initState();
    _model = SimulationModel();
    _controller = SimulationController(_model, context);
    _model.currentModel = widget.models.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent Simulation'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModelSelector(),
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return DropdownButton<ConsentModel>(
      value: _model.currentModel,
      items: widget.models.map((model) => 
        DropdownMenuItem(
          value: model,
          child: Text(model.name)
        )
      ).toList(),
      onChanged: (selectedModel) {
        setState(() {
          _controller.selectModel(selectedModel!);
        });
      },
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _model.messages.length,
      itemBuilder: (context, index) {
        final message = _model.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(SimulationMessage message) {
    return message.type == MessageType.image
      ? Image.memory(message.imageData!, width: 200, height: 200)
      : Text(message.content);
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.image),
          onPressed: _pickImage,
        ),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(hintText: 'Enter message'),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
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

Future<void> _sendMessage() async {
  final text = _messageController.text;
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

  void _clearChat() {
    setState(() {
      _model.clearMessages();
    });
  }
}

