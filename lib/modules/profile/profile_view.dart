import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/core/utils/dialog_helper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final auth = Get.find<AuthService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── Account Card ──────────────────────────────────────
          Obx(
            () => auth.isLoggedIn.value
                ? _buildLoggedInCard(context, auth, theme)
                : _buildLoginPromptCard(context, theme),
          ),
          const SizedBox(height: 28),

          // ── General Section ───────────────────────────────────
          _buildSectionHeader(context, 'general'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(context, [
            _MenuItem(
              icon: Icons.local_offer_rounded,
              iconBg: cs.tertiaryContainer,
              iconColor: cs.onTertiaryContainer,
              title: 'promo_codes'.tr,
              onTap: () => Get.toNamed(AppRoutes.promoCodes),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              iconBg: cs.secondaryContainer,
              iconColor: cs.onSecondaryContainer,
              title: 'notification_settings'.tr,
              onTap: () => Get.toNamed(AppRoutes.notificationSettings),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Preferences Section ───────────────────────────────
          _buildSectionHeader(context, 'preferences'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(context, [
            _MenuItem(
              icon: Icons.tune_rounded,
              iconBg: cs.primaryContainer,
              iconColor: cs.onPrimaryContainer,
              title: 'currency'.tr,
              onTap: () => Get.toNamed(AppRoutes.preferences),
            ),
            _MenuToggleItem(
              icon: Icons.dark_mode_rounded,
              iconBg: const Color(0xFF2D2D3A),
              iconColor: const Color(0xFFE8DEF8),
              title: 'dark_mode'.tr,
              value: profileCtrl.isDarkMode,
              onChanged: profileCtrl.toggleDarkMode,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Support Section ───────────────────────────────────
          _buildSectionHeader(context, 'support'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(context, [
            _MenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              iconBg: cs.tertiaryContainer,
              iconColor: cs.onTertiaryContainer,
              title: 'Support Messages',
              onTap: () {
                if (auth.isLoggedIn.value) {
                  Get.toNamed(AppRoutes.supportTickets);
                } else {
                  Get.toNamed(AppRoutes.login);
                }
              },
            ),
            _MenuItem(
              icon: Icons.help_outline_rounded,
              iconBg: cs.secondaryContainer,
              iconColor: cs.onSecondaryContainer,
              title: 'help_support'.tr,
              onTap: () => Get.toNamed(AppRoutes.helpSupport),
            ),
            _MenuItem(
              icon: Icons.mail_outline_rounded,
              iconBg: cs.primaryContainer,
              iconColor: cs.onPrimaryContainer,
              title: 'contact_us'.tr,
              onTap: () => Get.toNamed(AppRoutes.contactUs),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Legal Section ─────────────────────────────────────
          _buildSectionHeader(context, 'legal'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(context, [
            _MenuItem(
              icon: Icons.info_outline_rounded,
              iconBg: cs.surfaceContainerHighest,
              iconColor: cs.onSurfaceVariant,
              title: 'about'.tr,
              onTap: () => Get.toNamed(AppRoutes.about),
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              iconBg: cs.surfaceContainerHighest,
              iconColor: cs.onSurfaceVariant,
              title: 'terms_of_service'.tr,
              onTap: () => Get.toNamed(AppRoutes.terms),
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              iconBg: cs.surfaceContainerHighest,
              iconColor: cs.onSurfaceVariant,
              title: 'privacy_policy'.tr,
              onTap: () => Get.toNamed(AppRoutes.privacy),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Logout Button ────────────────────────────────────
          Obx(
            () => auth.isLoggedIn.value
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        DialogHelper.showConfirmation(
                          title: 'logout_confirm_title'.tr,
                          message: 'logout_confirm_message'.tr,
                          isDestructive: true,
                          onConfirm: () => auth.logout(),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text('logout'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(
                          color: cs.error.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // ── App Version ──────────────────────────────────────
          Center(
            child: Text(
              '${'app_name'.tr} v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  // ── Menu Card ───────────────────────────────────────────────────
  Widget _buildMenuCard(BuildContext context, List<_MenuItemBase> items) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i].build(context),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
          ],
        ],
      ),
    );
  }

  // ── Logged-in card ──────────────────────────────────────────────
  Widget _buildLoggedInCard(
    BuildContext context,
    AuthService auth,
    ThemeData theme,
  ) {
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: cs.primary,
            child: auth.userPhotoUrl.value.isNotEmpty
                ? ClipOval(
                    child: _buildAvatarImage(
                      auth.userPhotoUrl.value,
                      cs,
                      Text(
                        auth.userName.value.isNotEmpty
                            ? auth.userName.value[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  )
                : Text(
                    auth.userName.value.isNotEmpty
                        ? auth.userName.value[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.userEmail.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.editProfile),
            icon: Icon(
              Icons.edit_outlined,
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login prompt card ───────────────────────────────────────────
  Widget _buildLoginPromptCard(BuildContext context, ThemeData theme) {
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: cs.primaryContainer,
            child: Icon(
              Icons.person_outline_rounded,
              size: 36,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'login_prompt'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('login'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.signup),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('signup'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String path, ColorScheme cs, Widget fallback) {
    if (path.isEmpty) {
      return fallback;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    final isNetworkPath = path.contains('backend/image') ||
        (!path.startsWith('/') && !path.contains(':/') && !path.startsWith('content:'));

    if (isNetworkPath) {
      final fullUrl = path.startsWith('/')
          ? '${ApiConstants.baseUrl}$path'
          : '${ApiConstants.baseUrl}/$path';
      return Image.network(
        fullUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.file(
      File(path),
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

// ── Menu Item Models ──────────────────────────────────────────────

abstract class _MenuItemBase {
  Widget build(BuildContext context);
}

class _MenuItem extends _MenuItemBase {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuToggleItem extends _MenuItemBase {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final RxBool value;
  final ValueChanged<bool> onChanged;

  _MenuToggleItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Obx(
            () => Switch.adaptive(
              value: value.value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
