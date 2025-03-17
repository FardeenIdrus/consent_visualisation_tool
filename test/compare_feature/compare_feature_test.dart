// test/compare_feature_test.dart
import 'package:consent_visualisation_tool/theme/app_theme.dart';
import 'package:consent_visualisation_tool/view/consent_flow.dart';
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
    'main': <String>[
      'Before sharing an Image:',
      'The sender is presented with a list of potential risks surrounding the sharing of intimate images digitally',
      'The sender must actively acknowledge understanding of each risk'
    ],
    'sub': <String>[
      'The risks presented include:',
      'Digital permanence risks',
      'Distribution risks',
      'Control limitation risks',
      'Future impact risks',
      'Security risks'
    ],
    'additional': <String>[
      'Each risk requires explicit acknowledgment from the sender',
      'Sender must check acknowledgment boxes for each risk',
      'Consent is specific to each instance of image sharing'
    ]
  };
  
  expect(model.getInitialConsentProcess(ConsentModel.informed()), equals(expectedInformed));
});

  // Verify that the initial consent process map for Affirmative Consent is correct.
test('getInitialConsentProcess returns correct data for Affirmative Consent', () {
  final expectedAffirmative = {
  'main': <String>[
  'Before sharing an image:',
  'The sender is presented with a list of potential risks surrounding digital intimate image sharing',
  'Both sender and recipient must actively confirm their participation'
],
'sub': <String>[
  'The sender must check acknowledgment boxes for each risk',
  'The sender must explicitly confirm their willingness to share',
  'The recipient must actively confirm their willingness to receive',
  'Clear options to decline are provided at each step for both parties'
],
'additional': <String>[
  'Dual-party confirmation is mandatory',
  'Image sharing only occurs when both parties agree',
  'Consent is specific to each instance of image sharing',
]
  };
  
  expect(model.getInitialConsentProcess(ConsentModel.affirmative()), equals(expectedAffirmative));
});

  // Verify that the initial consent process map for Dynamic Consent is correct.
