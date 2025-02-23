// lib/model/compare_model.dart

import 'consent_models.dart';

// Model for the compare screen, containing information about consent models.
class CompareScreenModel {
  // List of available consent models.
  final List<ConsentModel> consentModels = ConsentModelList.getAvailableModels();
  
  // Returns a map describing the initial consent process for a given model.
  Map<String, dynamic> getInitialConsentProcess(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return {
          'main': <String>[
            'The sender is presented with a risk disclosure panel highlighting five key areas:',
          ],
           'risk_disclosure': <String>[
      'Digital Permanence: Once shared, images can persist indefinitely in digital spaces, creating potential for future misuse.',
      'Distribution Risks: Once shared, images can be copied, saved, or redistributed without your discretion, even if initially shared within a consensual exchange.',
      'Control Limitations: After sharing, you will have limited ability to control how your images are stored, shared, or used by others.',
      'Future Impact: Shared images may have long-term consequences for personal relationships, professional opportunities, and overall wellbeing.',
      'Security Risks:  There is potential for third-party interception, unauthorized access, or data breaches of shared images.'
    ],
          'additional': <String>[
            'User must check acknowledgment boxes for each risk',
            'User cannot proceed without acknowledging all risks'
          ]
        };
case 'Affirmative Consent':
  return {
    'type': 'pathways',
    'pathway1': {
      'title': 'Sender-Initiated Sharing',
      'steps': <String>[
        'The sender is presented with the same risk disclosure as Informed Consent when they attempt to share an image',
        'User must check acknowledgment boxes for each risk',
        'User cannot proceed without acknowledging all risks',
        'Sender is prompted: "Do you enthusiastically agree to share this image?"',
        'Sender must explicitly confirm their willing participation',
        'Recipient must actively confirm their willingness to receive',
        'Clear decline option is provided at each step'
      ]
    },
    'pathway2': {
      'title': 'Recipient Requests Image',
      'steps': <String>[
        'Recipient initiates image request',
        'The sender is presented with the request',
        'If the sender accepts the request, they see the same risk disclosure as Informed Consent',
        'Sender must check acknowledgment boxes for each risk',
        'Sender is prompted: "Do you enthusiastically agree to share this image?"',
        'Only if the sender agrees, will the recipient receive the image',
        'Clear decline option is provided at each step'
      ]
    }
  };
case 'Dynamic Consent':
  return {
    'main': <String>[
      'At point of set up:',
      'The sender configures how often they want to review consent'
    ],
    'sub': <String>[
      'Set consent review frequency (hourly, daily, weekly)',
      'Configure notification preferences for review reminders',
    ],
    'additional': <String>[
      'System explains how ongoing consent management works',
      'Sender must understand the implications of their chosen review schedule'
    ]
  };
case 'Granular Consent':
  return {
    'main': <String>[
      'The sender is presented with a list of permissions settings:',
      'The sender must configure detailed permission settings',
      'The sender must specify sharing conditions before proceeding'
    ],
    'sub': <String>[
      'Time limits for content access',
      'Recipients permission levels',
      'Sharing restriction preferences',
      'Screenshot permissions',
    ],
    'additional': <String>[
      'Sender is shown explanation for each permission setting',
      'All settings must be configured before sharing'
    ]
  };
case 'Implied Consent':
  return {
    'main': <String>[
      'At point of set up:',
      'No explicit consent mechanism',
      'Consent is assumed through user actions'
    ],
    'sub': <String>[
      'No risk disclosure provided',
      'No explicit confirmation required',
      'No consent configuration needed',
      'Standard sharing interface only'
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
      'Sharing is permitted once sender acknowledges all risks',
      'No technical controls are available to the sender to protect their content'
    ],
    'sub': <String>[
      'Cannot set time limits for content access',
      'Cannot prevent recipients from saving content',
      'Cannot restrict recipients from sharing content',
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
      'Sharing occurs with configured review schedule',
      'No immediate technical restrictions available'
    ],
    'sub': <String>[
      'Cannot prevent recipients from saving content',
      'Cannot restrict recipients from sharing content'
    ],
    'additional': <String>[
      'Protection relies on ongoing review of consent rather than technical restrictions'
    ]
  };
      case 'Granular Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'Technical controls enforce configured permission settings',
      'Protection mechanisms are applied to content'
    ],
    'sub': <String>[
      'Time limits are set on content access',
      'Saving permissions are enforced',
      'Sharing restrictions are implemented',
      'Screenshot permissions are applied',
    ],
    'additional': <String>[
      'All configured protection mechanisms are automatically applied'
    ]
  };
case 'Implied Consent':
  return {
    'main': <String>[
      'At the point of sharing:',
      'No consent verification required',
      'No technical controls available'
    ],
    'sub': <String>[
      'Cannot set time limits for content access',
      'Cannot prevent recipients from saving content',
      'Cannot restrict recipients from sharing content'
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
      'No ability to modify initial sharing conditions',
      'No way to control shared content'
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
      'Once content is shared, sender loses technical control despite initial mutual agreement'
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
      'Can revoke access during any review',
      'Can modify review frequency',
      'Can delete shared content at any time',
      'Receives notifications for scheduled reviews'
    ],
    'additional': <String>[
      'Continuous control through scheduled reassessment',
    ]
  };
   case 'Granular Consent':
  return {
    'main': <String>[
      'After sharing:',
      'The sender can modify sharing conditions',
      'The sender retains control through technical restrictions'
    ],
    'sub': <String>[
      'Can adjust time limits',
      'Can modify access permissions',
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
      'No ability to modify conditions',
      'No control over shared content'
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
