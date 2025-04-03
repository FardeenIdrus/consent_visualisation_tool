// Represents a consent model with a name.

class ConsentModel {
  final String name;

   // Constructor for creating a ConsentModel instance
  ConsentModel({required this.name});

  factory ConsentModel.granular() {
    return ConsentModel(name: 'Granular Consent');
  }

  factory ConsentModel.affirmative() {
    return ConsentModel(name: 'Affirmative Consent');
  }

  factory ConsentModel.informed() {
    return ConsentModel(name: 'Informed Consent');
  }

  factory ConsentModel.dynamic() {
    return ConsentModel(name: 'Dynamic Consent');
  }

  factory ConsentModel.implied() {
    return ConsentModel(name: 'Implied Consent');
  }
}

/// Utility class that provides a list of all available consent models.
class ConsentModelList {
  static List<ConsentModel> getAvailableModels() {
    return [
      ConsentModel.granular(),
      ConsentModel.affirmative(),
      ConsentModel.informed(),
      ConsentModel.dynamic(),
      ConsentModel.implied(),
    ];
  }
}
