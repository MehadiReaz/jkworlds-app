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
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: AuthCard(
                child: Form(
                  key: controller.resetPasswordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      /// Icon
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withValues(alpha: .1),
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 42,
                            color: cs.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),


                      /// Title
                      Text(
                        'reset_password'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),


                      /// Description
                      Text(
                        'Create a strong new password for your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 36),



                      /// New password label
                      Text(
                        'NEW PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 8),


                      /// New password
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordCtrl,
                          obscureText:
                              controller.obscureResetPassword.value,
                          textInputAction:
                              TextInputAction.next,
                          validator:
                              controller.validatePassword,

                          decoration:
                              buildAuthInputDecoration(
                            hintText:
                                'enter_password'.tr,
                            cs: cs,
                            theme: theme,

                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: .5),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureResetPassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,

                                color: cs.onSurfaceVariant
                                    .withValues(alpha: .6),
                              ),

                              onPressed: () =>
                                  controller
                                      .obscureResetPassword
                                      .toggle(),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 20),



                      /// Confirm password label
                      Text(
                        'confirm_password_label'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: cs.onSurfaceVariant,
                        ),
                      ),


                      const SizedBox(height: 8),


                      /// Confirm password
                      Obx(
                        () => TextFormField(
                          controller:
                              controller.confirmPasswordCtrl,

                          obscureText:
                              controller
                                  .obscureResetConfirmPassword
                                  .value,

                          textInputAction:
                              TextInputAction.done,

                          validator:
                              controller
                                  .validateConfirmPassword,


                          decoration:
                              buildAuthInputDecoration(
                            hintText:
                                'confirm_your_password'.tr,

                            cs: cs,
                            theme: theme,

                            prefixIcon: Icon(
                              Icons.verified_user_outlined,
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: .5),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                controller
                                        .obscureResetConfirmPassword
                                        .value
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,

                                color: cs.onSurfaceVariant
                                    .withValues(alpha: .6),
                              ),

                              onPressed: () =>
                                  controller
                                      .obscureResetConfirmPassword
                                      .toggle(),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 28),



                      /// Reset button
                      Obx(
                        () => FilledButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.resetPassword,


                          style:
                              FilledButton.styleFrom(

                            minimumSize:
                                const Size.fromHeight(58),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),

                            elevation: 0,
                          ),


                          child:
                              controller.isLoading.value

                                  ? SizedBox(
                                      height: 22,
                                      width: 22,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: cs.onPrimary,
                                      ),
                                    )


                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [

                                        Text(
                                          'Reset Password',
                                          style:
                                              TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),

                                        SizedBox(width: 8),

                                        Icon(
                                          Icons
                                              .arrow_forward_rounded,
                                        ),
                                      ],
                                    ),
                        ),
                      ),


                      const SizedBox(height: 28),



                      /// Back login
                      Center(
                        child: TextButton.icon(

                          onPressed: () =>
                              Get.offAllNamed(
                                AppRoutes.login,
                              ),

                          icon: Icon(
                            Icons
                                .arrow_back_ios_new_rounded,

                            size: 16,
                            color: cs.primary,
                          ),


                          label: Text(
                            'back_to_log_in'.tr,

                            style: TextStyle(
                              color: cs.primary,
                              fontWeight:
                                  FontWeight.w700,
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