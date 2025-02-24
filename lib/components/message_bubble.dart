// lib/components/message_bubble.dart
import 'package:flutter/material.dart';
import '../model/chat_interface_model.dart';
import '../theme/app_theme.dart';
import '../controller/chat_interface_controller.dart';

class MessageBubble extends StatelessWidget {
  final SimulationMessage message;
  final bool isReceiver;
  final bool isRecipient2; 
  final VoidCallback? onConsentRequest;
  final bool canSave;
  final bool canForward;
  final Function(BuildContext) onSave;
  final Function(BuildContext) onForward;
  final Function(BuildContext)? onDelete;
  final SimulationController controller;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isReceiver,
     this.isRecipient2 = false,
    this.onConsentRequest,
    this.canSave = true,
    this.canForward = true,
    required this.onSave,
    required this.onForward,
    this.onDelete,
    required this.controller,
  });

  void _showGranularSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GranularConsentDialog(
        initialSettings: message.additionalData,
        isModification: true,
        onSettingsUpdated: (newSettings) {
          controller.updateMessageSettings(message, newSettings);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isReceiver &&
        message.type == MessageType.image &&
        message.consentModel?.name == 'Affirmative Consent' &&
        message.additionalData?['requiresRecipientConsent'] == true) {
      return _buildConsentRequest(context);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
            const SizedBox(width: 8),
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
      bool isDynamicConsent = message.consentModel?.name == 'Dynamic Consent';
      bool canDelete = message.additionalData?['allowDeletion'] == true;
      List<Widget> controls = [];
      String timeRemaining = '';
      bool isExpired = false;

      if (!isReceiver && message.consentModel?.name == 'Granular Consent') {
        controls.add(
          _buildActionButton(
            icon: Icons.settings,
            enabled: true,
            onPressed: () => _showGranularSettings(context),
            label: 'Settings',
          ),
        );
      }

      if (message.consentModel?.name == 'Granular Consent' && 
          message.additionalData?['timeLimit'] == true) {
        final minutes = message.additionalData!['timeLimitMinutes'] as int;
        final expiryTime = message.timestamp.add(Duration(minutes: minutes));
        final remaining = expiryTime.difference(DateTime.now());
        
        if (remaining.isNegative) {
          timeRemaining = 'Expired';
          isExpired = true;
        } else {
          timeRemaining = '${remaining.inSeconds}';
        }
      }

      return Container(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                message.imageData!,
                width: 240,
                height: 320,
                fit: BoxFit.cover,
              ),
            ),
            if (timeRemaining.isNotEmpty && !isReceiver)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.red.withOpacity(0.9) : Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    timeRemaining,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
             if (controls.isNotEmpty || isReceiver || (isDynamicConsent && !isReceiver))
      Positioned(
        bottom: 8,
        right: 8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...controls,
            if (isDynamicConsent && !isReceiver && canDelete)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: _buildActionButton(
                  icon: Icons.delete_outline,
                  enabled: true,
                  onPressed: () => onDelete?.call(context),
                  label: 'Delete',
                ),
              ),
            if (isReceiver && !isRecipient2) ...[
              // Save and forward buttons only for first recipient, not Recipient 2
              if (canSave)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildActionButton(
                    icon: Icons.save_rounded,
                    enabled: true,
                    onPressed: () => onSave(context),
                    label: 'Save',
                  ),
                ),
              if (canForward)
                _buildActionButton(
                  icon: Icons.forward_rounded,
                  enabled: true,
                  onPressed: () => onForward(context),
                  label: 'Forward',
                ),
            ] else if (isReceiver && isRecipient2) ...[
              // No buttons at all for Recipient 2
            ],
          ],
        ),
      ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildConsentRequest(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 8),
              Text(
                'Consent Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('View Image'),
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

  Widget _buildActionButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: enabled ? Colors.white : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
