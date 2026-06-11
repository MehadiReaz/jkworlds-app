import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

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
                // ── Card Container ─────────────────────────
                AuthCard(
                  child: Form(
                    key: controller.forgotFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Title ─────────────────────────────────
                        Text(
                          'forgot_password_title'.tr,
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
                          'forgot_password_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 36),

                        // ── Email Input Label ────────────────────────────
                        Text(
                          'email_address_label'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Email TextFormField ──────────────────────────
                        TextFormField(
                          controller: controller.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: controller.validateEmail,
                          decoration: buildAuthInputDecoration(
                            hintText: 'enter_email'.tr,
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit Button ────────────────────────────────
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.forgotPassword,
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
                                    'send_password_reset_link'.tr,
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
                          onTap: () => Get.back(),
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
