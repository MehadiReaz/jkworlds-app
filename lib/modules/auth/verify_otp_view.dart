import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';

class VerifyOtpView extends GetView<AuthController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: .6),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: cs.primary,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(14),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: cs.primary.withValues(alpha: .08),
      border: Border.all(
        color: cs.primary.withValues(alpha: .4),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: AuthCard(
                child: Form(
                  key: controller.verifyOtpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Verification Icon
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withValues(alpha: .10),
                          ),
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 42,
                            color: cs.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Title
                      Text(
                        'Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Subtitle
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'We sent a verification code to\n',
                            ),
                            TextSpan(
                              text: controller.emailCtrl.text,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      /// OTP Label
                      Text(
                        'ENTER 6-DIGIT CODE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// OTP Input
                      Center(
                        child: Pinput(
                          controller: controller.otpCtrl,
                          length: 6,
                          keyboardType: TextInputType.number,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          validator: controller.validateOtp,
                          onCompleted: (_) {
                            if (!controller.isLoading.value) {
                              controller.verifyOtp();
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Verify Button
                      Obx(
                        () => FilledButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.verifyOtp,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Resend Section
                      Obx(() {
                        final seconds =
                            controller.otpTimerSeconds.value;

                        return Column(
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            seconds > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: .08),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Resend available in ${seconds}s',
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    onPressed:
                                        controller.isLoading.value
                                            ? null
                                            : controller.resendOtp,
                                    child: const Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      }),

                      const SizedBox(height: 28),

                      /// Change Email
                      Center(
                        child: TextButton.icon(
                          onPressed: Get.back,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: cs.primary,
                          ),
                          label: Text(
                            'Change Email',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}