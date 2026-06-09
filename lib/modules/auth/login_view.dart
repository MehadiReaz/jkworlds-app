import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'package:jkworlds/data/services/auth_service.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ── Branding ──────────────────────────────────────
                _buildHeader(theme, cs),
                const SizedBox(height: 48),

                // ── Title ─────────────────────────────────────────
                Text(
                  'login'.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'login_prompt'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Email ─────────────────────────────────────────
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateEmail,
                  decoration: _inputDecoration(
                    label: 'email'.tr,
                    icon: Icons.email_outlined,
                    cs: cs,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────
                Obx(
                  () => TextFormField(
                    controller: controller.passwordCtrl,
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    validator: controller.validatePassword,
                    decoration: _inputDecoration(
                      label: 'password'.tr,
                      icon: Icons.lock_outline,
                      cs: cs,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => controller.obscurePassword.toggle(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Forgot Password ───────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.goToForgotPassword,
                    child: Text(
                      'forgot_password'.tr,
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Login Button ──────────────────────────────────
                Obx(
                  () => FilledButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.login,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            'login'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Continue as Guest ─────────────────────────────
                OutlinedButton(
                  onPressed: controller.continueAsGuest,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: cs.outline),
                  ),
                  child: Text(
                    'continue_as_guest'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── OR Divider ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: cs.outlineVariant),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or_divider'.tr,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: cs.outlineVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Google Sign-In ────────────────────────────────
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                    icon: Get.find<AuthService>().isSocialLoading.value
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          )
                        : Icon(
                            Icons.g_mobiledata_rounded,
                            size: 28,
                            color: cs.primary,
                          ),
                    label: Text(
                      'continue_with_google'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: cs.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Sign Up Link ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont_have_account'.tr,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: controller.goToSignup,
                      child: Text(
                        'signup'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header with gradient icon ─────────────────────────────────
  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.storefront_rounded,
          size: 44,
          color: cs.onPrimary,
        ),
      ),
    );
  }

  // ── Reusable input decoration ─────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required ColorScheme cs,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
    );
  }
}
