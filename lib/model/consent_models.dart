class ConsentModel {
  final String name;
  final String description;
  final List<String> risks;
  final List<String> keyCharacteristics;
  final Map<String, dynamic> experimentConfig;

  ConsentModel({
    required this.name,
    required this.description,
    required this.risks,
    required this.keyCharacteristics,
    required this.experimentConfig,
  });

  // Factory methods for each consent model

  factory ConsentModel.granular() {
    return ConsentModel(
      name: 'Granular Consent',
      description: 'Provides detailed, specific control over content sharing.',
      risks: [
        'Digital images can be copied despite protections',
        'Complete deletion may be impossible',
        'Images might be stored on recipient\'s device',
      ],
      keyCharacteristics: [
        'Detailed permission settings',
        'User-defined sharing conditions',
        'Precise access control'
      ],
      experimentConfig: {
        'viewingPermissions': [
          'Allow viewing',
          'Allow saving',
          'View duration options'
        ],
        'sharingRestrictions': [
          'Prevent screenshots',
          'Prevent forwarding',
        ]
      },
    );
  }

  factory ConsentModel.affirmative() {
    return ConsentModel(
      name: 'Affirmative Consent',
      description: 'Requires clear, proactive confirmation of participation.',
      risks: [
        'Potential communication barriers',
        'Requires continuous verification',
        'May feel overly formal'
      ],
      keyCharacteristics: [
        'Explicit agreement',
        'Voluntary participation',
        'Specific to actions'
      ],
      experimentConfig: {
        'confirmationSteps': [
          'Sender confirms intent to share',
          'Recipient accepts image receipt'
        ]
      },
    );
  }

    factory ConsentModel.informed() {
    return ConsentModel(
      name: 'Informed Consent',
      description: 'Requires clear, proactive confirmation of participation.',
      risks: [
        'Potential communication barriers',
        'Requires continuous verification',
        'May feel overly formal'
      ],
      keyCharacteristics: [
        'Explicit agreement',
        'Voluntary participation',
        'Specific to actions'
      ],
      experimentConfig: {
        'confirmationSteps': [
          'Sender confirms intent to share',
          'Recipient accepts image receipt'
        ]
      },
    );
  }

  factory ConsentModel.dynamic() {
    return ConsentModel(
      name: 'Dynamic Consent',
      description: 'Requires clear, proactive confirmation of participation.',
      risks: [
        'Potential communication barriers',
        'Requires continuous verification',
        'May feel overly formal'
      ],
      keyCharacteristics: [
        'Explicit agreement',
        'Voluntary participation',
        'Specific to actions'
      ],
      experimentConfig: {
        'confirmationSteps': [
          'Sender confirms intent to share',
          'Recipient accepts image receipt'
        ]
      },
    );
  }
    factory ConsentModel.implied() {
    return ConsentModel(
      name: 'Implied Consent',
      description: 'Requires clear, proactive confirmation of participation.',
      risks: [
        'Potential communication barriers',
        'Requires continuous verification',
        'May feel overly formal'
      ],
      keyCharacteristics: [
        'Explicit agreement',
        'Voluntary participation',
        'Specific to actions'
      ],
      experimentConfig: {
        'confirmationSteps': [
          'Sender confirms intent to share',
          'Recipient accepts image receipt'
        ]
      },
    );
  }

  
}

class ConsentModelList {
  static List<ConsentModel> getAvailableModels() {
    return [
      ConsentModel.granular(),
      ConsentModel.affirmative(),
      ConsentModel.informed(),
      ConsentModel.dynamic(),
      ConsentModel.implied(),
      // Add more models here
    ];
  }
}