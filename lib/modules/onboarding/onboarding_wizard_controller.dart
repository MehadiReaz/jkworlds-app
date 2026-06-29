import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class OnboardingWizardController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final currentStep = 0.obs;
  final isLoading = false.obs;

  // Step 1: Persona selection
  final preferredService = 'traveler'.obs; // traveler, business, chauffeur

  // Step 2: Location & Contact details
  final cityCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final countryCodeCtrl = TextEditingController(text: '+234'); // Default country code NGN
  final dobRx = Rxn<DateTime>();

  // Step 3: Preferred Currency
  final preferredCurrency = 'USD'.obs; // USD, EUR, GBP, NGN

  @override
  void onInit() {
    super.onInit();
    // Pre-populate if user has partial data from oauth
    final user = _auth.currentUser.value;
    if (user != null) {
      if (user.city != null && user.city!.isNotEmpty) cityCtrl.text = user.city!;
      if (user.country != null && user.country!.isNotEmpty) countryCtrl.text = user.country!;
      if (user.phone != null && user.phone!.isNotEmpty) phoneCtrl.text = user.phone!;
      if (user.countryCode != null && user.countryCode!.isNotEmpty) countryCodeCtrl.text = user.countryCode!;
      if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
        try {
          dobRx.value = DateTime.parse(user.dateOfBirth!);
        } catch (_) {}
      }
    }
  }

  String get dobFormatted => dobRx.value != null
      ? DateFormat('yyyy-MM-dd').format(dobRx.value!)
      : '';

  void setService(String service) {
    preferredService.value = service;
  }

  void setCurrency(String currency) {
    preferredCurrency.value = currency;
  }

  void pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 18); // Must be at least 18
    final initialDate = dobRx.value ?? DateTime(now.year - 25);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      dobRx.value = selected;
    }
  }

  bool validateCurrentStep() {
    if (currentStep.value == 0) {
      // Step 1: persona always validated (pre-selected)
      return true;
    } else if (currentStep.value == 1) {
      // Step 2: Location and contact validation
      if (cityCtrl.text.trim().isEmpty) {
        SnackbarHelper.showError('Please enter your current city.');
        return false;
      }
      if (countryCtrl.text.trim().isEmpty) {
        SnackbarHelper.showError('Please enter your country.');
        return false;
      }
      if (countryCodeCtrl.text.trim().isEmpty) {
        SnackbarHelper.showError('Please enter your country code extension.');
        return false;
      }
      if (phoneCtrl.text.trim().isEmpty) {
        SnackbarHelper.showError('Please enter your mobile phone number.');
        return false;
      }
      if (dobRx.value == null) {
        SnackbarHelper.showError('Please select your Date of Birth.');
        return false;
      }
      return true;
    }
    // Step 3: currency validated (pre-selected)
    return true;
  }

  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < 2) {
        currentStep.value++;
      } else {
        submitPreferences();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> submitPreferences() async {
    isLoading.value = true;
    try {
      await _auth.updateOnboardingPreferences(
        preferredCurrency: preferredCurrency.value,
        preferredService: preferredService.value,
        city: cityCtrl.text.trim(),
        country: countryCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        countryCode: countryCodeCtrl.text.trim(),
        dateOfBirth: dobFormatted,
      );

      SnackbarHelper.showSuccess('Onboarding completed successfully!');
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      logger.e('[OnboardingWizardController] Submit error: $e');
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cityCtrl.dispose();
    countryCtrl.dispose();
    phoneCtrl.dispose();
    countryCodeCtrl.dispose();
    super.onClose();
  }
}
