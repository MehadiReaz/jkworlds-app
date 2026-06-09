import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import 'package:jkworlds/data/services/auth_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final currencyService = Get.find<CurrencyService>();
    final auth = Get.find<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── Auth Section ─────────────────────────────────────
          Obx(() => auth.isLoggedIn.value
              ? _buildLoggedInCard(context, auth, theme)
              : _buildLoginPromptCard(context, theme)),
          const SizedBox(height: 24),

          // ── Language Section ─────────────────────────────────────
          _sectionTitle(context, 'language'.tr, Icons.language),
          const SizedBox(height: 8),
          ...profileCtrl.locales.map((item) {
            final locale = item['locale'] as Locale;
            final name = item['name'] as String;
            return ListTile(
              title: Text(name),
              trailing: Get.locale?.languageCode == locale.languageCode
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => profileCtrl.changeLocale(locale),
            );
          }),

          const Divider(height: 40),

          // ── Currency Section ────────────────────────────────────
          _sectionTitle(context, 'currency'.tr, Icons.attach_money),
          const SizedBox(height: 8),
          Obx(() {
            return Column(
              children: currencyService.currencies.map((cur) {
                final isSelected =
                    currencyService.selectedCurrency.value.code == cur.code;
                return ListTile(
                  title: Text('${cur.symbol}  ${cur.name}'),
                  subtitle: Text(cur.code),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () => currencyService.changeCurrency(cur.code),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ── Logged-in card: shows user info + logout ──────────────────
  Widget _buildLoggedInCard(
      BuildContext context, AuthService auth, ThemeData theme) {
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: cs.primary,
            child: Text(
              auth.userName.value.isNotEmpty
                  ? auth.userName.value[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            auth.userName.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.userEmail.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text('logout'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login prompt card ─────────────────────────────────────────
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

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
