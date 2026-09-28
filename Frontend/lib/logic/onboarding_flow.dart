enum OnboardingStep {
  welcome,
  askLanguage,
  confirmHindi,
  languageSet,
  askName,
  confirmName,
  completed,
}

class OnboardingFlow {
  OnboardingStep currentStep = OnboardingStep.welcome;

  String? selectedLanguage;
  String? userName;

  void setLanguage(String language) {
    selectedLanguage = language;
  }

  void setName(String name) {
    userName = name;
  }

  void moveTo(OnboardingStep step) {
    currentStep = step;
  }
}
