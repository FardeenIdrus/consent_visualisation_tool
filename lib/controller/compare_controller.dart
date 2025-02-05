import 'package:consent_visualisation_tool/model/compare_model.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:flutter/foundation.dart';


class CompareController {
  final CompareScreenModel model = CompareScreenModel();
  
  // Selected models for comparison
  ValueNotifier<List<ConsentModel>> selectedModels = 
    ValueNotifier<List<ConsentModel>>([]);

  void toggleModelSelection(ConsentModel model) {
    final currentSelection = List<ConsentModel>.from(selectedModels.value);
    
    if (currentSelection.contains(model)) {
      currentSelection.remove(model);
    } else {
      if (currentSelection.length < 2) {
        currentSelection.add(model);
      }
    }
    
    selectedModels.value = currentSelection;
  }

  void resetSelection() {
    selectedModels.value = [];
  }
}