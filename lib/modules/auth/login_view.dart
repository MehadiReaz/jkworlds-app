import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';
import 'package:jkworlds/core/constants/image_assets.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
                // ── Login Card Container ──────────────────────────
                AuthCard(
                  child: Form(
                    key: controller.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            height: 64,
                            child: Image.asset(
                              ImageAssets.logo,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text(
                          'WELCOME BACK',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 32),

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
                          textInputAction: TextInputAction.next,
                          validator: controller.validateEmail,
                          decoration: buildAuthInputDecoration(
                            hintText: 'enter_email'.tr,
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Password Input Label ─────────────────────────
                        Text(
                          'password_label'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Password TextFormField ───────────────────────
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordCtrl,
                            obscureText: controller.obscurePassword.value,
                            textInputAction: TextInputAction.done,
                            validator: controller.validatePassword,
                            decoration: buildAuthInputDecoration(
                              hintText: 'enter_password'.tr,
                              cs: cs,
                              theme: theme,
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
                        const SizedBox(height: 12),

                        // ── Forgot Password Link ─────────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: controller.goToForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Login Submit Button ──────────────────────────
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
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
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Don't have an account? Sign up ────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.goToSignup,
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Divider ──────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                                thickness: 1.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or_use'.tr,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Social Sign-In Section ───────────────────────
                        Obx(
                          () => SocialSignInSection(
                            isLoading: controller.isLoading.value,
                            onGooglePressed: controller.signInWithGoogle,
                            onApplePressed: controller.signInWithApple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Continue as Guest ─────────────────────────────
                const SizedBox(height: 24),
                TextButton(
                  onPressed: controller.continueAsGuest,
                  child: Text(
                    'continue_as_guest'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
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
