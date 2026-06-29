import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'booking_detail_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/booking_model.dart';

class BookingDetailsView extends StatelessWidget {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingDetailsController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.booking.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (ctrl.errorMessage.value.isNotEmpty && ctrl.booking.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load booking details.',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ctrl.errorMessage.value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: ctrl.fetchBookingDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final booking = ctrl.booking.value;
        if (booking == null) {
          return const Center(
            child: Text('No booking details found.'),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.fetchBookingDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Overview Card
                _buildStatusHeaderCard(booking, cs, theme),
                const SizedBox(height: 16),

                // 2. Vehicle Overview Card
                if (booking.vehicle != null) ...[
                  _buildVehicleCard(booking, cs, theme),
                  const SizedBox(height: 16),
                ],

                // 3. Trip Schedule Details Card (Dates, Locations)
                _buildScheduleCard(booking, cs, theme),
                const SizedBox(height: 16),

                // 4. Customer Information Card
                _buildCustomerCard(booking, cs, theme),
                const SizedBox(height: 16),

                // 5. Driver Details Card (If Chauffeur drive / Chauffeur Pending)
                if (booking.rentalType == RentalType.chauffeur) ...[
                  _buildDriverCard(booking, cs, theme),
                  const SizedBox(height: 16),
                ],

                // 6. Cost breakdown details Card
                _buildPricingCard(booking, currencyService, cs, theme, isLight),
                const SizedBox(height: 16),

                // 7. Payment details Card
                _buildPaymentCard(booking, cs, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── 1. Status Card ──────────────────────────────────────────────
  Widget _buildStatusHeaderCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    String badgeText = booking.statusLabel.toUpperCase();
    Color badgeColor;
    if (booking.statusLabel.isNotEmpty) {
      switch (booking.statusBadgeClass.toLowerCase()) {
        case 'success':
          badgeColor = const Color(0xFF2E7D32); // Green
          break;
        case 'info':
          badgeColor = const Color(0xFF1565C0); // Blue
          break;
        case 'warning':
          badgeColor = const Color(0xFFE65100); // Amber
          break;
        case 'danger':
        case 'error':
          badgeColor = const Color(0xFFC62828); // Red
          break;
        default:
          badgeColor = const Color(0xFF757575); // Grey
      }
    } else {
      switch (booking.status) {
        case BookingStatus.active:
          badgeText = 'ACTIVE';
          badgeColor = const Color(0xFF2E7D32);
          break;
        case BookingStatus.upcoming:
          badgeText = 'CONFIRMED';
          badgeColor = const Color(0xFF1565C0);
          break;
        case BookingStatus.past:
          badgeText = 'COMPLETED';
          badgeColor = const Color(0xFF757575);
          break;
        case BookingStatus.cancelled:
          badgeText = 'CANCELLED';
          badgeColor = const Color(0xFFC62828);
          break;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bookingNumber ?? 'Booking #${booking.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(booking.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Vehicle Card ─────────────────────────────────────────────
  Widget _buildVehicleCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    final vehicle = booking.vehicle!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 60,
                child: vehicle.images.isNotEmpty
                    ? Image.network(
                        vehicle.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.directions_car_rounded, color: cs.primary, size: 28),
                        ),
                      )
                    : Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.directions_car_rounded, color: cs.primary, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${vehicle.brand} • ${vehicle.type}',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSpecIconText(Icons.airline_seat_recline_normal_rounded, '${vehicle.seats} seats', cs, theme),
                      const SizedBox(width: 12),
                      _buildSpecIconText(Icons.settings_suggest_rounded, vehicle.transmission, cs, theme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecIconText(IconData icon, String text, ColorScheme cs, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
      ],
    );
  }

  // ── 3. Schedule Card ────────────────────────────────────────────
  Widget _buildScheduleCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'TRIP SCHEDULE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Pickup Info Row
            _buildScheduleRow(
              title: 'Pickup',
              dateStr: dateFormat.format(booking.pickupDate),
              timeStr: timeFormat.format(booking.pickupDate),
              location: booking.pickupLocation.isNotEmpty ? booking.pickupLocation : 'Selected Pickup Location',
              icon: Icons.login_rounded,
              iconColor: Colors.green.shade600,
              cs: cs,
              theme: theme,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, indent: 32),
            ),

            // Dropoff Info Row
            _buildScheduleRow(
              title: 'Return',
              dateStr: dateFormat.format(booking.returnDate),
              timeStr: timeFormat.format(booking.returnDate),
              location: booking.dropoffLocation.isNotEmpty ? booking.dropoffLocation : 'Selected Return Location',
              icon: Icons.logout_rounded,
              iconColor: Colors.orange.shade700,
              cs: cs,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow({
    required String title,
    required String dateStr,
    required String timeStr,
    required String location,
    required IconData icon,
    required Color iconColor,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title — $dateStr at $timeStr',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 4. Customer Card ────────────────────────────────────────────
  Widget _buildCustomerCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CUSTOMER INFORMATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', booking.customerName ?? 'User', cs, theme),
            const SizedBox(height: 8),
            _buildDetailRow('Email', booking.customerEmail ?? 'user@gmail.com', cs, theme),
            const SizedBox(height: 8),
            _buildDetailRow('Phone', booking.customerPhone ?? 'N/A', cs, theme),
            const SizedBox(height: 8),
            _buildDetailRow('Service Mode', booking.rentalType == RentalType.chauffeur ? 'Chauffeur Driven' : 'Self Drive', cs, theme),
          ],
        ),
      ),
    );
  }

  // ── 5. Driver Card ──────────────────────────────────────────────
  Widget _buildDriverCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'DRIVER INFORMATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (booking.driverImage != null && booking.driverImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      booking.driverImage!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_pin_rounded, color: cs.primary, size: 24),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_pin_rounded, color: cs.primary, size: 24),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.driverName ?? 'Driver Pending Assignment',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.driverName != null
                            ? 'Phone: ${booking.driverPhone ?? "N/A"}${booking.driverEmail != null ? " • ${booking.driverEmail}" : ""}'
                            : 'A driver will be assigned to your booking shortly.',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 6. Pricing Card ─────────────────────────────────────────────
  Widget _buildPricingCard(BookingModel booking, CurrencyService csService, ColorScheme cs, ThemeData theme, bool isLight) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'COST BREAKDOWN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Rental Fare', booking.baseAmountFormatted ?? '', cs, theme),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Service Fee & Taxes',
              booking.addonsTotalFormatted ?? '',
              cs,
              theme,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Security Deposit', booking.depositAmountFormatted ?? '', cs, theme),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50.withValues(alpha: isLight ? 1.0 : 0.05),
                border: Border.all(color: Colors.orange.shade200, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Paid',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    booking.totalAmountFormatted ?? booking.payableAmountFormatted ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 7. Payment Card ─────────────────────────────────────────────
  Widget _buildPaymentCard(BookingModel booking, ColorScheme cs, ThemeData theme) {
    final payStatus = booking.paymentStatus?.toLowerCase() ?? 'unpaid';
    final isPaid = payStatus == 'paid';
    final statusColor = isPaid ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PAYMENT STATUS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Gateway', booking.paymentMethod != null ? booking.paymentMethod!.toUpperCase() : 'N/A', cs, theme),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  payStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme cs, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
