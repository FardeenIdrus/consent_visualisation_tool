import 'consent_models.dart';

class CompareScreenModel {
  final List<ConsentModel> consentModels = ConsentModelList.getAvailableModels();
  
  String getInitialConsentProcess(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return 'Comprehensive risk disclosure and explicit acknowledgment';
      case 'Affirmative Consent':
        return 'Builds on Informed Consent (risk disclosures) by adding mutual confirmation requirement';
      case 'Dynamic Consent':
        return 'Simple explicit agreement with periodic review';
      case 'Granular Consent':
        return 'Detailed permission configuration before sharing';
      case 'Implied Consent':
        return 'No explicit confirmation required';
      default:
        return 'Not specified';
    }
  }

  String getControlMechanisms(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return 'Risk warnings only';
      case 'Affirmative Consent':
        return 'Risk warnings and dual-party confirmation';
      case 'Dynamic Consent':
        return 'Revocation controls and reassessment prompts';
      case 'Granular Consent':
        return 'Time limits and granular access restrictions';
      case 'Implied Consent':
        return 'No technical restrictions';
      default:
        return 'Not specified';
    }
  }

  String getConsentModification(ConsentModel model) {
    switch (model.name) {
      case 'Informed Consent':
        return 'No modification after initial consent';
      case 'Affirmative Consent':
        return 'No modification after mutual confirmation';
      case 'Dynamic Consent':
        return 'Can revoke access and schedule reassessment';
      case 'Granular Consent':
        return 'Adjustable access settings and expiration';
      case 'Implied Consent':
        return 'No post-sharing control';
      default:
        return 'Not specified';
    }
  }
}