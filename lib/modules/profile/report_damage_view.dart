import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/modules/profile/profile_controller.dart';

class ReportDamageView extends GetView<ProfileController> {
  const ReportDamageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Report Car Damage'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAMAGE REPORT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Report Car Damage',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select one of your bookings and submit a report for any condition issues or damage.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: _cardDecoration(theme, cs),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useRow = constraints.maxWidth > 500;
                        if (useRow) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel(context, 'Select Booking / Vehicle', required: true),
                                    _buildBookingDropdown(context),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel(context, 'Severity', required: true),
                                    _buildSeverityDropdown(context),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(context, 'Select Booking / Vehicle', required: true),
                              _buildBookingDropdown(context),
                              const SizedBox(height: 16),
                              _buildFieldLabel(context, 'Severity', required: true),
                              _buildSeverityDropdown(context),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel(context, 'Damage Title', required: true),
                    TextFormField(
                      controller: controller.damageTitleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Scratch on rear bumper',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel(context, 'Description'),
                    TextFormField(
                      controller: controller.damageDescriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe what happened...',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel(context, 'Upload Images'),
                    _buildImagePickerSection(context, theme, cs),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 20),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: theme.cardColor,
                              foregroundColor: cs.onSurface,
                              side: BorderSide(
                                color: cs.outlineVariant.withValues(alpha: 0.8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: controller.isSubmittingDamageReport.value
                                ? null
                                : () => controller.submitDamageReport(),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5500),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSubmittingDamageReport.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label, {bool required = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildBookingDropdown(BuildContext context) {
    return Obx(() {
      final bookings = controller.bookings;
      final isLoading = controller.isLoadingBookings;

      if (isLoading) {
        return DropdownButtonFormField<String>(
          value: null,
          hint: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          items: const [],
          onChanged: null,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }

      if (bookings.isEmpty) {
        return DropdownButtonFormField<String>(
          value: null,
          hint: const Text('-- No Bookings Available --'),
          items: const [],
          onChanged: null,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }

      return DropdownButtonFormField<String>(
        value: controller.damageSelectedBookingId.value,
        hint: const Text('Choose a booking'),
        isExpanded: true,
        items: bookings.map((booking) {
          final title = booking.vehicle?.name != null
              ? "${booking.vehicle!.name} (${booking.bookingNumber ?? booking.id})"
              : "Booking #${booking.bookingNumber ?? booking.id}";
          return DropdownMenuItem<String>(
            value: booking.id,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          controller.damageSelectedBookingId.value = val;
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  Widget _buildSeverityDropdown(BuildContext context) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.damageSeverity.value,
        hint: const Text('Select Severity'),
        items: const [
          DropdownMenuItem(value: 'minor', child: Text('Minor')),
          DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
          DropdownMenuItem(value: 'severe', child: Text('Severe')),
        ],
        onChanged: (val) {
          if (val != null) {
            controller.damageSeverity.value = val;
          }
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  Widget _buildImagePickerSection(BuildContext context, ThemeData theme, ColorScheme cs) {
    return Obx(() {
      final images = controller.damageSelectedImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => controller.pickDamageImage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFECE5),
                    foregroundColor: const Color(0xFFFF5500),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Choose files',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    images.isEmpty
                        ? 'No file chosen'
                        : '${images.length} file${images.length > 1 ? 's' : ''} chosen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final path = images[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => controller.removeDamageImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'You can upload multiple photos (JPG, PNG, WEBP — max 5MB each)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    });
  }

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
}
