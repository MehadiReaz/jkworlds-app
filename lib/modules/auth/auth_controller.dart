import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import '../../core/utils/logger.dart';

/// Controller shared by Login, Signup, Forgot Password, and Reset Password views.
class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ── Form Controllers ──────────────────────────────────────────
  final nameCtrl            = TextEditingController();
  final emailCtrl           = TextEditingController();
  final passwordCtrl        = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final otpCtrl             = TextEditingController();

  // ── Form Keys ─────────────────────────────────────────────────
  final loginFormKey         = GlobalKey<FormState>();
  final signupFormKey        = GlobalKey<FormState>();
  final forgotFormKey        = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────
  final isLoading              = false.obs;
  final obscurePassword        = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }

  // ── Validators ────────────────────────────────────────────────

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
    if (!GetUtils.isEmail(v.trim())) return 'invalid_email'.tr;
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr;
    if (v.length < 6) return 'password_too_short'.tr;
    return null;
  }

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr;
    if (v != passwordCtrl.text) return 'passwords_dont_match'.tr;
    return null;
  }

  String? validateOtp(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
    if (v.trim().length < 4) return 'OTP must be at least 4 digits';
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.login(emailCtrl.text.trim(), passwordCtrl.text);
      _clearFields();
      _navigateAfterSuccess();
      _showSuccess('login_success'.tr);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.signup(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passwordCtrl.text,
        confirmPasswordCtrl.text,
      );
      _clearFields();
      _navigateAfterSuccess();
      _showSuccess('signup_success'.tr);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
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
      _showSuccess('forgot_password_title'.tr, message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.resetPassword(
        email:                emailCtrl.text.trim(),
        otp:                  otpCtrl.text.trim(),
        password:             passwordCtrl.text,
        passwordConfirmation: confirmPasswordCtrl.text,
      );
      _clearFields();
      Get.offAllNamed(AppRoutes.login);
      _showSuccess('success'.tr, 'Password reset successfully!');
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Social Auth ───────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final success = await _auth.signInWithGoogle();
    if (success) {
      _clearFields();
      _navigateAfterSuccess();
      _showSuccess('login_success'.tr);
    }
  }

  Future<void> signInWithApple() async {
    final success = await _auth.signInWithApple();
    if (success) {
      _clearFields();
      _navigateAfterSuccess();
      _showSuccess('login_success'.tr);
    }
  }

  // ── Navigation ────────────────────────────────────────────────

  void goToSignup()         { _clearFields(); Get.offNamed(AppRoutes.signup); }
  void goToLogin()          { _clearFields(); Get.offNamed(AppRoutes.login); }
  void goToForgotPassword() { _clearFields(); Get.toNamed(AppRoutes.forgotPassword); }
  void continueAsGuest()    { _clearFields(); _navigateAfterSuccess(); }

  void _navigateAfterSuccess() {
    const authRoutes = {
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    };

    logger.f(_auth.isLoggedIn.value.toString());

    final prev = Get.previousRoute;
    if (prev.isNotEmpty && !authRoutes.contains(prev)) {
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
        return;
      }
    }
    Get.offAllNamed(AppRoutes.main);
  }

  // ── Helpers ───────────────────────────────────────────────────

  void _clearFields() {
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    otpCtrl.clear();
  }

  void _showSuccess(String title, [String message = '']) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar(
        title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }

  void _showError(String message) {
    Get.snackbar(
      'error'.tr, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}