import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/modules/profile/profile_controller.dart';
import 'package:jkworlds/data/models/damage_report_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class CarDamageReportsView extends GetView<ProfileController> {
  const CarDamageReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Fetch dashboard whenever this view is displayed
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
          onRefresh: () => controller.loadDamageReportsDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Car Damage Reports',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track and manage all your vehicle damage claims',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () => Get.toNamed(AppRoutes.reportDamage),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5500),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Report Damage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Section
                Obx(() => _buildStatsRow(context)),
                const SizedBox(height: 24),

                // Damage reports list
                Obx(() {
                  if (controller.isLoadingReportsList.value && controller.damageReports.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.damageReports.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.damageReports.length,
                    itemBuilder: (context, index) {
                      final report = controller.damageReports[index];
                      return _buildReportCard(context, report);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24) / 3;
        final bool isSmallScreen = constraints.maxWidth < 450;

        if (isSmallScreen) {
          return Column(
            children: [
              _buildStatCard(
                context,
                'Total Reports',
                controller.totalDamageReports.value.toString(),
                theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                context,
                'Pending',
                controller.pendingDamageReports.value.toString(),
                const Color(0xFFFF9F0A),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                context,
                'Resolved',
                controller.resolvedDamageReports.value.toString(),
                const Color(0xFF34C759),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                context,
                'Total Reports',
                controller.totalDamageReports.value.toString(),
                theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                context,
                'Pending',
                controller.pendingDamageReports.value.toString(),
                const Color(0xFFFF9F0A),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                context,
                'Resolved',
                controller.resolvedDamageReports.value.toString(),
                const Color(0xFF34C759),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, DamageReportModel report) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Status Badge Details
    String statusLabel = report.statusLabel ?? report.status.capitalizeFirst ?? report.status;
    Color statusBgColor = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);

    switch (report.status.toLowerCase()) {
      case 'resolved':
        statusBgColor = const Color(0xFFD1FAE5);
        statusTextColor = const Color(0xFF059669);
        break;
      case 'reviewed':
        statusBgColor = const Color(0xFFDBEAFE);
        statusTextColor = const Color(0xFF2563EB);
        break;
      case 'rejected':
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        break;
      default:
        break;
    }

    final formattedDate = DateFormat('dd MMM yyyy').format(report.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report.vehicleTitle ?? 'Unknown Vehicle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle: Report and Booking ID
          Text(
            'Report #${report.reportNumber ?? report.id} · Booking #${report.bookingCode ?? report.bookingId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Grid Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReportDetailColumn(context, 'Issue', report.title),
              _buildReportDetailColumn(
                context,
                'Severity',
                report.severity.capitalizeFirst ?? report.severity,
              ),
              _buildReportDetailColumn(context, 'Date', formattedDate),
              _buildReportDetailColumn(context, 'Photos', report.images.length.toString()),
            ],
          ),
          const SizedBox(height: 16),

          // Description snippet
          if (report.description.isNotEmpty) ...[
            Text(
              report.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],

          // View Details Link
          GestureDetector(
            onTap: () => _showReportDetailsDialog(context, report),
            child: const Text(
              'View Details',
              style: TextStyle(
                color: Color(0xFFFF5500),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Damage Claims Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All reports you submit will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetailsDialog(BuildContext context, DamageReportModel report) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(report.createdAt);

    // Status Badge Details
    String statusLabel = report.statusLabel ?? report.status.capitalizeFirst ?? report.status;
    Color statusBgColor = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);

    switch (report.status.toLowerCase()) {
      case 'resolved':
        statusBgColor = const Color(0xFFD1FAE5);
        statusTextColor = const Color(0xFF059669);
        break;
      case 'reviewed':
        statusBgColor = const Color(0xFFDBEAFE);
        statusTextColor = const Color(0xFF2563EB);
        break;
      case 'rejected':
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        break;
      default:
        break;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Damage Claim Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Vehicle & Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.vehicleTitle ?? 'Unknown Vehicle',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (report.vehiclePlateNumber != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Plate: ${report.vehiclePlateNumber}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Report Details Grid
                _buildModalDetailRow('Report No', '#${report.reportNumber ?? report.id}', cs),
                _buildModalDetailRow('Booking Code', report.bookingCode ?? report.bookingId, cs),
                _buildModalDetailRow('Date Filed', formattedDate, cs),
                _buildModalDetailRow('Damage Issue', report.title, cs),
                _buildModalDetailRow('Severity Level', report.severity.capitalizeFirst ?? report.severity, cs),
                const SizedBox(height: 16),

                // Description Block
                Text(
                  'Description',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                    report.description.isNotEmpty ? report.description : 'No description provided.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Admin Note Block
                if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
                  Text(
                    'Admin Review Note',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      report.adminNote!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Photos Grid
                if (report.images.isNotEmpty) ...[
                  Text(
                    'Attached Photos (${report.images.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.images.length,
                      itemBuilder: (context, idx) {
                        final imgUrl = report.images[idx];
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                            image: DecorationImage(
                              image: NetworkImage(imgUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
