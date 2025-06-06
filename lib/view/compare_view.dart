import 'package:consent_visualisation_tool/view/consent_flow.dart';
import 'package:flutter/material.dart';
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart';
import '../theme/app_theme.dart';

/// Screen for comparing different consent models across key dimensions
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final CompareController controller = CompareController();
  // Local tracking of the selected dimension. This is kept in sync with the controller.
  String selectedDimension = 'initial';

  // Defines the three key dimensions used to compare consent models:
  /// - Initial Consent Process: How consent is first established
  /// - Permission Granularity: Technical controls at sharing time
  /// - Modification & Revocation: Post-sharing control options
  final Map<String, Map<String, Object>> dimensions = {
    'initial': {
      'title': 'Initial Consent Process',
      'description': 'How consent is first established and obtained',
      'icon': Icons.start_outlined,
    },
    'permissions': {
      'title': 'Permission Granularity',
      'description': 'Technical controls and restrictions provided to the sender at the point of sharing',
      'icon': Icons.security_outlined,
    },
    'revocability': {
      'title': 'Modification & Revocation',
      'description': 'Post-sharing control and modification options',
      'icon': Icons.change_circle_outlined,
    }
  };

  @override
  void initState() {
    // Set up listeners to sync UI with controller state changes
    super.initState();
    controller.selectedModels.addListener(() {
      setState(() {});
    });
    controller.selectedDimension.addListener(() {
      setState(() {
        selectedDimension = controller.selectedDimension.value;
      });
    });
  }

  @override
  void dispose() {
    controller.selectedModels.removeListener(() {});
    controller.selectedDimension.removeListener(() {});
    super.dispose();
  }

  // Build the steps for a given consent model based on the currently selected dimension.
  List<ConsentStep> _getStepsForModel(ConsentModel model) {
    final modelData = controller.getFeatures(model, controller.selectedDimension.value);
    if (modelData['type'] == 'pathways') {
      return _buildPathwaySteps(modelData);
    }
    return _buildStandardSteps(modelData);
  }

  /// Creates a two-pathway consent flow for models that offer distinct consent flows
  /// sender-initiated vs. recipient-requested for Affirmative Consent
  List<ConsentStep> _buildPathwaySteps(Map<String, dynamic> modelData) {
    return [
      ConsentStep(
        title: modelData['pathway1']['title'],
        icon: Icons.person_add_outlined,
        details: List<String>.from(modelData['pathway1']['steps']),
      ),
      ConsentStep(
        title: modelData['pathway2']['title'],
        icon: Icons.people_outlined,
        details: List<String>.from(modelData['pathway2']['steps']),
      ),
    ];
  }

// Creates a standard visualisation showing Primary Features, Capabilities, and Key Implications of a consent model

List<ConsentStep> _buildStandardSteps(Map<String, dynamic> modelData) {
  List<ConsentStep> steps = [];

  if (modelData['main'] != null) {
    steps.add(ConsentStep(
      title: 'Primary Features',
      icon: Icons.check_circle_outline,
      details: List<String>.from(modelData['main']),
    ));
  }

  // Add handling for risk_disclosure
  if (modelData['risk_disclosure'] != null) {
    steps.add(ConsentStep(
      title: 'Risk Disclosure',
      icon: Icons.warning_outlined,  // Using warning icon for risks
      details: List<String>.from(modelData['risk_disclosure']),
    ));
  }

  if (modelData['sub'] != null && (modelData['sub'] as List).isNotEmpty) {
    steps.add(ConsentStep(
      title: 'Capabilities',
      icon: Icons.settings_outlined,
      details: List<String>.from(modelData['sub']),
    ));
  }

  if (modelData['additional'] != null) {
    steps.add(ConsentStep(
      title: 'Key Implications',
      icon: Icons.info_outline,
      details: List<String>.from(modelData['additional']),
    ));
  }

  return steps;
}

  // Builds the dimension selector row.
Widget _buildDimensionSelector() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: dimensions.entries.map((entry) {
          final isSelected = controller.selectedDimension.value == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => controller.changeDimension(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value['title'] as String,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}


  // Builds the dimension focus section that displays the description.
  Widget _buildDimensionDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: const Border(
          left: BorderSide(
            color: AppTheme.primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dimension Focus',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dimensions[controller.selectedDimension.value]?['description'] as String? ??
                'Select a dimension to compare',
            style: const TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the main comparison section.
Widget _buildComparison(List<ConsentModel> models) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        // For small screens, stack panels vertically.
        return Column(
          children: [
            _buildDimensionDescription(),
            const SizedBox(height: 8),
            // Divider with key outside ScrollView for easy test access
            const Divider(key: Key('verticalDivider')),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ConsentFlowVisualization(
                      modelName: models[0].name,
                      steps: _getStepsForModel(models[0]),
                    ),
                    const Divider(),
                    ConsentFlowVisualization(
                      modelName: models[1].name,
                      steps: _getStepsForModel(models[1]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        // For larger screens, show side-by-side.
        return Column(
          children: [
            _buildDimensionDescription(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConsentFlowVisualization(
                          modelName: models[0].name,
                          steps: _getStepsForModel(models[0]),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConsentFlowVisualization(
                          modelName: models[1].name,
                          steps: _getStepsForModel(models[1]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    },
  );
}



  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Consent Model Comparison'),
      centerTitle: true,
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      actions: [
        ValueListenableBuilder<List<ConsentModel>>(
          valueListenable: controller.selectedModels,
          builder: (context, selectedModels, _) {
            return selectedModels.length == 2
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimulationScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text(
                        "See how these models work in a chat interface",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Two Models to Compare',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<ConsentModel>>(
            valueListenable: controller.selectedModels,
            builder: (context, selectedModels, _) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.model.consentModels.map((model) {
                  final isSelected = selectedModels.contains(model);
                  return ChoiceChip(
                    label: Text(model.name),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleModelSelection(model),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

Widget _buildSelectionPrompt() {
  return SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Two Models',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select two consent models to explore their unique characteristics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildModelSelector(),
          _buildDimensionSelector(),
          Expanded(
            child: ValueListenableBuilder<List<ConsentModel>>(
              valueListenable: controller.selectedModels,
              builder: (context, selectedModels, _) {
                if (selectedModels.length != 2) {
                  return _buildSelectionPrompt();
                }
                return _buildComparison(selectedModels);
              },
            ),
          ),
        ],
      ),
    );
  }
}








