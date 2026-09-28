// // enum OnboardingStep {
// //   welcome,
// //   askLanguage,
// //   confirmHindi,
// //   languageSet,
// //   askName,
// //   confirmName,
// //   completed,
// // }

// // class OnboardingFlow {
// //   OnboardingStep currentStep = OnboardingStep.welcome;

// //   String? selectedLanguage;
// //   String? userName;

// //   void setLanguage(String language) {
// //     selectedLanguage = language;
// //   }

// //   void setName(String name) {
// //     userName = name;
// //   }

// //   void moveTo(OnboardingStep step) {
// //     currentStep = step;
// //   }

// //   void nextStep() {
// //     switch (currentStep) {
// //       case OnboardingStep.welcome:
// //         currentStep = OnboardingStep.askLanguage;
// //         break;

// //       case OnboardingStep.askLanguage:
// //         if (selectedLanguage?.toLowerCase().contains('hindi') == true) {
// //           currentStep = OnboardingStep.confirmHindi;
// //         } else {
// //           currentStep = OnboardingStep.languageSet;
// //         }
// //         break;

// //       case OnboardingStep.confirmHindi:
// //         currentStep = OnboardingStep.languageSet;
// //         break;

// //       case OnboardingStep.languageSet:
// //         currentStep = OnboardingStep.askName;
// //         break;

// //       case OnboardingStep.askName:
// //         currentStep = OnboardingStep.confirmName;
// //         break;

// //       case OnboardingStep.confirmName:
// //         currentStep = OnboardingStep.completed;
// //         break;

// //       case OnboardingStep.completed:
// //         break;
// //     }
// //   }
// // }
// enum OnboardingStep {
//   welcome,
//   askLanguage,
//   confirmHindi,
//   languageSet,
//   askName,
//   confirmName,
//   completed,
// }

// class OnboardingFlow {
//   OnboardingStep currentStep = OnboardingStep.welcome;

//   String? selectedLanguage;
//   String? userName;

//   void setLanguage(String language) {
//     selectedLanguage = language;
//   }

//   void setName(String name) {
//     userName = name;
//   }

//   void moveTo(OnboardingStep step) {
//     currentStep = step;
//   }
// }

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