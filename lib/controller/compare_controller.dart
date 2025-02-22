// lib/controller/compare_controller.dart

import 'package:consent_visualisation_tool/model/compare_model.dart';
import 'package:consent_visualisation_tool/model/consent_models.dart';
import 'package:flutter/foundation.dart';

/// Controller for the compare screen.
class CompareController {
  /// The model used to store the state of the compare screen.
  final CompareScreenModel model = CompareScreenModel();
  
  /// The currently selected models for comparison.
  ValueNotifier<List<ConsentModel>> selectedModels = 
    ValueNotifier<List<ConsentModel>>([]);
    
  /// The currently selected dimension for comparison.
  ValueNotifier<String> selectedDimension = ValueNotifier<String>('initial');

  /// Toggles the selection of a consent model.
  ///
  /// If the model is already selected, it is removed from the selection.
  /// If the model is not selected and there are less than 2 models selected,
  /// it is added to the selection.
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

  /// Resets the selection of models.
  void resetSelection() {
    selectedModels.value = [];
  }
  
  /// Changes the currently selected dimension.
  void changeDimension(String dimension) {
    selectedDimension.value = dimension;
  }
  
  /// Returns a map of features for the given consent model based on the
  /// selected dimension.
  Map<String, dynamic> getFeatures(ConsentModel consentModel, String dimension) {
    switch (dimension) {
      case 'initial':
        return model.getInitialConsentProcess(consentModel);
      case 'permissions':
        return model.getControlMechanisms(consentModel);
      case 'revocability':
        return model.getConsentModification(consentModel);
      default:
        return {'main': <String>[], 'sub': <String>[]};
    }
  }
}
