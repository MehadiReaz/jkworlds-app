import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'package:jkworlds/data/services/auth_service.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ── Branding ──────────────────────────────────────
                _buildHeader(cs),
                const SizedBox(height: 48),

                // ── Title ─────────────────────────────────────────
                Text(
                  'signup'.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'signup_prompt'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Name ──────────────────────────────────────────
                TextFormField(
                  controller: controller.nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: controller.validateName,
                  decoration: _inputDecoration(
                    label: 'name'.tr,
                    icon: Icons.person_outline,
                    cs: cs,
                  ),
                ),
                const SizedBox(height: 16),

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
                    textInputAction: TextInputAction.next,
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
                const SizedBox(height: 16),

                // ── Confirm Password ──────────────────────────────
                Obx(
                  () => TextFormField(
                    controller: controller.confirmPasswordCtrl,
                    obscureText: controller.obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    validator: controller.validateConfirmPassword,
                    decoration: _inputDecoration(
                      label: 'confirm_password'.tr,
                      icon: Icons.lock_outline,
                      cs: cs,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            controller.obscureConfirmPassword.toggle(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Signup Button ─────────────────────────────────
                Obx(
                  () => FilledButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.signup,
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
                            'signup'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

                // ── Login Link ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_account'.tr,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: controller.goToLogin,
                      child: Text(
                        'login'.tr,
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
  Widget _buildHeader(ColorScheme cs) {
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
