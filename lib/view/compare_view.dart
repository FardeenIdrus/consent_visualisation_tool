// lib/view/compare_view.dart
import 'package:flutter/material.dart';
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart';
import '../theme/app_theme.dart';

/// A screen that allows users to compare two consent models across different dimensions.
///
/// This widget displays a UI for selecting and comparing consent models side by side,
/// highlighting their differences in initial consent processes, permission controls,
/// and modification capabilities.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  /// Controller that manages the comparison state and logic
  final CompareController controller = CompareController();
  
  /// Local tracking of selected dimension (initial, permissions, revocability)
  String selectedDimension = 'initial';

  /// Definition of available comparison dimensions with their metadata
  final Map<String, Map<String, Object>> dimensions = {
    'initial': {
      'title': 'Initial Consent Process',
      'description': 'How consent is first established and obtained',
      'icon': Icons.start_outlined,
    },
    'permissions': {
      'title': 'Permission Granularity',
      'description': 'Technical controls and restrictions at the point of sharing',
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
    super.initState();
    // Listen to changes in selected dimension
    controller.selectedDimension.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    controller.selectedDimension.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildModelSelector(),
          _buildDimensionSelector(),
          Expanded(
            child: ValueListenableBuilder<List<ConsentModel>>(
              valueListenable: controller.selectedModels,
              builder: (context, selectedModels, child) {
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

  /// Builds the app bar with action buttons
  ///
  /// Includes a simulation button that appears when two models are selected
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Consent Model Comparison'),
      centerTitle: true,
      elevation: 0,
      actions: [
        ValueListenableBuilder<List<ConsentModel>>(
          valueListenable: controller.selectedModels,
          builder: (context, selectedModels, child) {
            return selectedModels.length == 2
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Start Simulation',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimulationScreen(),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Builds the model selection area
  ///
  /// Displays available consent models as chips, allowing selection of up to two
  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            builder: (context, selectedModels, child) {
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
                      color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textPrimaryColor,
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

  /// Builds the dimension selection toolbar
  ///
  /// Allows users to switch between comparing initial consent, permissions, or revocability
  Widget _buildDimensionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dimensions.entries.map((entry) {
            final isSelected = controller.selectedDimension.value == entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Row(
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      size: 20,
                      color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(entry.value['title'] as String),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => controller.changeDimension(entry.key),
                selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the comparison section
  ///
  /// Contains the dimension description and the main comparison content
  Widget _buildComparison(List<ConsentModel> models) {
    return Column(
      children: [
        _buildDimensionDescription(),
        Expanded(
          child: _buildComparisonContent(models),
        ),
      ],
    );
  }

  /// Builds the description text for the currently selected dimension
  Widget _buildDimensionDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Text(
        dimensions[controller.selectedDimension.value]?['description'] as String? ?? 
          'Select a dimension to compare',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Builds the main comparison content area showing models side by side
  ///
  /// Retrieves appropriate feature data based on the selected dimension
  /// and displays it in a side-by-side card layout
  Widget _buildComparisonContent(List<ConsentModel> models) {
    final features = {
      'initial': controller.model.getInitialConsentProcess,
      'permissions': controller.model.getControlMechanisms,
      'revocability': controller.model.getConsentModification,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: models.map((model) {
          final modelFeatures = features[controller.selectedDimension.value]!(model);
          
          return Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildFeatureList(modelFeatures),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a list of features for a consent model
  ///
  /// Handles different feature structures including special case for Affirmative Consent
  /// which uses a pathway-based structure
  Widget _buildFeatureList(Map<String, dynamic> modelFeatures) {
    List<Widget> featureWidgets = [];

    // Handle special case for Affirmative Consent pathways
    if (modelFeatures['type'] == 'pathways') {
      featureWidgets.addAll([
        _buildPathwaySection(modelFeatures['pathway1']),
        const SizedBox(height: 16),
        _buildPathwaySection(modelFeatures['pathway2']),
      ]);
    } else {
      // Main features
      if (modelFeatures['main'] != null) {
        featureWidgets.addAll(
          (modelFeatures['main'] as List<String>).map((feature) => 
            _buildFeatureItem(feature, false)
          )
        );
      }

      // Sub features 
      if (modelFeatures['sub'] != null && (modelFeatures['sub'] as List<String>).isNotEmpty) {
        featureWidgets.add(const SizedBox(height: 8));
        featureWidgets.addAll(
          (modelFeatures['sub'] as List<String>).map((feature) => 
            _buildFeatureItem(feature, true)
          )
        );
      }

      // Additional features 
      if (modelFeatures['additional'] != null) {
        featureWidgets.add(const SizedBox(height: 8));
        featureWidgets.addAll(
          (modelFeatures['additional'] as List<String>).map((feature) => 
            _buildFeatureItem(feature, false)
          )
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: featureWidgets,
    );
  }

  /// Builds a pathway section for Affirmative Consent

  Widget _buildPathwaySection(Map<String, dynamic> pathwayData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pathwayData['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...((pathwayData['steps'] as List<String>).map((step) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ).toList()),
        ],
      ),
    );
  }

  /// Builds a single feature item with a bullet point
  Widget _buildFeatureItem(String feature, bool isSubFeature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: isSubFeature ? 4 : 6,
            height: isSubFeature ? 4 : 6,
            decoration: BoxDecoration(
              color: isSubFeature 
                ? AppTheme.textSecondaryColor 
                : AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: isSubFeature 
                  ? AppTheme.textSecondaryColor 
                  : AppTheme.textPrimaryColor,
                fontSize: isSubFeature ? 14 : 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPrompt() {
    return Center(
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
    );
  }
}
