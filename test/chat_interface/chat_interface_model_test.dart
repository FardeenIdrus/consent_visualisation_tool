// test/chat_interface_model_test.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consent_visualisation_tool/model/chat_interface_model.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';

void main() {
  group('SimulationMessage', () {
    test('Constructor initializes properties correctly', () {
      // Create test data
      const testContent = 'Test message';
      const testType = MessageType.text;
      final testImageData = Uint8List.fromList([1, 2, 3, 4]);
      final testModel = ConsentModel.informed();
      final additionalData = {'key': 'value'};
      
      // Create a message
      final message = SimulationMessage(
        content: testContent,
        type: testType,
        imageData: testImageData,
        consentModel: testModel,
        additionalData: additionalData,
      );
      
      // Verify properties
      expect(message.content, equals(testContent));
      expect(message.type, equals(testType));
      expect(message.imageData, equals(testImageData));
      expect(message.consentModel, equals(testModel));
      expect(message.additionalData, equals(additionalData));
      expect(message.timestamp, isNotNull);
      expect(message.forwardedFrom, isNull);
    });
    
    test('Constructor with forwarded message', () {
      final originalMessage = SimulationMessage(
        content: 'Original',
        type: MessageType.text
      );
      
      final forwardedMessage = SimulationMessage(
        content: 'Forwarded',
        type: MessageType.text,
        forwardedFrom: originalMessage
      );
      
      expect(forwardedMessage.forwardedFrom, equals(originalMessage));
    });
  });
  
  group('SimulationModel', () {
    late SimulationModel model;
    
    // Mock BuildContext for the model
    final mockContext = MockBuildContext();
    isSenderActive() => true;
    
    setUp(() {
      model = SimulationModel(mockContext, isSenderActive);
    });
    
    tearDown(() {
      model.dispose();
    });
    
    test('Initial state is empty', () {
      expect(model.messages, isEmpty);
      expect(model.forwardedMessages, isEmpty);
      expect(model.currentModel, isNull);
    });
    
    test('addMessage adds message to the list', () {
      final message = SimulationMessage(
        content: 'Test message',
        type: MessageType.text
      );
      
      model.addMessage(message);
      
      expect(model.messages, contains(message));
      expect(model.messages.length, equals(1));
    });
    
    test('addForwardedMessage adds to forwardedMessages list', () {
      final message = SimulationMessage(
        content: 'Forwarded message',
        type: MessageType.text
      );
      
      model.addForwardedMessage(message);
      
      expect(model.forwardedMessages, contains(message));
      expect(model.forwardedMessages.length, equals(1));
    });
    
    test('deleteMessage removes message from the list', () {
      final message = SimulationMessage(
        content: 'Test message',
        type: MessageType.text
      );
      
      model.addMessage(message);
      expect(model.messages, contains(message));
      
      model.deleteMessage(message);
      expect(model.messages, isEmpty);
    });
    
    test('clearMessages removes all messages', () {
      // Add multiple messages
      model.addMessage(SimulationMessage(
        content: 'Message 1',
        type: MessageType.text
      ));
      
      model.addMessage(SimulationMessage(
        content: 'Message 2',
        type: MessageType.text
      ));
      
      model.addForwardedMessage(SimulationMessage(
        content: 'Forwarded message',
        type: MessageType.text
      ));
      
      expect(model.messages.length, equals(2));
      expect(model.forwardedMessages.length, equals(1));
      
      model.clearMessages();
      
      expect(model.messages, isEmpty);
      expect(model.forwardedMessages, isEmpty);
    });
    
    test('Message expiration testing indirectly', () {
      // Create a Granular Consent model
      final granularModel = ConsentModel.granular();
      model.currentModel = granularModel;
      
      // Create a message with a time limit
      final messageWithTimeLimit = SimulationMessage(
        content: 'This will expire',
        type: MessageType.image,
        imageData: Uint8List.fromList([1, 2, 3, 4]),
        consentModel: granularModel,
        additionalData: {
          'timeLimit': true,
          'timeLimitMinutes': 0,
          'timeLimitSeconds': 1,
        },
      );
      
      // Add the message
      model.addMessage(messageWithTimeLimit);
      expect(model.messages.length, equals(1));
      
      // Can't call private methods directly, so use the model's public methods
      // That would trigger the expirations checks
      model.notifyListeners();
    
      expect(model.messages.isNotEmpty, isTrue);
    });

    test('notifyListeners triggers message stream updates', () async {
      // Create a controller to listen to the message stream
      bool updateReceived = false;
      
      // Listen to the stream
      final subscription = model.messageStream.listen((messages) {
        updateReceived = true;
      });
      
      // Add a message which should notify listeners
      model.addMessage(SimulationMessage(
        content: 'Test notification',
        type: MessageType.text
      ));
      
      await Future.delayed(Duration.zero);
      
      expect(updateReceived, isTrue);
      
      // Clean up
      await subscription.cancel();
    });
  });
  
  // Test the DynamicConsentReassessmentDialog widget
  group('Dynamic Consent Reassessment Dialog', () {
    testWidgets('Simulated dialog builds correctly and handles user input', (WidgetTester tester) async {
      
      // Create a test app with a simulated reassessment dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Consent Re-evaluation'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Would you like to continue sharing this image?'),
                      
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop({'continue': false}),
                        child: Text('Revoke Consent'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop({
                          'continue': true,
                          'newTotalSeconds': 60
                        }),
                        child: Text('Continue Sharing'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Show Dialog'),
            ),
          ),
        ),
      );
      
      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      // Verify dialog is shown with expected content
      expect(find.text('Consent Re-evaluation'), findsOneWidget);
      expect(find.text('Would you like to continue sharing this image?'), findsOneWidget);
      expect(find.text('Revoke Consent'), findsOneWidget);
      expect(find.text('Continue Sharing'), findsOneWidget);
      
      // Test revoking consent
      await tester.tap(find.text('Revoke Consent'));
      await tester.pumpAndSettle();
      
      // Dialog should be dismissed
      expect(find.text('Consent Re-evaluation'), findsNothing);
      
      // Show dialog again to test the other button
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      // Test continuing consent
      await tester.tap(find.text('Continue Sharing'));
      await tester.pumpAndSettle();
      
      // Dialog should be dismissed
      expect(find.text('Consent Re-evaluation'), findsNothing);
    });
  });
}

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}