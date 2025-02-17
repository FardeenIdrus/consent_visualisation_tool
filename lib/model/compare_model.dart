import 'consent_models.dart';

class CompareScreenModel {
  final List<ConsentModel> consentModels = ConsentModelList.getAvailableModels();
  
  String getInitialConsentProcess(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return 'The sender is presented with a comprehensive risk disclosure panel highlighting five key areas:\n'
               '* Digital Permanence\n'
               '* Distribution Risks\n'
               '* Control Limitations\n'
               '* Future Impact\n'
               '* Security Risks\n\n'
               'User must check acknowledgment boxes for each risk.\n'
               'User cannot proceed without acknowledging all risks.';

      case 'Affirmative Consent':
        return '* The sender is presented with a confirmation dialog to verify sharing intent.\n'
               '* Upon sender confirmation, recipient is presented with explicit acceptance request.\n'
               '* Both users must actively click "Accept" to proceed.\n'
               '* A clear "Decline" option is provided to both parties.';

      case 'Dynamic Consent':
        return '* The sender is presented with a review frequency setup screen.\n'
               '* The sender must select their preferred review schedule.\n'
               '* The sender sets up notification preferences for consent reviews.';

      case 'Granular Consent':
        return '* The sender is presented with a sharing configuration panel.\n'
               '* The sender must set specific parameters before sharing:\n'
               '* Content viewing duration\n'
               '* Saving permissions\n'
               '* Sharing restrictions\n'
               'The sender can customise each control setting.';

      case 'Implied Consent':
        return 'The sender is presented with a standard sharing interface only\n'
               'No additional consent prompts or configurations';

      default:
        return 'Not specified';
    }
  }

  String getControlMechanisms(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent': 
        return 'The sender cannot set specific control restrictions (such as preventing saving, sharing, and time-limited view).';

      case 'Affirmative Consent':
        return 'The sender cannot set specific control restrictions (such as preventing saving, sharing, and time-limited view).';

      case 'Dynamic Consent':
        return 'The sender cannot set specific control restrictions (such as preventing saving, sharing, and time-limited view), however, is presented with the option to set how often they would like to reassess consent of their shared content.';

      case 'Granular Consent':
        return 'The sender can set explicit sharing permissions (Deletion of shared content after the set time has elapsed, and forwarding and saving restrictions can be set).';

      case 'Implied Consent':
        return 'No technical restrictions or content protection mechanisms';

      default:
        return 'Not specified';
    }
  }

  String getConsentModification(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return 'No mechanism for modifying initial consent';

      case 'Affirmative Consent':
        return 'No mechanism for modifying initial consent';

      case 'Dynamic Consent':
        return 'The user is provided with ongoing consent management with periodic reassessment and immediate revocation of shared content.';

      case 'Granular Consent':
        return 'Flexible modification of sharing conditions, including adjusting access settings and content expiration.';

      case 'Implied Consent':
        return 'No mechanism for modifying initial consent';

      default:
        return 'Not specified';
    }
  }
}