import 'package:get/get.dart';
import 'onboarding_wizard_controller.dart';

class OnboardingWizardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingWizardController>(() => OnboardingWizardController());
  }
}
