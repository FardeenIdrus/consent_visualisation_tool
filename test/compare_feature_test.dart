// test/compare_feature_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/compare_model.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/compare_view.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart';

void main() {

   // ----------------------------
  // CompareModel Tests
  // ----------------------------
  group('CompareModel Tests', () {
    late CompareScreenModel model;

    // Create a new CompareScreenModel instance before each test.
    setUp(() {
      model = CompareScreenModel();
    });

    // Verify that the list of available consent models contains 5 models with expected names.
    test('consentModels returns list of models', () {
      expect(model.consentModels.length, 5);
      final modelNames = model.consentModels.map((m) => m.name).toList();
      expect(modelNames, contains('Informed Consent'));
      expect(modelNames, contains('Affirmative Consent'));
      expect(modelNames, contains('Dynamic Consent'));
      expect(modelNames, contains('Granular Consent'));
      expect(modelNames, contains('Implied Consent'));
    });

    // Verify that the initial consent process map for Informed Consent is correct.
   test('getInitialConsentProcess returns correct data for Informed Consent', () {
    final expectedInformed = {
      'main': ['Before sharing content:', 'The sender is presented with a comprehensive risk disclosure panel', 'The sender must actively acknowledge understanding of risks'],
      'risk_disclosure': ['The risk disclosure panel includes the following risks:', 'Digital Permanence: Once shared, images can persist indefinitely in digital spaces, creating potential for future misuse.', 'Distribution Risks: Once shared, images can be copied, saved, or redistributed without your discretion, even if initially shared within a consensual exchange.', 'Control Limitations: After sharing, you will have limited ability to control how your images are stored, shared, or used by others.', 'Future Impact: Shared images may have long-term consequences for personal relationships, professional opportunities, and overall wellbeing.', 'Security Risks: There is potential for third-party interception, unauthorized access, or data breaches of shared images.'],
      'additional': ['Each risk requires explicit acknowledgment', 'Sharing disabled until all risks are understood']
    };

    expect(model.getInitialConsentProcess(ConsentModel.informed()), equals(expectedInformed));
  });

  // Verify that the initial consent process map for Affirmative Consent is correct.
  test('getInitialConsentProcess returns correct data for Affirmative Consent', () {
    final expectedAffirmative = {
      'type': 'pathways',
      'pathway1': {
        'title': 'Sender-Initiated Sharing',
        'steps': ['The sender is presented with the same risk disclosure as Informed Consent when they attempt to share an image', 'The sender must check acknowledgment boxes for each risk', 'The sender cannot proceed without acknowledging all risks', 'The sender is prompted: "Do you enthusiastically agree to share this image?"', 'Sender must explicitly confirm their willing participation', 'Recipient must actively confirm their willingness to receive', 'Clear decline option is provided at each step for both sender and recipient']
      },
      'pathway2': {
        'title': 'Recipient Requests Image',
        'steps': ['Recipient initiates image request', 'The sender is presented with the request', 'If the sender accepts the request, they see the same risk disclosure as Informed Consent', 'Sender must check acknowledgment boxes for each risk', 'Sender is prompted: "Do you enthusiastically agree to share this image?"', 'Only if the sender agrees, will the recipient receive the image', 'Clear decline option is provided at each step to the sender']
      }
    };

    expect(model.getInitialConsentProcess(ConsentModel.affirmative()), equals(expectedAffirmative));
  });

  // Verify that the initial consent process map for Dynamic Consent is correct.
  test('getInitialConsentProcess returns correct data for Dynamic Consent', () {
    final expectedDynamic = {
      'main': ['At point of set up:', 'The sender configures how often they want to review consent'],
      'sub': ['The sender then sets consent review frequency (hourly, daily, weekly)', 'Configure notification preferences for review reminders'],
      'additional': ['The system explains how ongoing consent management works', 'The sender must understand the implications of their chosen review schedule']
    };

    expect(model.getInitialConsentProcess(ConsentModel.dynamic()), equals(expectedDynamic));
  });

  // Verify that the initial consent process map for Granular Consent is correct.
  test('getInitialConsentProcess returns correct data for Granular Consent', () {
    final expectedGranular = {
      'main': ['At point of set up:', 'The sender is presented with a list of permissions settings', 'The sender must configure detailed permission settings'],
      'sub': ['Define content viewing duration', 'Configure saving restrictions', 'Configure sharing restrictions'],
      'additional': ['Each permission setting requires explicit configuration', 'All settings must be configured before sharing']
    };

    expect(model.getInitialConsentProcess(ConsentModel.granular()), equals(expectedGranular));
  });

  // Verify that the initial consent process map for Granular Consent is correct.
  test('getInitialConsentProcess returns correct data for Implied Consent', () {
    final expectedImplied = {
      'main': ['At point of set up:', 'No explicit consent mechanism is presented to the sender', 'Consent is assumed through user actions'],
      'sub': ['No risk disclosure information is provided to the sender', 'No explicit confirmation required', 'No consent configuration options are presented to the sender'],
      'additional': ['Relies purely on assumption of consent through behavior', 'No safeguards or confirmations in place']
    };

    expect(model.getInitialConsentProcess(ConsentModel.implied()), equals(expectedImplied));
  });


  // Verify that the control mechanism process map for Informed Consent is correct.
 test('getControlMechanisms returns correct data for Informed Consent', () {
    final expectedInformed = {
      'main': ['At the point of sharing:', 'The sender is only allowed to share once they acknowledge all risks', 'No technical controls are available to the sender to protect their content'],
      'sub': ['The sender cannot set time limits for content access', 'The sender cannot prevent recipients from saving content', 'The sender cannot restrict recipients from sharing content'],
      'additional': ['Protection relies on senders understanding of the risks']
    };

    expect(model.getControlMechanisms(ConsentModel.informed()), equals(expectedInformed));
  });

  // Verify that the control mechanism process map for Affirmative Consent is correct.
  test('getControlMechanisms returns correct data for Affirmative Consent', () {
    final expectedAffirmative = {
      'main': ['At the point of sharing:', 'Sharing requires mutual confirmation from both parties', 'No technical controls are available'],
      'sub': ['The sender cannot set time limits for content access', 'The sender cannot prevent recipients from saving content', 'The sender cannot restrict recipients from sharing content'],
      'additional': ['Protection relies on explicit agreement rather than technical restrictions']
    };

    expect(model.getControlMechanisms(ConsentModel.affirmative()), equals(expectedAffirmative));
  });

  // Verify that the control mechanism process map for Dynamic Consent is correct.
  test('getControlMechanisms returns correct data for Dynamic Consent', () {
    final expectedDynamic = {
      'main': ['At the point of sharing:', 'The sender shares content with a configured review schedule', 'The sender has no immediate technical restrictions'],
      'sub': ['The sender cannot prevent recipients from saving content', 'The sender cannot restrict recipients from sharing content'],
      'additional': ['Protection relies on ongoing review of consent rather than technical restrictions']
    };

    expect(model.getControlMechanisms(ConsentModel.dynamic()), equals(expectedDynamic));
  });

  // Verify that the control mechanism process map for Granular Consent is correct.
  test('getControlMechanisms returns correct data for Granular Consent', () {
    final expectedGranular = {
      'main': ['At the point of sharing:', 'System enforces configured permission settings', 'Protection mechanisms are applied to content'],
      'sub': ['Time limits are set on content access', 'Saving permissions are enforced', 'Sharing restrictions are implemented'],
      'additional': ['All configured protection mechanisms are applied']
    };

    expect(model.getControlMechanisms(ConsentModel.granular()), equals(expectedGranular));
  });

   // Verify that the control mechanism process map for Implied Consent is correct.
  test('getControlMechanisms returns correct data for Implied Consent', () {
    final expectedImplied = {
      'main': ['At the point of sharing:', 'No consent verification is presented to the sender', 'No technical controls are available to the sender'],
      'sub': ['The sender cannot set time limits for content access', 'The sender cannot prevent recipients from saving content', 'The sender cannot restrict recipients from sharing content'],
      'additional': ['No protection mechanisms are available']
    };

    expect(model.getControlMechanisms(ConsentModel.implied()), equals(expectedImplied));
  });

   // Verify that the consent modification process map for Informed Consent is correct.
  test('getConsentModification returns correct data for Informed Consent', () {
    final expectedInformed = {
      'main': ['After sharing:', 'The sender has no ability to modify initial sharing conditions', 'The sender has no way to control shared content'],
      'sub': ['The sender has no ability to withdraw shared content', 'The sender has no ability to change access permissions', 'The sender has no ability to track how content is being used'],
      'additional': ['Once content is shared, sender loses technical control'] 
    };
    
    expect(model.getConsentModification(ConsentModel.informed()), equals(expectedInformed));
  });

  // Verify that the consent modification process map for Affirmative Consent is correct.
  test('getConsentModification returns correct data for Affirmative Consent', () {
    final expectedAffirmative = {
      'main': ['After sharing:', 'No ability to modify initial sharing conditions', 'No way to control shared content'], 
      'sub': ['The sender has no ability to withdraw shared content', 'The sender has no ability to change access permissions', 'The sender has no ability to track how content is being used'],
      'additional': ['Once content is shared, sender loses technical control over shared content']
    };

    expect(model.getConsentModification(ConsentModel.affirmative()), equals(expectedAffirmative));
  });

  // Verify that the consent modification process map for Dynamic Consent is correct.
  test('getConsentModification returns correct data for Dynamic Consent', () {
    final expectedDynamic = {
      'main': ['After sharing:', 'Regular consent reassessment occurs based on schedule', 'Sender maintains ongoing control through review process'],
      'sub': ['Can delete shared content at any time', 'Can revoke access during any review', 'Can modify review frequency', 'Receives notifications for scheduled reviews'], 
      'additional': ['The sender has continuous control through scheduled reassessment and the ability to revoke access to shared content at any time']
    };

    expect(model.getConsentModification(ConsentModel.dynamic()), equals(expectedDynamic));
  });

  // Verify that the consent modification process map for Granular Consent is correct.
  test('getConsentModification returns correct data for Granular Consent', () {
    final expectedGranular = {
      'main': ['After sharing:', 'The sender retains ability to modify controls', 'Technical restrictions remain enforceable'],
      'sub': ['Can adjust viewing time limits', 'Can modify saving permissions', 'Can update sharing restrictions'],
      'additional': ['Changes to settings take effect immediately'] 
    };

    expect(model.getConsentModification(ConsentModel.granular()), equals(expectedGranular));
  });

  // Verify that the consent modification process map for Implied Consent is correct.
  test('getConsentModification returns correct data for Implied Consent', () {
    final expectedImplied = {
      'main': ['After sharing:', 'The sender has no ability to modify conditions', 'The sender has no control over shared content'],
      'sub': ['Cannot withdraw shared content', 'Cannot change access permissions', 'Cannot track how content is being used'],
      'additional': ['Complete loss of control once content is shared']
    };

    expect(model.getConsentModification(ConsentModel.implied()), equals(expectedImplied));
  });
});

  // ----------------------------
  // CompareController Tests
  // ----------------------------
  group('CompareController Tests', () {
    late CompareController controller;

    // Create a new CompareController instance before each test.
    setUp(() {
      controller = CompareController();
    });

    // Verify that initially no consent models are selected.
    test('initially has empty selected models', () {
      expect(controller.selectedModels.value.length, 0);
    });

    // Verify that toggling selection on an unselected model adds it.
    test('toggleModelSelection adds model when not already selected', () {
      final model = ConsentModel.informed();
      controller.toggleModelSelection(model);
      expect(controller.selectedModels.value.length, 1);
      expect(controller.selectedModels.value.contains(model), true);
    });

    // Verify that toggling selection on a selected model removes it.
    test('toggleModelSelection removes model when already selected', () {
      final model = ConsentModel.informed();
      controller.toggleModelSelection(model);
      controller.toggleModelSelection(model);
      expect(controller.selectedModels.value.length, 0);
    });

    // Verify that selection is limited to 2 models.
    test('toggleModelSelection limits selection to 2 models', () {
      controller.toggleModelSelection(ConsentModel.informed());
      controller.toggleModelSelection(ConsentModel.affirmative());
      controller.toggleModelSelection(ConsentModel.granular());
      expect(controller.selectedModels.value.length, 2);
    });

    // Verify that resetSelection clears all selected models.
    test('resetSelection clears selected models', () {
      controller.toggleModelSelection(ConsentModel.informed());
      controller.toggleModelSelection(ConsentModel.affirmative());
      controller.resetSelection();
      expect(controller.selectedModels.value.length, 0);
    });

    // Verify that changing the dimension updates the selectedDimension.
    test('changeDimension updates selectedDimension', () {
      controller.changeDimension('permissions');
      expect(controller.selectedDimension.value, 'permissions');
    });
  });

  // ----------------------------
  // CompareView Widget Tests
  // ----------------------------
  group('CompareView Widget Tests', () {
    // Test that when two models are selected, the compare view displays the dimension focus and model names.
    testWidgets('model selection flow works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Tap the consent model chips for "Informed Consent" and "Granular Consent"
      await tester.tap(find.text('Informed Consent').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pumpAndSettle();

      // Verify that the dimension focus header is displayed and both model names appear.
      expect(find.text('Dimension Focus'), findsOneWidget);
      expect(find.textContaining('Informed Consent'), findsWidgets);
      expect(find.textContaining('Granular Consent'), findsWidgets);
    });

    // Test that changing the dimension updates the displayed comparison details.
    testWidgets('dimension changing works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Select two models.
      await tester.tap(find.text('Informed Consent').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pumpAndSettle();

      // Tap on the 'Permission Granularity' chip to change the dimension.
      await tester.tap(find.text('Permission Granularity'));
      await tester.pumpAndSettle();

      // Verify that the dimension description contains expected text 
      expect(find.textContaining('Technical controls'), findsOneWidget);
    });

    // Test navigation from the compare screen to the simulation screen.
    testWidgets('navigation to simulation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Select two models.
      await tester.tap(find.text('Informed Consent').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pumpAndSettle();
      
      // Tap the button that navigates to the simulation screen.
      await tester.tap(find.text('See how these models work in a chat interface'));
      await tester.pumpAndSettle();
      
      // Verify that the SimulationScreen is displayed.
      expect(find.byType(SimulationScreen), findsOneWidget);
    });

    // New Test: Verify that when fewer than two models are selected, the selection prompt is displayed.
    testWidgets('displays selection prompt when fewer than two models are selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // No models are selected.
      expect(find.text('Choose Two Models'), findsOneWidget);
      expect(find.text('Select two consent models to explore their unique characteristics'), findsOneWidget);
    });
  });
}



