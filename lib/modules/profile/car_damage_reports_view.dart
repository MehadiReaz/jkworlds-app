import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/modules/profile/profile_controller.dart';
import 'package:jkworlds/data/models/damage_report_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class CarDamageReportsView extends GetView<ProfileController> {
  const CarDamageReportsView({super.key});

  static const Color _orange = Color(0xFFFF5500);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDamageReportsDashboard();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Car Damage Reports'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _orange,
          onRefresh: () => controller.loadDamageReportsDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(context),
                const SizedBox(height: 20),
                Obx(() => _buildStatsRow(context)),
                const SizedBox(height: 24),
                _buildSectionLabel(context, 'Recent Reports'),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoadingReportsList.value &&
                      controller.damageReports.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: _orange)),
                    );
                  }
                  if (controller.damageReports.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.damageReports.length,
                    itemBuilder: (context, index) =>
                        _buildReportCard(context, controller.damageReports[index]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Page Header ──────────────────────────────────────────────

  Widget _buildPageHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Damage Reports',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track and manage your vehicle damage claims',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.reportDamage),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Report'),
          style: FilledButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Total',
            value: controller.totalDamageReports.value.toString(),
            icon: Icons.assignment_outlined,
            iconBg: Theme.of(context).colorScheme.surfaceContainerHighest,
            iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
            valueColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Pending',
            value: controller.pendingDamageReports.value.toString(),
            icon: Icons.schedule_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            valueColor: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Resolved',
            value: controller.resolvedDamageReports.value.toString(),
            icon: Icons.check_circle_outline_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            valueColor: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Report Card ──────────────────────────────────────────────

  Widget _buildReportCard(BuildContext context, DamageReportModel report) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final formattedDate = DateFormat('dd MMM yyyy').format(report.createdAt);

    final (statusLabel, statusBg, statusFg, accentColor) =
        _statusStyle(report.status, cs);
    final (severityDot, _) = _severityStyle(report.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status accent stripe
          Container(height: 3, color: accentColor),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        report.vehicleTitle ?? 'Unknown Vehicle',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Report #${report.reportNumber ?? report.id} · Booking #${report.bookingCode ?? report.bookingId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),

                // 3-column meta (Issue / Severity / Date)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetaItem(context, 'Issue', report.title),
                    ),
                    Expanded(
                      child: _buildMetaItemWithDot(
                        context,
                        'Severity',
                        report.severity.capitalizeFirst ?? report.severity,
                        severityDot,
                      ),
                    ),
                    Expanded(
                      child: _buildMetaItem(context, 'Date', formattedDate),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                if (report.description.isNotEmpty) ...[
                  Text(
                    report.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),

                // Footer: view link + photo count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showReportDetailsDialog(context, report),
                      child: const Text(
                        'View details',
                        style: TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (report.images.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 14,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${report.images.length} photos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.45),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaItemWithDot(
    BuildContext context,
    String label,
    String value,
    Color dotColor,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.45),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              value.isNotEmpty ? value : 'N/A',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Empty State ───────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.car_crash_outlined,
                size: 34,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No damage claims yet',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reports you submit will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Details Dialog ────────────────────────────────────────────

  void _showReportDetailsDialog(BuildContext context, DamageReportModel report) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(report.createdAt);
    final (statusLabel, statusBg, statusFg, _) = _statusStyle(report.status, cs);
    final (severityDot, severityBg) = _severityStyle(report.severity);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Damage claim details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 12),

                // Vehicle header card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.directions_car_rounded,
                            size: 20, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.vehicleTitle ?? 'Unknown Vehicle',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (report.vehiclePlateNumber != null)
                              Text(
                                report.vehiclePlateNumber!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Detail rows
                _buildDialogRow('Report no.', '#${report.reportNumber ?? report.id}', cs),
                _buildDialogRow('Booking code', report.bookingCode ?? report.bookingId, cs),
                _buildDialogRow('Filed on', formattedDate, cs),
                _buildDialogRow('Issue', report.title, cs),
                // Severity with coloured pill
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Severity',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: severityDot,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              report.severity.capitalizeFirst ?? report.severity,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: severityDot,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'Description',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    report.description.isNotEmpty
                        ? report.description
                        : 'No description provided.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),

                // Admin note
                if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined,
                          size: 14, color: cs.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Admin note',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      report.adminNote!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                // Photos
                if (report.images.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Attached photos (${report.images.length})',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.images.length,
                      itemBuilder: (context, idx) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                          image: DecorationImage(
                            image: NetworkImage(report.images[idx]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Returns (label, badgeBg, badgeFg, accentStripeColor)
  (String, Color, Color, Color) _statusStyle(String status, ColorScheme cs) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return ('Resolved', const Color(0xFFD1FAE5), const Color(0xFF059669), const Color(0xFF34C759));
      case 'reviewed':
        return ('Reviewed', const Color(0xFFDBEAFE), const Color(0xFF2563EB), const Color(0xFF0A84FF));
      case 'rejected':
        return ('Rejected', const Color(0xFFFEE2E2), const Color(0xFFDC2626), const Color(0xFFFF3B30));
      default:
        final label = status.capitalizeFirst ?? status;
        return (label, const Color(0xFFFEF3C7), const Color(0xFFD97706), const Color(0xFFFF9F0A));
    }
  }

  /// Returns (dotColor, bgColor)
  (Color, Color) _severityStyle(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return (const Color(0xFFEF4444), const Color(0xFFFEE2E2));
      case 'medium':
        return (const Color(0xFFF59E0B), const Color(0xFFFEF3C7));
      default:
        return (const Color(0xFF10B981), const Color(0xFFD1FAE5));
    }
  }
}