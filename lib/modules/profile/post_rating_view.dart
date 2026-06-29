import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/modules/profile/profile_controller.dart';

class PostRatingView extends GetView<ProfileController> {
  const PostRatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
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
                'RATINGS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rate Your Car Experience',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select one of your bookings and submit a review for the booked car.',
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
                                    _buildFieldLabel(context, 'Select Booking', required: true),
                                    _buildBookingDropdown(context),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel(context, 'Rating', required: true),
                                    _buildRatingDropdown(context),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(context, 'Select Booking', required: true),
                              _buildBookingDropdown(context),
                              const SizedBox(height: 16),
                              _buildFieldLabel(context, 'Rating', required: true),
                              _buildRatingDropdown(context),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel(context, 'Review'),
                    TextFormField(
                      controller: controller.commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write your experience...',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed: controller.isSubmittingRating.value
                              ? null
                              : () => controller.submitRating(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA085),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isSubmittingRating.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Submit Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
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
        value: controller.selectedBookingId.value,
        hint: const Text('-- Select Booking --'),
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
          controller.selectedBookingId.value = val;
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  Widget _buildRatingDropdown(BuildContext context) {
    return Obx(() {
      return DropdownButtonFormField<double>(
        value: controller.selectedRating.value,
        hint: const Text('Select Rating'),
        items: const [
          DropdownMenuItem(value: 5.0, child: Text('⭐⭐⭐⭐⭐ (5 - Excellent)')),
          DropdownMenuItem(value: 4.0, child: Text('⭐⭐⭐⭐ (4 - Very Good)')),
          DropdownMenuItem(value: 3.0, child: Text('⭐⭐⭐ (3 - Good)')),
          DropdownMenuItem(value: 2.0, child: Text('⭐⭐ (2 - Fair)')),
          DropdownMenuItem(value: 1.0, child: Text('⭐ (1 - Poor)')),
        ],
        onChanged: (val) {
          controller.selectedRating.value = val;
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
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
