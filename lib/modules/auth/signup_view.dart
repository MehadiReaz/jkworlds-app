import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/shared_auth_widgets.dart';
import 'package:jkworlds/core/constants/image_assets.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

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
                const SizedBox(height: 24),
                // ── Signup Card Container ─────────────────────────
                AuthCard(
                  child: Form(
                    key: controller.signupFormKey,
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
                          'create_account'.tr,
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
                          'signup_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 32),

                        // ── Full Name Input Label ────────────────────────
                        Text(
                          'full_name_label'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Full Name TextFormField ──────────────────────
                        TextFormField(
                          controller: controller.nameCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: controller.validateName,
                          decoration: buildAuthInputDecoration(
                            hintText: 'enter_name'.tr,
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(height: 20),

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
                            obscureText: controller.obscureSignupPassword.value,
                            textInputAction: TextInputAction.next,
                            validator: controller.validatePassword,
                            decoration: buildAuthInputDecoration(
                              hintText: 'enter_password'.tr,
                              cs: cs,
                              theme: theme,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureSignupPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.obscureSignupPassword.toggle(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Confirm Password Input Label ─────────────────
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
                        // ── Confirm Password TextFormField ───────────────
                        Obx(
                          () => TextFormField(
                            controller: controller.confirmPasswordCtrl,
                            obscureText:
                                controller.obscureSignupConfirmPassword.value,
                            textInputAction: TextInputAction.done,
                            validator: controller.validateConfirmPassword,
                            decoration: buildAuthInputDecoration(
                              hintText: 'confirm_your_password'.tr,
                              cs: cs,
                              theme: theme,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureSignupConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.obscureSignupConfirmPassword.toggle(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Signup Submit Button ─────────────────────────
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.signup,
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
                                    'signup'.tr,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Already have an account? Log In ──────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "already_have_account".tr + " ",
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.goToLogin,
                              child: Text(
                                'login'.tr,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
