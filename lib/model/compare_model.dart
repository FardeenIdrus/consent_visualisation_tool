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
           'sub': <String>[
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
              'Sender confirms intent to share image',
              'Recipient must actively click "Accept" to proceed',
              'Clear "Decline" option is provided'
            ]
          },
          'pathway2': {
            'title': 'Recipient Requests Image',
            'steps': <String>[
              'Recipient requests to receive image',
              'Sender must explicitly agree to share',
              'Clear "Decline" option is provided'
            ]
          }
        };
      case 'Dynamic Consent':
        return {
          'main': <String>[
            'The sender is presented with a review frequency setup screen',
            'The sender must select their preferred review schedule',
            'The sender sets up notification preferences for consent reviews'
          ],
          'sub': <String>[]
        };
      case 'Granular Consent':
        return {
          'main': <String>[
            'The sender is presented with a sharing configuration panel',
            'The sender must set specific parameters before sharing:'
          ],
          'sub': <String>[
            'Content viewing duration',
            'Saving permissions',
            'Sharing restrictions'
          ],
          'additional': <String>[
            'The sender can customise each control setting'
          ]
        };
      case 'Implied Consent':
        return {
          'main': <String>[
            'The sender is presented with a standard sharing interface only',
            'No additional consent prompts or configurations'
          ],
          'sub': <String>[]
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
      'Sharing is permitted once risks are acknowledged',
      'No technical controls are available to the sender to protect their content'
    ],
    'sub': <String>[
      'Cannot set time limits for content access',
      'Cannot prevent recipients from saving content',
      'Cannot restrict recipients from sharing content'
    ],
  };
      case 'Affirmative Consent':
        return {
          'main': <String>[
            'The sender cannot set specific control restrictions (such as preventing saving, sharing, and time-limited view)'
          ],
          'sub': <String>[]
        };
      case 'Dynamic Consent':
        return {
          'main': <String>[
            'The sender cannot set specific control restrictions (such as preventing saving, sharing, and time-limited view), however, is presented with the option to set how often they would like to reassess consent of their shared content'
          ],
          'sub': <String>[]
        };
      case 'Granular Consent':
        return {
          'main': <String>[
            'The sender can set explicit sharing permissions (Deletion of shared content after the set time has elapsed, and forwarding and saving restrictions can be set)'
          ],
          'sub': <String>[]
        };
      case 'Implied Consent':
        return {
          'main': <String>[
            'No technical restrictions or content protection mechanisms'
          ],
          'sub': <String>[]
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
          'main': <String>['No mechanism for modifying initial consent'],
          'sub': <String>[]
        };
      case 'Dynamic Consent':
        return {
          'main': <String>[
            'The user is provided with ongoing consent management with periodic reassessment and immediate revocation of shared content'
          ],
          'sub': <String>[]
        };
      case 'Granular Consent':
        return {
          'main': <String>[
            'Flexible modification of sharing conditions, including adjusting access settings and content expiration'
          ],
          'sub': <String>[]
        };
      case 'Implied Consent':
        return {
          'main': <String>['No mechanism for modifying initial consent'],
          'sub': <String>[]
        };
    }
    return {'main': <String>[], 'sub': <String>[]};
  }
}
