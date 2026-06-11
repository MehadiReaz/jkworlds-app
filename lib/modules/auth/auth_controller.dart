import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

/// Controller shared by Login, Signup, and Forgot Password views.
class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ── Form Controllers ──────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ── Form Keys ─────────────────────────────────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();

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

  // ── Actions ───────────────────────────────────────────────────

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    final success = await _auth.login(emailCtrl.text.trim(), passwordCtrl.text);
    isLoading.value = false;

    if (success) {
      _clearFields();
      Get.snackbar(
        'login_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.back();
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    isLoading.value = true;
    final success = await _auth.signup(
      nameCtrl.text.trim(),
      emailCtrl.text.trim(),
      passwordCtrl.text,
    );
    isLoading.value = false;

    if (success) {
      _clearFields();
      Get.snackbar(
        'signup_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.back();
    }
  }

  Future<void> forgotPassword() async {
    if (!forgotFormKey.currentState!.validate()) return;

    isLoading.value = true;
    await _auth.forgotPassword(emailCtrl.text.trim());
    isLoading.value = false;

    _clearFields();
    Get.back();
  }

  // ── Social Auth ────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final success = await _auth.signInWithGoogle();
    if (success) {
      _clearFields();
      Get.snackbar(
        'login_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.back();
    }
  }

  Future<void> signInWithApple() async {
    final success = await _auth.signInWithApple();
    if (success) {
      _clearFields();
      Get.snackbar(
        'login_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.back();
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
    Get.back();
  }

  void _clearFields() {
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
  }
}
