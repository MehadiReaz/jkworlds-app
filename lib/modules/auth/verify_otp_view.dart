import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';


class VerifyOtpView extends GetView<AuthController> {
  const VerifyOtpView({super.key});

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
                    key: controller.verifyOtpFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Title ─────────────────────────────────
                        Text(
                          'Verification',
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
                          'Enter the OTP code sent to: ${controller.emailCtrl.text}',
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 36),

                        // ── OTP Input Label ──────────────────────────────
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
                        // ── OTP TextFormField ────────────────────────────
                        TextFormField(
                          controller: controller.otpCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: controller.validateOtp,
                          decoration: buildAuthInputDecoration(
                            hintText: 'Enter OTP code',
                            cs: cs,
                            theme: theme,
                            prefixIcon: Icon(
                              Icons.pin_outlined,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Verify Button ────────────────────────────────
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.verifyOtp,
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
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── OTP Resend Option ────────────────────────────
                        Obx(() {
                          final seconds = controller.otpTimerSeconds.value;
                          return Center(
                            child: seconds > 0
                                ? RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      children: [
                                        const TextSpan(text: "Didn't receive code? "),
                                        TextSpan(
                                          text: 'Resend in ${seconds}s',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : TextButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.resendOtp,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // ── Back to Forgot Password ──────────────────────
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
                                'Change Email',
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
