// test/compare_feature_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/compare_model.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/compare_view.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart';

void main() {
  group('CompareController Tests', () {
    late CompareController controller;

    setUp(() {
      controller = CompareController();
    });

    test('initially has empty selected models', () {
      expect(controller.selectedModels.value.length, 0);
    });

    test('toggleModelSelection adds model when not already selected', () {
      final model = ConsentModel.informed();
      controller.toggleModelSelection(model);
      expect(controller.selectedModels.value.length, 1);
      expect(controller.selectedModels.value.contains(model), true);
    });

    test('toggleModelSelection removes model when already selected', () {
      final model = ConsentModel.informed();
      controller.toggleModelSelection(model);
      controller.toggleModelSelection(model);
      expect(controller.selectedModels.value.length, 0);
    });

    test('toggleModelSelection limits selection to 2 models', () {
      controller.toggleModelSelection(ConsentModel.informed());
      controller.toggleModelSelection(ConsentModel.affirmative());
      controller.toggleModelSelection(ConsentModel.granular());
      expect(controller.selectedModels.value.length, 2);
    });

    test('resetSelection clears selected models', () {
      controller.toggleModelSelection(ConsentModel.informed());
      controller.toggleModelSelection(ConsentModel.affirmative());
      controller.resetSelection();
      expect(controller.selectedModels.value.length, 0);
    });

    test('changeDimension updates selectedDimension', () {
      controller.changeDimension('permissions');
      expect(controller.selectedDimension.value, 'permissions');
    });
  });

  group('CompareModel Tests', () {
    late CompareScreenModel model;

    setUp(() {
      model = CompareScreenModel();
    });

    test('consentModels returns list of models', () {
      expect(model.consentModels.length, 5);
      
      // Verify all expected models exist
      final modelNames = model.consentModels.map((m) => m.name).toList();
      expect(modelNames, contains('Informed Consent'));
      expect(modelNames, contains('Affirmative Consent'));
      expect(modelNames, contains('Dynamic Consent'));
      expect(modelNames, contains('Granular Consent'));
      expect(modelNames, contains('Implied Consent'));
    });

    test('getInitialConsentProcess returns correct structure for Informed Consent', () {
      final result = model.getInitialConsentProcess(ConsentModel.informed());
      expect(result.containsKey('main'), true);
      expect(result.containsKey('sub'), true);
      expect(result.containsKey('additional'), true);
      
      final mainList = result['main'] as List<String>;
      final subList = result['sub'] as List<String>;
      expect(mainList.isNotEmpty, true);
      expect(subList.isNotEmpty, true);
      
      if (mainList.isNotEmpty) {
        expect(mainList[0], contains('Risk disclosure panel'));
      }
    });

    test('getInitialConsentProcess returns pathways for Affirmative Consent', () {
      final result = model.getInitialConsentProcess(ConsentModel.affirmative());
      expect(result['type'], 'pathways');
      expect(result.containsKey('pathway1'), true);
      expect(result.containsKey('pathway2'), true);
      
      final pathway1 = result['pathway1'] as Map<String, dynamic>;
      final pathway2 = result['pathway2'] as Map<String, dynamic>;
      
      expect(pathway1['title'], 'Sender-Initiated Sharing');
      expect(pathway2['title'], 'Recipient Requests Image');
    });

    test('getControlMechanisms returns expected structure', () {
      final result = model.getControlMechanisms(ConsentModel.granular());
      expect(result.containsKey('main'), true);
      
      final mainList = result['main'] as List<String>;
      expect(mainList.isNotEmpty, true);
      
      if (mainList.isNotEmpty) {
        expect(mainList[0], contains('can set explicit sharing permissions'));
      }
    });

    test('getConsentModification returns expected structure', () {
      final result = model.getConsentModification(ConsentModel.dynamic());
      expect(result.containsKey('main'), true);
      
      final mainList = result['main'] as List<String>;
      expect(mainList.isNotEmpty, true);
      
      if (mainList.isNotEmpty) {
        expect(mainList[0], contains('ongoing consent management'));
      }
    });
  });

  group('CompareView Widget Tests', () {
    testWidgets('renders initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Check title is displayed
      expect(find.text('Consent Model Comparison'), findsOneWidget);
      
      // Check dimension selector is displayed
      expect(find.text('Initial Consent Process'), findsOneWidget);
      expect(find.text('Permission Granularity'), findsOneWidget);
      expect(find.text('Modification & Revocation'), findsOneWidget);
      
      // Check selection prompt is displayed (no models selected yet)
      expect(find.text('Choose Two Models'), findsOneWidget);
    });

    testWidgets('selecting models shows comparison view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Initially shows the selection prompt
      expect(find.text('Choose Two Models'), findsOneWidget);
      
      // Select two models
      await tester.tap(find.text('Informed Consent').first);
      await tester.pump();
      await tester.tap(find.text('Affirmative Consent').first);
      await tester.pump();
      
      // Selection prompt should be gone
      expect(find.text('Choose Two Models'), findsNothing);
      
      // Both selected models should be displayed
      expect(find.text('Informed Consent'), findsWidgets);
      expect(find.text('Affirmative Consent'), findsWidgets);
      
      // Cards should be displayed for comparison
      expect(find.byType(Card), findsNWidgets(2));
    });



testWidgets('changing dimension updates displayed content', (WidgetTester tester) async {
  // Set a larger surface size for testing
  tester.binding.window.physicalSizeTestValue = Size(1200, 800);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

  await tester.pumpWidget(
    MaterialApp(
      home: const CompareScreen(),
    ),
  );

  // Select two models
  await tester.tap(find.text('Informed Consent').first);
  await tester.pump();
  await tester.tap(find.text('Granular Consent').first);
  await tester.pump();
  
  // Initial dimension description should be visible
  expect(find.textContaining('consent is first established'), findsOneWidget);
  
  // Find and scroll to the "Permission Granularity" chip if needed
  final permissionsChip = find.text('Permission Granularity').first;
  await tester.ensureVisible(permissionsChip);
  await tester.tap(permissionsChip);
  await tester.pump();
  
  // Permissions dimension description should be visible
  expect(find.textContaining('controls and restrictions'), findsOneWidget);
  
  // Find and scroll to the "Modification & Revocation" chip if needed
  final revocabilityChip = find.text('Modification & Revocation').first;
  await tester.ensureVisible(revocabilityChip);
  await tester.tap(revocabilityChip);
  await tester.pump();
  
  // Revocability dimension description should be visible
  expect(find.textContaining('Post-sharing control'), findsOneWidget);
});

    testWidgets('displays pathway structure correctly for Affirmative Consent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Select Affirmative Consent
      await tester.tap(find.text('Affirmative Consent').first);
      await tester.pump();
      await tester.tap(find.text('Implied Consent').first);
      await tester.pump();
      
      // Check pathway headings
      expect(find.text('Sender-Initiated Sharing'), findsOneWidget);
      expect(find.text('Recipient Requests Image'), findsOneWidget);
      
      // Check pathway steps
      expect(find.text('Sender confirms intent to share image'), findsOneWidget);
      expect(find.text('Recipient must actively click "Accept" to proceed'), findsOneWidget);
    });

    testWidgets('simulator button appears when two models selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // No simulator button initially
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      
      // Select two models
      await tester.tap(find.text('Informed Consent').first);
      await tester.pump();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pump();
      
      // Simulator button should now appear
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('deselecting a model returns to prompt view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Select two models
      await tester.tap(find.text('Informed Consent').first);
      await tester.pump();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pump();
      
      // Comparison view should be visible
      expect(find.byType(Card), findsNWidgets(2));
      
      // Deselect one model
      await tester.tap(find.text('Informed Consent').first);
      await tester.pump();
      
      // Should return to selection prompt
      expect(find.text('Choose Two Models'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });
    
    testWidgets('navigation to simulation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompareScreen(),
        ),
      );

      // Select two models
      await tester.tap(find.text('Informed Consent').first);
      await tester.pump();
      await tester.tap(find.text('Granular Consent').first);
      await tester.pump();
      
      // Tap simulation button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      
      // Should navigate to simulation screen
      expect(find.byType(SimulationScreen), findsOneWidget);
    });
  });
}
