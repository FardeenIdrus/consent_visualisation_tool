// lib/model/compare_model.dart

import 'consent_models.dart';

// Model for the compare screen, containing information about consent models.
class CompareScreenModel {
  // List of available consent models.
  final List<ConsentModel> consentModels = ConsentModelList.getAvailableModels();
  
  // Returns a map describing the initial consent process for a given model.
// Updated getInitialConsentProcess for Informed Consent and Affirmative Consent
// in compare_model.dart

Map<String, dynamic> getInitialConsentProcess(ConsentModel model) {
  switch (model.name) {
case 'Informed Consent':
  return {
    'main': <String>[
      'Before sharing an Image:',
      'The sender is presented with a list of potential risks surrounding the sharing of intimate images digitally',
      'The sender must actively acknowledge understanding of each risk'
    ],
    'sub': <String>[
      'The risks presented include:',
      'Digital permanence risks',
      'Distribution risks',
      'Control limitation risks',
      'Future impact risks',
      'Security risks'
    ],
    'additional': <String>[
      'Each risk requires explicit acknowledgment from the sender',
      'Sender must check acknowledgment boxes for each risk',
      'Consent is specific to each instance of image sharing',
    ]
  };

case 'Affirmative Consent':
  return {
  'main': <String>[
  'Before sharing an image:',
  'The sender is presented with a list of potential risks surrounding digital intimate image sharing',
  'Both sender and recipient must actively confirm their participation'
],
'sub': <String>[
  'The sender must check acknowledgment boxes for each risk',
  'The sender must explicitly confirm their willingness to share',
  'The recipient must actively confirm their willingness to receive',
  'Clear options to decline are provided at each step for both parties'
],
'additional': <String>[
  'Dual-party confirmation is mandatory',
  'Image sharing only occurs when both parties agree',
  'Consent is specific to each instance of image sharing',
]
  };
case 'Dynamic Consent':
  return {
    'main': <String>[
      'Before sharing an image:',
      'The sender is provided an option to configure how often they want to review consent'
    ],
    'sub': <String>[
      'The sender then sets consent review frequency (hourly, daily, weekly)',
      'Configure notification preferences for review reminders',
    ],
    'additional': <String>[
      'The system explains the ongoing consent management process and review options'
    ]
  };
    case 'Granular Consent':
      // Existing implementation remains unchanged
      return {
        'main': <String>[
          'Before sharing an image:',
          'The sender is presented with a list of permissions settings',
          'The sender must configure detailed permission settings',
        ],
        'sub': <String>[
          'Define content viewing duration',
          'Configure saving restrictions',
          'Configure sharing restrictions',
        ],
        'additional': <String>[
          'Each permission setting requires explicit configuration',
          'All settings must be configured before sharing'
        ]
      };
    case 'Implied Consent':
      // Existing implementation remains unchanged
      return {
        'main': <String>[
          'Before sharing an image:',
          'No explicit consent mechanism is presented to the sender',
          'Consent is assumed through user actions'
        ],
        'sub': <String>[
          'No risk disclosure information is provided to the sender',
          'No explicit confirmation required',
          'No consent configuration options are presented to the sender',
        ],
        'additional': <String>[
          'Relies purely on assumption of consent through behavior',
          'No safeguards or confirmations in place'
        ]
      };
  }
  return {'main': <String>[], 'sub': <String>[]};
}

  // Returns a map describing the control mechanisms for a given model.
  Map<String, List<String>> getControlMechanisms(ConsentModel model) {
    switch (model.name) {
case 'Informed Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'The sender is only allowed to share once they acknowledge all risks',
      'No technical controls are available to the sender to protect their content'
    ],
    'sub': <String>[
      'The sender cannot set time limits for content access',
      'The sender cannot prevent recipients from saving content',
      'The sender cannot restrict recipients from sharing content'
    ],
    'additional': <String>[
      'Protection relies on senders understanding of the risks'
    ]
  };
case 'Affirmative Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'Sharing requires mutual confirmation from both parties',
      'No technical controls are available'
    ],
    'sub': <String>[
      'The sender cannot set time limits for content access',
      'The sender cannot prevent recipients from saving content',
      'The sender cannot restrict recipients from sharing content'
    ],
    'additional': <String>[
      'Protection relies on explicit agreement rather than technical restrictions'
    ]
  };
