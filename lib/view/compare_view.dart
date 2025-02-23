// lib/view/compare_view.dart
import 'package:flutter/material.dart';
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/chat_interface_view.dart';
import '../theme/app_theme.dart';

/// A screen that allows users to compare two consent models in a flowchart-style layout.
/// When two models are selected, the three dimensions appear as vertical expandable blocks.
/// Each block shows a header with a summary and, when expanded, displays a side-by-side
/// comparison of the details for the two models.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final CompareController controller = CompareController();

  // Definition of dimensions with metadata.
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
    },
  };

  @override
  void initState() {
    super.initState();
    controller.selectedModels.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.selectedModels.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildModelSelector(),
          Expanded(
            child: ValueListenableBuilder<List<ConsentModel>>(
              valueListenable: controller.selectedModels,
              builder: (context, selectedModels, _) {
                if (selectedModels.length != 2) {
                  return _buildSelectionPrompt();
                }
                return _buildFlowchart(selectedModels);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Consent Model Comparison'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.backgroundColor,
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

  /// Builds the vertical flowchart.
  Widget _buildFlowchart(List<ConsentModel> selectedModels) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dimensions.keys.length,
      separatorBuilder: (context, index) => Center(
        child: Icon(Icons.arrow_downward, color: AppTheme.primaryColor, size: 30),
      ),
      itemBuilder: (context, index) {
        final dimensionKey = dimensions.keys.elementAt(index);
        final dimensionData = dimensions[dimensionKey]!;
        return FlowchartBlock(
          dimensionKey: dimensionKey,
          dimensionTitle: dimensionData['title'] as String,
          dimensionDescription: dimensionData['description'] as String,
          modelA: selectedModels[0],
          modelB: selectedModels[1],
          controller: controller,
        );
      },
    );
  }
}

/// A widget representing an individual flowchart block for one comparison dimension.
class FlowchartBlock extends StatefulWidget {
  final String dimensionKey;
  final String dimensionTitle;
  final String dimensionDescription;
  final ConsentModel modelA;
  final ConsentModel modelB;
  final CompareController controller;

  const FlowchartBlock({
    super.key,
    required this.dimensionKey,
    required this.dimensionTitle,
    required this.dimensionDescription,
    required this.modelA,
    required this.modelB,
    required this.controller,
  });

  @override
  _FlowchartBlockState createState() => _FlowchartBlockState();
}

class _FlowchartBlockState extends State<FlowchartBlock> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Retrieve feature maps based on dimension.
    Map<String, dynamic> getFeatures(ConsentModel model) {
      switch (widget.dimensionKey) {
        case 'initial':
          return widget.controller.model.getInitialConsentProcess(model);
        case 'permissions':
          return widget.controller.model.getControlMechanisms(model);
        case 'revocability':
          return widget.controller.model.getConsentModification(model);
        default:
          return {'main': <String>[], 'sub': <String>[]};
      }
    }
    final featuresA = getFeatures(widget.modelA);
    final featuresB = getFeatures(widget.modelB);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, dimension title (in black), and expand/collapse indicator.
              Row(
                children: [
                  Icon(
                    widget.dimensionKey == 'initial'
                        ? Icons.start_outlined
                        : widget.dimensionKey == 'permissions'
                            ? Icons.security_outlined
                            : Icons.change_circle_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.dimensionTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dimension description in black.
              Text(
                widget.dimensionDescription,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                // Side-by-side comparison of features.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeaturesColumn(featuresA, widget.modelA.name)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFeaturesColumn(featuresB, widget.modelB.name)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the feature column for a given model.
  Widget _buildFeaturesColumn(Map<String, dynamic> features, String modelName) {
    // Check for pathways type (for Affirmative Consent, etc.)
    if (features.containsKey('type') && features['type'] == 'pathways') {
      return _buildPathwaysColumn(features, modelName);
    }
    List<Widget> items = [];
    // Model name in blue.
    items.add(Text(
      modelName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ));
    items.add(const SizedBox(height: 8));
    // "Main" features in black, bold.
    if (features['main'] != null) {
      items.addAll((features['main'] as List<String>).map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "• " + item,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )));
    }
    // "Sub" features in black, italic.
    if (features['sub'] != null) {
      items.addAll((features['sub'] as List<String>).map((item) => Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: Text(
              "◦ " + item,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          )));
    }
    // "Additional" features in black, bold.
    if (features['additional'] != null) {
      items.addAll((features['additional'] as List<String>).map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "• " + item,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  /// Builds a pathways column for models that use the 'pathways' type.
  Widget _buildPathwaysColumn(Map<String, dynamic> features, String modelName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          modelName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        _buildPathwayItem(features['pathway1']),
        const SizedBox(height: 8),
        _buildPathwayItem(features['pathway2']),
      ],
    );
  }

  /// Builds an individual pathway item.
  Widget _buildPathwayItem(Map<String, dynamic> pathwayData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pathwayData['title'] as String,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (pathwayData['steps'] as List<String>)
              .map((step) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
                    child: Text(
                      "• " + step,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}





