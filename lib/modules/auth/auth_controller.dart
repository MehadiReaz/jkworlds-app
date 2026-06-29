import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
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
  final verifyOtpFormKey     = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────
  final isLoading                    = false.obs;
  final obscureLoginPassword         = true.obs;
  final obscureSignupPassword        = true.obs;
  final obscureSignupConfirmPassword = true.obs;
  final obscureResetPassword         = true.obs;
  final obscureResetConfirmPassword  = true.obs;

  // ── OTP Resend Timer ──────────────────────────────────────────
  Timer? _otpTimer;
  final otpTimerSeconds = 0.obs;

  void startOtpTimer() {
    _otpTimer?.cancel();
    otpTimerSeconds.value = 120;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimerSeconds.value > 0) {
        otpTimerSeconds.value--;
      } else {
        _otpTimer?.cancel();
      }
    });
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
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
    if (v.length < 8) return 'password_too_short'.tr;
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
    if (v.trim().length != 6) return 'OTP must be exactly 6 digits';
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
      startOtpTimer();
      Get.toNamed(AppRoutes.verifyOtp);
      _showSuccess('forgot_password_title'.tr, message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (emailCtrl.text.trim().isEmpty) {
      _showError('Email is required to resend OTP.');
      return;
    }

    isLoading.value = true;
    try {
      final message = await _auth.forgotPassword(emailCtrl.text.trim());
      startOtpTimer();
      _showSuccess('forgot_password_title'.tr, message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (!verifyOtpFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final message = await _auth.verifyOtp(
        email: emailCtrl.text.trim(),
        otp: otpCtrl.text.trim(),
      );
      _otpTimer?.cancel();
      otpTimerSeconds.value = 0;
      Get.toNamed(AppRoutes.resetPassword);
      _showSuccess('success'.tr, message);
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
        email:    emailCtrl.text.trim(),
        otp:      otpCtrl.text.trim(),
        password: passwordCtrl.text,
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
      AppRoutes.verifyOtp,
      AppRoutes.resetPassword,
    };

    logger.f(_auth.isLoggedIn.value.toString());

    if (_auth.currentUser.value?.onboardingCompleted == false) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

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
    obscureLoginPassword.value = true;
    obscureSignupPassword.value = true;
    obscureSignupConfirmPassword.value = true;
    obscureResetPassword.value = true;
    obscureResetConfirmPassword.value = true;
  }

  void _showSuccess(String title, [String message = '']) {
    Future.delayed(const Duration(milliseconds: 100), () {
      SnackbarHelper.showSuccess(message.isNotEmpty ? message : title);
    });
  }

  void _showError(String message) {
    SnackbarHelper.showError(message);
  }
}