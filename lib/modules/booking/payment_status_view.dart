import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'payment_status_controller.dart';

class PaymentStatusView extends GetView<PaymentStatusController> {
  const PaymentStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Obx(() {
      final currentStatus = controller.status.value;
      final canPop = currentStatus == PaymentVerificationStatus.failed;

      return PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          // If in verifying/success status, we prevent popping to avoid half-completed checkout states
        },
        child: Scaffold(
          backgroundColor: isLight ? Colors.white : theme.scaffoldBackgroundColor,
          appBar: currentStatus == PaymentVerificationStatus.failed
              ? AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  title: const Text('Payment Failed'),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                )
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (currentStatus == PaymentVerificationStatus.verifying)
                        _buildVerifyingState(theme, cs)
                      else if (currentStatus == PaymentVerificationStatus.success)
                        _buildSuccessState(theme, cs, isLight)
                      else
                        _buildFailedState(theme, cs, isLight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ── 1. Verifying State UI ──────────────────────────────────────
  Widget _buildVerifyingState(ThemeData theme, ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 60),
        // Pulsing-like Ring indicator around Circular Progress
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                backgroundColor: cs.primary.withValues(alpha: 0.15),
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 40, color: cs.primary),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          'Securing your booking...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'We are verifying your transaction with the payment provider. Please do not close the app or navigate back.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── 2. Success State UI ────────────────────────────────────────
  Widget _buildSuccessState(ThemeData theme, ColorScheme cs, bool isLight) {
    final booking = controller.confirmedBooking;
    final vehicle = controller.vehicle ?? booking?.vehicle;
    final primaryColor = cs.primary;

    final startFormat = DateFormat('EEE, MMM d, yyyy');
    final endFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      children: [
        const SizedBox(height: 20),
        // Success Ring and Badge
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9), // Light green background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.15),
                spreadRadius: 8,
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Booking Confirmed!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for your payment. Your trip is now active and secure.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Booking Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Reference & Type)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOOKING ID',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking?.bookingNumber ?? 'Booking #${booking?.id ?? ''}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking?.rentalType == RentalType.chauffeur ? 'Chauffeur' : 'Self-Drive',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(),
                ),

                // Vehicle Summary
                if (vehicle != null) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 55,
                          color: cs.surfaceContainerHighest,
                          child: vehicle.images.isNotEmpty
                              ? Image.network(
                                  vehicle.images[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.directions_car_rounded, color: cs.primary, size: 28),
                                )
                              : Icon(Icons.directions_car_rounded, color: cs.primary, size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.brand,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vehicle.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                ],

                // Trip Dates & Times
                if (booking != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PICKUP',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              startFormat.format(booking.pickupDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              timeFormat.format(booking.pickupDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RETURN',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              endFormat.format(booking.returnDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              timeFormat.format(booking.returnDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Locations
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.pickupLocation} to ${booking.dropoffLocation}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                ],

                // Total Price Paid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Paid',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      booking != null
                          ? '${booking.currency ?? 'NGN'} ${booking.payableAmountFormatted ?? booking.totalPrice.toStringAsFixed(2)}'
                          : '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF5403), // Custom orange matching checkout view
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Action Buttons
        ElevatedButton(
          onPressed: controller.goToBookings,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: cs.onPrimary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Go to My Bookings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: controller.goToHome,
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: Text(
            'Go to Home',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. Failed State UI ─────────────────────────────────────────
  Widget _buildFailedState(ThemeData theme, ColorScheme cs, bool isLight) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE), // Light red background
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_rounded,
            color: Colors.red,
            size: 60,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Payment Verification Failed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'An error occurred during verification. We could not verify your payment. Please try again or contact customer support.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),

        // Action Buttons
        ElevatedButton(
          onPressed: controller.verifyPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Retry Verification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            side: BorderSide(color: cs.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Back to Checkout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
