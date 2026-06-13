import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_profile_controller.dart';
import 'package:jkworlds/modules/auth/widgets/shared_auth_widgets.dart';
import 'package:jkworlds/core/constants/api_constants.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Personal Info'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Title ─────────────────────────────────
              Text(
                'Personal Info',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // ── Card 1: Personal Information ──────────────────
              Container(
                decoration: _cardDecoration(theme, cs),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Form(
                  key: controller.profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Profile Photo Preview ────────────────────────
                      Center(
                        child: Stack(
                          children: [
                            Obx(() {
                              final path = controller.selectedImagePath.value;
                              Widget imageWidget;
                              if (path.isEmpty) {
                                imageWidget = Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: cs.onSurfaceVariant,
                                );
                              } else if (path.startsWith('assets/')) {
                                imageWidget = Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: cs.onSurfaceVariant,
                                    );
                                  },
                                );
                              } else if (path.startsWith('http://') || path.startsWith('https://')) {
                                imageWidget = Image.network(
                                  path,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: cs.onSurfaceVariant,
                                    );
                                  },
                                );
                              } else if (path.contains('backend/image') ||
                                  (!path.startsWith('/') && !path.contains(':/') && !path.startsWith('content:'))) {
                                final fullUrl = path.startsWith('/')
                                    ? '${ApiConstants.baseUrl}$path'
                                    : '${ApiConstants.baseUrl}/$path';
                                imageWidget = Image.network(
                                  fullUrl,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: cs.onSurfaceVariant,
                                    );
                                  },
                                );
                              } else {
                                imageWidget = Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: cs.onSurfaceVariant,
                                    );
                                  },
                                );
                              }

                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.surfaceContainerHighest,
                                  border: Border.all(
                                    color: cs.primary,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(child: imageWidget),
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: cs.primary,
                                shape: const CircleBorder(),
                                elevation: 4,
                                child: InkWell(
                                  onTap: controller.chooseFile,
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.cardColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 20,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Full Name & Email Row ───────────────────────
                      _buildGridRow(
                        context: context,
                        child1: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('FULL NAME', cs),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              validator: controller.validateName,
                              decoration: buildAuthInputDecoration(
                                hintText: 'Enter your name',
                                cs: cs,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        child2: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('EMAIL', cs),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateEmail,
                              decoration: buildAuthInputDecoration(
                                hintText: 'Enter your email',
                                cs: cs,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Phone Number & Address Row ──────────────────
                      _buildGridRow(
                        context: context,
                        child1: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('PHONE NUMBER', cs),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: buildAuthInputDecoration(
                                hintText: 'Enter your phone number',
                                cs: cs,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        child2: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ADDRESS', cs),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.addressCtrl,
                              decoration: buildAuthInputDecoration(
                                hintText: 'Enter your address',
                                cs: cs,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Update Button ──────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.updateProfile,
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              minimumSize: const Size(120, 46),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Card 2: Change Password ──────────────────────
              Container(
                decoration: _cardDecoration(theme, cs),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Form(
                  key: controller.passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── New Password Grid Row (Half width on tablet) ─
                      _buildGridRow(
                        context: context,
                        child1: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('NEW PASSWORD', cs),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.newPasswordCtrl,
                              obscureText: true,
                              validator: controller.validatePassword,
                              decoration: buildAuthInputDecoration(
                                hintText: 'Enter new password',
                                cs: cs,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        child2: const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // ── Confirm New Password ────────────────────────
                      _buildLabel('CONFIRM NEW PASSWORD', cs),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.confirmNewPasswordCtrl,
                        obscureText: true,
                        validator: controller.validateConfirmPassword,
                        decoration: buildAuthInputDecoration(
                          hintText: 'Confirm new password',
                          cs: cs,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Change Password Button ──────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(
                          () => FilledButton(
                            onPressed: controller.isPasswordLoading.value
                                ? null
                                : controller.changePassword,
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              minimumSize: const Size(170, 46),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isPasswordLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
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
    );
  }

  // ── Reusable card decoration ───────────────────────────────────
  BoxDecoration _cardDecoration(ThemeData theme, ColorScheme cs) {
    final isLight = theme.brightness == Brightness.light;
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ── Reusable label helper ──────────────────────────────────────
  Widget _buildLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Responsive layout helper ───────────────────────────────────
  Widget _buildGridRow({
    required BuildContext context,
    required Widget child1,
    required Widget child2,
  }) {
    final double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 16),
          Expanded(child: child2),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child1,
          if (child2 is! SizedBox) ...[const SizedBox(height: 16), child2],
        ],
      );
    }
  }
}
