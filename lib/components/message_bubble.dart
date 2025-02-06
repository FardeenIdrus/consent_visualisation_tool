// lib/components/message_bubble.dart

import 'package:flutter/material.dart';
import '../model/simulation_model.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final SimulationMessage message;
  final bool isReceiver;
  final VoidCallback? onConsentRequest;
  final bool canSave;
  final bool canForward;
  final Function(BuildContext) onSave;
  final Function(BuildContext) onForward;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isReceiver,
    this.onConsentRequest,
    this.canSave = true,
    this.canForward = true,
    required this.onSave,
    required this.onForward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle affirmative consent request for images
    if (isReceiver && 
        message.type == MessageType.image && 
        message.consentModel?.name == 'Affirmative Consent' &&
        message.additionalData?['requiresRecipientConsent'] == true) {
      return _buildConsentRequest(context);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      alignment: isReceiver ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isReceiver ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildConsentRequest(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 20, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Consent Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(Icons.visibility),
            label: Text('View Image'),
            onPressed: onConsentRequest,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    bool isAwaitingConsent = message.consentModel?.name == 'Affirmative Consent' &&
                            message.additionalData?['requiresRecipientConsent'] == true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.consentModel?.name ?? 'Unknown Model',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (isAwaitingConsent) ...[
            SizedBox(width: 8),
            Icon(Icons.pending_outlined, size: 12, color: Colors.grey[600]),
            Text(
              ' Awaiting consent',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildContent(BuildContext context) {
    if (message.type == MessageType.image) {
      return Container(
        constraints: BoxConstraints(maxWidth: 240),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                message.imageData!,
                width: 240,  // Set fixed width
                height: 320,  // Set fixed height
                fit: BoxFit.cover,
              ),
            ),
            if (isReceiver)
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.save_rounded,
                      enabled: canSave,
                      onPressed: () => onSave(context),
                    ),
                    SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.forward_rounded,
                      enabled: canForward,
                      onPressed: () => onForward(context),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 280),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isReceiver ? Colors.grey[100] : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.content,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: enabled ? Colors.white : Colors.grey[400],
        onPressed: enabled ? onPressed : null,
        constraints: BoxConstraints.tightFor(
          width: 32,
          height: 32,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}