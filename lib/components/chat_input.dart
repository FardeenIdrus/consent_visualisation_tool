// lib/components/chat_input.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget that provides a chat input area with an optional image preview.
/// 
/// This widget consists of two main parts:
/// 1. An image preview section that displays the selected image along with a button to remove it.
/// 2. An input section where users can type their message, pick an image, and send the message.
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onImagePick;
  final VoidCallback onSend;
  final Uint8List? pendingImage;
  final VoidCallback onClearImage;

  /// Constructs a [ChatInput] widget.
  ///
  /// [controller] is used to control the text input.
  /// [onImagePick] is called when the image picker button is pressed.
  /// [onSend] is called when the send button is pressed.
  /// [pendingImage] is the image data to be previewed, if available.
  /// [onClearImage] is called to clear the selected image.
  const ChatInput({
    super.key,
    required this.controller,
    required this.onImagePick,
    required this.onSend,
    this.pendingImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image Preview Section
        if (pendingImage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Display the selected image with a close button to remove it
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        pendingImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                        onPressed: onClearImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Text indicating the image is ready to be sent
                Expanded(
                  child: Text(
                    'Image ready to send',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Input Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 6,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Button to pick an image from the gallery
              IconButton(
                icon: const Icon(Icons.image_rounded, color: AppTheme.primaryColor),
                onPressed: onImagePick,
              ),
              // Text input field for message typing
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Button to send the message
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