case 'Dynamic Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
       'The sender shares content with a configured review schedule',
        'The sender has no immediate technical restrictions'
    ],
    'sub': <String>[
            'The sender cannot prevent recipients from saving content',
            'The sender cannot restrict recipients from sharing content'
    ],
    'additional': <String>[
      'Protection relies on ongoing review of consent rather than technical restrictions'
    ]
  };
      case 'Granular Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'System enforces configured permission settings',
      'Protection mechanisms are applied to content'
    ],
    'sub': <String>[
      'Time limits are set on content access',
      'Saving permissions are enforced',
      'Sharing restrictions are implemented',
    ],
    'additional': <String>[
      'All configured protection mechanisms are applied'
    ]
  };
case 'Implied Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'No consent verification is presented to the sender',
      'No technical controls are available to the sender'
    ],
    'sub': <String>[
      'The sender cannot set time limits for content access',
      'The sender cannot prevent recipients from saving content',
      'The sender cannot restrict recipients from sharing content'
    ],
    'additional': <String>[
      'No protection mechanisms are available'
    ]
  };
    }
    return {'main': <String>[], 'sub': <String>[]};
  }

  // Returns a map describing the consent modification capabilities for a given model.
  Map<String, List<String>> getConsentModification(ConsentModel model) {
    switch (model.name) {
case 'Informed Consent':
  return {
    'main': <String>[
      'After sharing:',
      'The sender has no ability to modify initial sharing conditions',
      'The sender has no way to control shared content'
    ],
    'sub': <String>[
      'The sender has no ability to withdraw shared content',
      'The sender has no ability to change access permissions',
      'The sender has no ability to track how content is being used'
    ],
    'additional': <String>[
      'Once content is shared, sender loses technical control'
    ]
  };
  case 'Affirmative Consent':
  return {
    'main': <String>[
      'After sharing:',
      'No ability to modify initial sharing conditions',
      'No way to control shared content'
    ],
    'sub': <String>[
      'The sender has no ability to withdraw shared content',
      'The sender has no ability to change access permissions',
      'The sender has no ability to track how content is being used'
    ],
    'additional': <String>[
      'Once content is shared, sender loses technical control over shared content'
    ]
  };
case 'Dynamic Consent':
  return {
    'main': <String>[
      'After sharing:',
      'Regular consent reassessment occurs based on schedule',
      'Sender maintains ongoing control through review process'
    ],
    'sub': <String>[
      'Can delete shared content at any time',
      'Can revoke access during any review',
      'Can modify review frequency',
      'Receives notifications for scheduled reviews'
    ],
    'additional': <String>[
      'The sender has continuous control through scheduled reassessment and the ability to revoke access to shared content at any time',
    ]
  };
   case 'Granular Consent':
  return {
    'main': <String>[
      'After sharing:',
      'The sender retains ability to modify controls',
      'Technical restrictions remain enforceable'
    ],
    'sub': <String>[
      'Can adjust viewing time limits',
      'Can modify saving permissions',
      'Can update sharing restrictions',
    ],
    'additional': <String>[
      'Changes to settings take effect immediately'
    ]
  };
case 'Implied Consent':
  return {
    'main': <String>[
      'After sharing:',
      'The sender has no ability to modify conditions',
      'The sender has no control over shared content'
    ],
    'sub': <String>[
      'Cannot withdraw shared content',
      'Cannot change access permissions',
      'Cannot track how content is being used'
    ],
    'additional': <String>[
      'Complete loss of control once content is shared'
    ]
  };
    }
    return {'main': <String>[], 'sub': <String>[]};
  }
}
