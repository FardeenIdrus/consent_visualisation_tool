import 'package:consent_visualisation_tool/controller/compare_controller.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompareScreen extends StatelessWidget {
  final CompareController controller = CompareController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compare Consent Models')),
      body: ListView.builder(
        itemCount: controller.model.consentModels.length,
        itemBuilder: (context, index) {
          final model = controller.model.consentModels[index];
          return Card(
            child: ListTile(
              title: Text(model.name),
              subtitle: Text(model.description),
            ),
          );
        },
      ),
    );
  }
}