test('getInitialConsentProcess returns correct data for Dynamic Consent', () {
  final expectedDynamic = {
    'main': [
      'Before sharing an image:',
      'The sender is provided an option to configure how often they want to review consent'
    ],
    'sub': [
      'The sender then sets consent review frequency (hourly, daily, weekly)', 
      'Configure notification preferences for review reminders'
    ],
    'additional': [
      'The system explains the ongoing consent management process and review options'
    ]
  };
  
  expect(model.getInitialConsentProcess(ConsentModel.dynamic()), equals(expectedDynamic));
});

  // Verify that the initial consent process map for Granular Consent is correct.
  test('getInitialConsentProcess returns correct data for Granular Consent', () {
    final expectedGranular = {
      'main': ['Before sharing an image:', 'The sender is presented with a list of permissions settings', 'The sender must configure detailed permission settings'],
      'sub': ['Define content viewing duration', 'Configure saving restrictions', 'Configure sharing restrictions'],
      'additional': ['Each permission setting requires explicit configuration', 'All settings must be configured before sharing']
    };

    expect(model.getInitialConsentProcess(ConsentModel.granular()), equals(expectedGranular));
  });

  // Verify that the initial consent process map for Implied Consent is correct.
  test('getInitialConsentProcess returns correct data for Implied Consent', () {
    final expectedImplied = {
      'main': ['Before sharing an image:', 'No explicit consent mechanism is presented to the sender', 'Consent is assumed through user actions'],
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

  test('getInitialConsentProcess returns default data for unknown consent model', () {
  // Create a dummy consent model with a name not covered by the switch.
  final unknownModel = ConsentModel(name: 'Unknown Consent');
  expect(model.getInitialConsentProcess(unknownModel), equals({'main': <String>[], 'sub': <String>[]}));
});

test('getControlMechanisms returns default data for unknown consent model', () {
  final unknownModel = ConsentModel(name: 'Unknown Consent');
  expect(model.getControlMechanisms(unknownModel), equals({'main': <String>[], 'sub': <String>[]}));
});

test('getConsentModification returns default data for unknown consent model', () {
  final unknownModel = ConsentModel(name: 'Unknown Consent');
  expect(model.getConsentModification(unknownModel), equals({'main': <String>[], 'sub': <String>[]}));
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

 // Verify that getFeatures returns the modification details when dimension is 'revocability'.
    test('getFeatures returns correct data for revocability', () {
  final informed = ConsentModel.informed();
  // "revocability" should return what getConsentModification returns.
  final result = controller.getFeatures(informed, 'revocability');
  final expected = controller.model.getConsentModification(informed);
  expect(result, equals(expected));
});

// Verify that getFeatures returns an empty map when dimension is not recognized.
test('getFeatures returns default data for unknown dimension', () {
  final informed = ConsentModel.informed();
  // Passing an unknown dimension should return the default value.
  final result = controller.getFeatures(informed, 'unknown');
  expect(result, equals({'main': <String>[], 'sub': <String>[]}));
});
  });



  // ----------------------------
  // CompareView Widget Tests
  // ----------------------------
group('CompareView Widget Tests', () {
  // Test that when two models are selected, the compare view displays the dimension focus and model names.
  testWidgets('model selection flow works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompareScreen(),
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
      const MaterialApp(
        home: CompareScreen(),
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

    // Verify that the dimension description contains expected text.
    expect(find.textContaining('Technical controls'), findsOneWidget);
  });

  // Test navigation from the compare screen to the simulation screen.
  testWidgets('navigation to simulation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompareScreen(),
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
      const MaterialApp(
        home: CompareScreen(),
      ),
    );

    // No models are selected.
    expect(find.text('Choose Two Models'), findsOneWidget);
    expect(find.text('Select two consent models to explore their unique characteristics'), findsOneWidget);
  });
});

group('ConsentFlowVisualization Widget Tests', () {
  testWidgets('renders all steps and allows expanding/collapsing', (WidgetTester tester) async {
    final steps = [
      ConsentStep(
        title: 'Step 1',
        icon: Icons.check_circle_outline,
        details: ['Detail 1', 'Detail 2'],
      ),
      ConsentStep(
        title: 'Step 2',
        icon: Icons.settings_outlined,
        details: ['Detail 3', 'Detail 4', 'Detail 5'],
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColor: AppTheme.primaryColor,
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        home: Scaffold(
          body: ConsentFlowVisualization(
            modelName: 'Test Model',
            steps: steps,
          ),
        ),
      ),
    );

    // Verify model name is displayed
    expect(find.text('Test Model'), findsOneWidget);
    
    // Verify step titles are displayed
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    
    // Initially, details should not be visible (collapsed)
    expect(find.text('Detail 1'), findsNothing);
    expect(find.text('Detail 3'), findsNothing);

    // Tap on first step to expand it
    await tester.tap(find.text('Step 1'));
    await tester.pumpAndSettle();
    
    // Now the details for the first step should be visible
    expect(find.text('Detail 1'), findsOneWidget);
    expect(find.text('Detail 2'), findsOneWidget);
    
    // But the second step's details should still be hidden
    expect(find.text('Detail 3'), findsNothing);
    
    // Tap on second step to expand it
    await tester.tap(find.text('Step 2'));
    await tester.pumpAndSettle();
    
    // Now the first step should collapse and the second step should expand
    expect(find.text('Detail 1'), findsNothing);
    expect(find.text('Detail 3'), findsOneWidget);
    expect(find.text('Detail 4'), findsOneWidget);
    expect(find.text('Detail 5'), findsOneWidget);
    
    // Tap on second step again to collapse it
    await tester.tap(find.text('Step 2'));
    await tester.pumpAndSettle();
    
    // Now all details should be hidden again
    expect(find.text('Detail 1'), findsNothing);
    expect(find.text('Detail 3'), findsNothing);
    
    // Verify presence of chevron icons in the collapsed state
    expect(find.byIcon(Icons.expand_more), findsNWidgets(2));
  });
});
}



