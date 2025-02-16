import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/simulation_view.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final CompareController controller = CompareController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure Image Exchange - Consent Preferences'),
        actions: [
  ValueListenableBuilder<List<ConsentModel>>(
    valueListenable: controller.selectedModels,
    builder: (context, selectedModels, child) {
      return selectedModels.length == 2 
        ? IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
                  Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => const SimulationScreen()
        )
        );
            },
            tooltip: 'View Simulation ',
          )
        : SizedBox.shrink();
    },
  )
]
      ),
      body: ValueListenableBuilder<List<ConsentModel>>(
        valueListenable: controller.selectedModels,
        builder: (context, selectedModels, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose your preferred consent model for sharing intimate images',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildConsentModelSelectionRow(),
              
              Expanded(
                child: selectedModels.length == 2 
                  ? _buildDetailedComparisonView(selectedModels)
                  : _buildSelectModelsPrompt(),
              ),
              if (selectedModels.length == 2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => SimulationScreen()
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'View how these models would work in a chat interface',
                style: TextStyle(color: Colors.white),)))
            ],
          );
        },
      ),
    );
  }

  Widget _buildConsentModelSelectionRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: controller.model.consentModels.map((model) {
            return ValueListenableBuilder<List<ConsentModel>>(
              valueListenable: controller.selectedModels,
              builder: (context, selectedModels, child) {
                final isSelected = selectedModels.contains(model);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(model.name),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleModelSelection(model),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

Widget _buildDetailedComparisonView(List<ConsentModel> selectedModels) {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildComparisonSection(
        'Initial Consent Process',
        selectedModels,
        (model) => controller.model.getInitialConsentProcess(model),
      ),
      _buildComparisonSection(
        'Control Mechanisms',
        selectedModels,
        (model) => controller.model.getControlMechanisms(model),
      ),
      _buildComparisonSection(
        'Consent Control & Modification',
        selectedModels,
        (model) => controller.model.getConsentModification(model),
      ),
      _buildCharacteristicsSection(selectedModels),
      _buildRisksSection(selectedModels),
    ],
  );
}

Widget _buildComparisonSection(
  String title,
  List<ConsentModel> models,
  String Function(ConsentModel) getValue,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: models.map((model) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getValue(model),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCharacteristicsSection(List<ConsentModel> models) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Characteristics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: models.map((model) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...model.keyCharacteristics.map((characteristic) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, 
                            size: 16, 
                            color: AppTheme.primaryColor
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              characteristic,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRisksSection(List<ConsentModel> models) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Associated Risks',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: models.map((model) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...model.risks.map((risk) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, 
                            size: 16, 
                            color: Colors.orange
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              risk,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildSelectModelsPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 100,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 20),
            Text(
              'Select two consent models to compare',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}