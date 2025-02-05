class ConsentModel {
  final String name;
  final String description;

  ConsentModel({required this.name, required this.description});
}

class CompareScreenModel {
  final List<ConsentModel> consentModels = [
    ConsentModel(name: 'Informed Consent', description: '...'),
    ConsentModel(name: 'Affirmative Consent', description: '...'),
    // Add more consent models
  ];
}