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

class _CompareScreenState extends State<CompareScreen> {
  final CompareController controller = CompareController();
  String selectedDimension = 'initial';  // 'initial', 'permissions', 'revocability'

  final dimensions = {
    'initial': {
      'title': 'Initial Consent Process',
      'icon': Icons.start,
      'description': 'How consent is first established and obtained'
    },
    'permissions': {
      'title': 'Permission Controls',
      'icon': Icons.security,
      'description': 'Technical controls and restrictions at sharing'
    },
    'revocability': {
      'title': 'Modification & Revocation',
      'icon': Icons.update,
      'description': 'Post-sharing control and modification options'
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Consent Models'),
        elevation: 0,
        actions: [
          ValueListenableBuilder<List<ConsentModel>>(
            valueListenable: controller.selectedModels,
            builder: (context, selectedModels, child) {
              return selectedModels.length == 2
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.play_arrow, color: Colors.white),
                        label: Text('Try Simulation', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SimulationScreen()),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModelSelector(),
          ValueListenableBuilder<List<ConsentModel>>(
            valueListenable: controller.selectedModels,
            builder: (context, selectedModels, child) {
              if (selectedModels.length != 2) {
                return Expanded(child: _buildSelectionPrompt());
              }
              return Expanded(child: _buildComparison(selectedModels));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Two Models to Compare',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          ValueListenableBuilder<List<ConsentModel>>(
            valueListenable: controller.selectedModels,
            builder: (context, selectedModels, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.model.consentModels.map((model) {
                  final isSelected = selectedModels.contains(model);
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: MaterialButton(
                      onPressed: () => controller.toggleModelSelection(model),
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          model.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
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

  Widget _buildComparison(List<ConsentModel> models) {
    return Column(
      children: [
        _buildDimensionSelector(),
        Expanded(
          child: _buildComparisonContent(models),
        ),
      ],
    );
  }

  Widget _buildDimensionSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: dimensions.entries.map((entry) {
          final isSelected = selectedDimension == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDimension = entry.key),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                    SizedBox(height: 8),
                    Text(
                      entry.value['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
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
  }// Inside the _buildComparisonContent method in compare_screen.dart

Widget _buildComparisonContent(List<ConsentModel> models) {
  final features = {
    'initial': controller.model.getInitialConsentProcess,
    'permissions': controller.model.getControlMechanisms,
    'revocability': controller.model.getConsentModification,
  };

  return Container(
    padding: EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: models.map((model) {
        final modelFeatures = features[selectedDimension]!(model);
        
        return Expanded(
          child: Card(
            margin: EdgeInsets.all(8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Divider(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.name == 'Affirmative Consent' && 
                              selectedDimension == 'initial' &&
                              modelFeatures['type'] == 'pathways') ...[
                            _buildPathwaySection(modelFeatures['pathway1'] as Map<String, dynamic>),
                            SizedBox(height: 8),
                            _buildPathwaySection(modelFeatures['pathway2'] as Map<String, dynamic>),
                          ] else ...[
                            ...(modelFeatures['main'] as List<String>).map((feature) => 
                              _buildFeatureItem(feature, false)
                            ),
                            if ((modelFeatures['sub'] as List<String>?)?.isNotEmpty ?? false) ...[
                              ...(modelFeatures['sub'] as List<String>).map((feature) => 
                                _buildFeatureItem(feature, true)
                              ),
                            ],
                            if ((modelFeatures['additional'] as List<String>?)?.isNotEmpty ?? false) ...[
                              ...(modelFeatures['additional'] as List<String>).map((feature) => 
                                _buildFeatureItem(feature, false)
                              ),
                            ],
                          ],
                        ],
                      ),
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

Widget _buildPathwaySection(Map<String, dynamic> pathwayData) {
  return ExpansionTile(
    title: Text(
      pathwayData['title'] as String,
      style: TextStyle(
        color: AppTheme.textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (pathwayData['steps'] as List<String>).map((step) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

  Widget _buildFeatureItem(String feature, bool isSubFeature) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSubFeature ? 32 : 16,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6, right: 8),
            width: isSubFeature ? 4 : 6,
            height: isSubFeature ? 4 : 6,
            decoration: BoxDecoration(
              color: isSubFeature ? AppTheme.textSecondaryColor : AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: isSubFeature ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
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
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.compare_arrows,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Choose Any Two Models',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select two consent models above to see a detailed comparison',
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