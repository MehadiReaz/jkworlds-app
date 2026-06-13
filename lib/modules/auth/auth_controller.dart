import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

import '../../core/utils/logger.dart';

/// Controller shared by Login, Signup, Forgot Password, and Reset Password views.
class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ── Form Controllers ──────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  // ── Form Keys ─────────────────────────────────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // ── Validators ────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'field_required'.tr;
    if (!GetUtils.isEmail(value.trim())) return 'invalid_email'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value.length < 6) return 'password_too_short'.tr;
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'field_required'.tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value != passwordCtrl.text) return 'passwords_dont_match'.tr;
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'field_required'.tr;
    if (value.trim().length < 4) return 'OTP must be at least 4 digits';
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final success = await _auth.login(
        emailCtrl.text.trim(),
        passwordCtrl.text,
      );
      if (success) {
        _clearFields();
        _navigateAfterSuccess();
        _showSuccessSnackbar('login_success'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final success = await _auth.signup(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passwordCtrl.text,
        confirmPasswordCtrl.text,
      );

      if (success) {
        _clearFields();
        _navigateAfterSuccess();
        _showSuccessSnackbar('signup_success'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (!forgotFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final message = await _auth.forgotPassword(emailCtrl.text.trim());
      Get.toNamed(AppRoutes.resetPassword);
      _showSuccessSnackbar('forgot_password_title'.tr, message);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final success = await _auth.resetPassword(
        email: emailCtrl.text.trim(),
        otp: otpCtrl.text.trim(),
        password: passwordCtrl.text,
        passwordConfirmation: confirmPasswordCtrl.text,
      );

      if (success) {
        _clearFields();
        Get.offAllNamed(AppRoutes.login);
        _showSuccessSnackbar('success'.tr, 'Password reset successfully!');
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Social Auth ────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final success = await _auth.signInWithGoogle();
    if (success) {
      _clearFields();
      _navigateAfterSuccess();
      _showSuccessSnackbar('login_success'.tr);
    }
  }

  Future<void> signInWithApple() async {
    final success = await _auth.signInWithApple();
    if (success) {
      _clearFields();
      _navigateAfterSuccess();
      _showSuccessSnackbar('login_success'.tr);
    }
  }

  // ── Navigation ────────────────────────────────────────────────

  void goToSignup() {
    _clearFields();
    Get.offNamed(AppRoutes.signup);
  }

  void goToLogin() {
    _clearFields();
    Get.offNamed(AppRoutes.login);
  }

  void goToForgotPassword() {
    _clearFields();
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void continueAsGuest() {
    _clearFields();
    _navigateAfterSuccess();
  }

  void _navigateAfterSuccess() {
    if (Get.previousRoute.isNotEmpty &&
        Get.previousRoute != AppRoutes.login &&
        Get.previousRoute != AppRoutes.signup &&
        Get.previousRoute != AppRoutes.forgotPassword &&
        Get.previousRoute != AppRoutes.resetPassword) {
      logger.f(_auth.isLoggedIn.value.toString());
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } else {
      logger.f(_auth.isLoggedIn.value.toString());
      Get.offAllNamed(AppRoutes.main);
    }
  }

  void _clearFields() {
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    otpCtrl.clear();
  }

  void _showSuccessSnackbar(String title, [String message = '']) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }
}
