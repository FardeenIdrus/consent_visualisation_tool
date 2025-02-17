// lib/view/compare_screen.dart
import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:consent_visualisation_tool/view/simulation_view.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> with SingleTickerProviderStateMixin {
  final CompareController controller = CompareController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent Model Comparison'),
        elevation: 0,
        actions: [
          ValueListenableBuilder<List<ConsentModel>>(
            valueListenable: controller.selectedModels,
            builder: (context, selectedModels, child) {
              return selectedModels.length == 2
                  ? Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.play_arrow, color: Colors.white),
                        label: Text('Try Simulation', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SimulationScreen(),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox.shrink();
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: ValueListenableBuilder<List<ConsentModel>>(
          valueListenable: controller.selectedModels,
          builder: (context, selectedModels, child) {
            return Column(
              children: [
                _buildHeader(context),
                _buildConsentModelSelectionRow(),
                Expanded(
                  child: selectedModels.length == 2
                      ? FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildDetailedComparisonView(selectedModels),
                        )
                      : _buildSelectModelsPrompt(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Compare Consent Models',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore and understand different approaches to digital consent',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentModelSelectionRow() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      elevation: isSelected ? 4 : 0,
                    ),
                  );
                },
              );
            }).toList(),
          ),
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
          Icons.start,
        ),
        _buildComparisonSection(
          'Permission Controls',
          selectedModels,
          (model) => controller.model.getControlMechanisms(model),
          Icons.security,
        ),
        _buildComparisonSection(
          'Modification & Revocation',
          selectedModels,
          (model) => controller.model.getConsentModification(model),
          Icons.update,
        ),
      ],
    );
  }

// Update the _buildComparisonSection method in your CompareScreen

Widget _buildComparisonSection(
  String title,
  List<ConsentModel> models,
  String Function(ConsentModel) getValue,
  IconData icon,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 24),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.backgroundColor.withOpacity(0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Models Comparison
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: models.map((model) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model Name Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          model.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Model Features List
                      _buildFeaturesList(getValue(model)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFeaturesList(String features) {
  // Split the features string into individual bullet points
  final points = features.split('\n')
    .where((line) => line.trim().isNotEmpty)
    .map((line) => line.trim())
    .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: points.map((point) {
      // Check if it's a main point or sub-point
      final isSubPoint = point.startsWith('-');
      final text = point.replaceFirst(RegExp(r'^[•-]\s*'), '');

      return Padding(
        padding: EdgeInsets.only(
          left: isSubPoint ? 16.0 : 0,
          bottom: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSubPoint) ...[
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSubPoint 
                    ? AppTheme.textSecondaryColor 
                    : AppTheme.textPrimaryColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

  Widget _buildSelectModelsPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.compare_arrows,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Choose Any Two Models',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Select two consent models above to see a detailed comparison',
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