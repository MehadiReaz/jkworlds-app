import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthCard(
                  child: Form(
                    key: controller.resetPasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Title ─────────────────────────────────
                        Text(
                          'reset_password'.tr,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the OTP sent to your email and your new password.',
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 36),

                        // ── Email Input (Read-only) ──────────────────────
                        Text(
                          'email'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.emailCtrl,
                          readOnly: true,
                          decoration: buildAuthInputDecoration(
                            hintText: 'email'.tr,
                            cs: cs,
                            theme: theme,
                          ).copyWith(
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            prefixIcon: Icon(Icons.email_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── OTP Code Input ──────────────────────────────
                        Text(
                          'OTP CODE *',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.otpCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: controller.validateOtp,
                          decoration: buildAuthInputDecoration(
                            hintText: 'Enter OTP code',
                            cs: cs,
                            theme: theme,
                            prefixIcon: Icon(Icons.pin_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── New Password Input ───────────────────────────
                        Text(
                          'NEW PASSWORD *',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordCtrl,
                            obscureText: controller.obscurePassword.value,
                            textInputAction: TextInputAction.next,
                            validator: controller.validatePassword,
                            decoration: buildAuthInputDecoration(
                              hintText: 'enter_password'.tr,
                              cs: cs,
                              theme: theme,
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.obscurePassword.toggle(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Confirm New Password Input ───────────────────
                        Text(
                          'confirm_password_label'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: controller.confirmPasswordCtrl,
                            obscureText: controller.obscureConfirmPassword.value,
                            textInputAction: TextInputAction.done,
                            validator: controller.validateConfirmPassword,
                            decoration: buildAuthInputDecoration(
                              hintText: 'confirm_your_password'.tr,
                              cs: cs,
                              theme: theme,
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.obscureConfirmPassword.toggle(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit Button ────────────────────────────────
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.resetPassword,
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              disabledBackgroundColor: cs.primary.withValues(
                                alpha: 0.6,
                              ),
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
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
                                    'reset_password'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Back to Log In ───────────────────────────────
                        GestureDetector(
                          onTap: () => Get.offAllNamed(AppRoutes.login),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chevron_left_rounded,
                                color: cs.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'back_to_log_in'.tr,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
