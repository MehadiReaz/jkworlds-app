import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/data/services/notification_service.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifService = Get.find<NotificationService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('notification_settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── Master Toggle ──────────────────────────────────────
          _buildMasterToggle(context, notifService, cs, theme),
          const SizedBox(height: 24),

          // ── Category Toggles ───────────────────────────────────
          _buildSectionHeader(context, 'notif_categories'.tr),
          const SizedBox(height: 8),
          Obx(
            () => AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: notifService.pushEnabled.value ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !notifService.pushEnabled.value,
                child: _buildCategoryCard(
                  context,
                  cs,
                  theme,
                  notifService,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Info Note ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'notif_info'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Master Push Toggle ──────────────────────────────────────────
  Widget _buildMasterToggle(
    BuildContext context,
    NotificationService notifService,
    ColorScheme cs,
    ThemeData theme,
  ) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 28,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'push_notifications'.tr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    notifService.pushEnabled.value
                        ? 'notif_enabled'.tr
                        : 'notif_disabled'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch.adaptive(
              value: notifService.pushEnabled.value,
              onChanged: notifService.togglePushEnabled,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Card ───────────────────────────────────────────────
  Widget _buildCategoryCard(
    BuildContext context,
    ColorScheme cs,
    ThemeData theme,
    NotificationService notifService,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            context: context,
            icon: Icons.event_note_rounded,
            iconBg: cs.primaryContainer,
            iconColor: cs.onPrimaryContainer,
            title: 'notif_booking_updates'.tr,
            subtitle: 'notif_booking_updates_desc'.tr,
            value: notifService.bookingUpdates,
            onChanged: notifService.toggleBookingUpdates,
          ),
          _divider(cs),
          _buildToggleTile(
            context: context,
            icon: Icons.local_offer_rounded,
            iconBg: cs.tertiaryContainer,
            iconColor: cs.onTertiaryContainer,
            title: 'notif_promotions'.tr,
            subtitle: 'notif_promotions_desc'.tr,
            value: notifService.promotions,
            onChanged: notifService.togglePromotions,
          ),
          _divider(cs),
          _buildToggleTile(
            context: context,
            icon: Icons.trending_down_rounded,
            iconBg: cs.errorContainer,
            iconColor: cs.onErrorContainer,
            title: 'notif_price_alerts'.tr,
            subtitle: 'notif_price_alerts_desc'.tr,
            value: notifService.priceAlerts,
            onChanged: notifService.togglePriceAlerts,
          ),
          _divider(cs),
          _buildToggleTile(
            context: context,
            icon: Icons.directions_car_rounded,
            iconBg: cs.secondaryContainer,
            iconColor: cs.onSecondaryContainer,
            title: 'notif_new_vehicles'.tr,
            subtitle: 'notif_new_vehicles_desc'.tr,
            value: notifService.newVehicles,
            onChanged: notifService.toggleNewVehicles,
          ),
        ],
      ),
    );
  }

  // ── Single Toggle Tile ──────────────────────────────────────────
  Widget _buildToggleTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required RxBool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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

  Widget _divider(ColorScheme cs) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: cs.outlineVariant.withValues(alpha: 0.2),
    );
  }

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
}
