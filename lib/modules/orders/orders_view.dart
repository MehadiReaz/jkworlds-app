import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'orders_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/booking_model.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final filterOptions = [
      'all_types'.tr,
      'confirmed'.tr,
      'active'.tr,
      'completed'.tr,
      'cancelled'.tr,
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('my_bookings'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter Chips Option Row ─────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: List.generate(filterOptions.length, (index) {
                  final label = filterOptions[index];
                  return Obx(() {
                    final isSelected = ctrl.selectedTab.value == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) ctrl.changeTab(index);
                        },
                        selectedColor: cs.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: theme.cardColor,
                        side: BorderSide(
                          color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  });
                }),
              ),
            ),

            // ── Bookings Table Card ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Headers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: _buildTableHeaderText('Car', cs)),
                            Expanded(flex: 3, child: _buildTableHeaderText('Date', cs)),
                            Expanded(flex: 2, child: _buildTableHeaderText('Status', cs, textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: _buildTableHeaderText('Amount', cs, textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),

                      // Table Rows
                      Obx(() {
                        final bookings = ctrl.filteredBookings;
                        if (bookings.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 48,
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'no_results'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Car Column (Photo + Name)
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: (booking.vehicle?.images.isNotEmpty ?? false)
                                                ? Image.asset(
                                                    booking.vehicle!.images[0],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Icon(
                                                      Icons.directions_car_rounded,
                                                      size: 20,
                                                      color: cs.primary,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.directions_car_rounded,
                                                    size: 20,
                                                    color: cs.primary,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${booking.vehicle?.brand ?? ''} ${booking.vehicle?.name ?? 'Booking #${booking.id}'}'.trim().replaceAll(RegExp(r'\s*\(.*\)'), ''),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Date Column
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _formatDateRange(booking.pickupDate, booking.returnDate),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),

                                  // Status Column
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: _buildStatusWidget(booking.status, cs),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      currencyService.formatPrice(booking.totalPrice),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: cs.onSurface,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header Text Helper ──────────────────────────────────────────
  Widget _buildTableHeaderText(String text, ColorScheme cs, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      textAlign: textAlign,
    );
  }

  // ── Date Range Formatter ────────────────────────────────────────
  String _formatDateRange(DateTime start, DateTime end) {
    final startFormat = DateFormat('MMM d');
    final endFormat = DateFormat('MMM d, yyyy');
    return '${startFormat.format(start)} – ${endFormat.format(end)}';
  }

  // ── Colored Status Label Helper ─────────────────────────────────
  Widget _buildStatusWidget(BookingStatus status, ColorScheme cs) {
    String text;
    Color color;

    switch (status) {
      case BookingStatus.active:
        text = 'ACTIVE';
        color = const Color(0xFF2E7D32); // Green
        break;
      case BookingStatus.upcoming:
        text = 'CONFIRMED';
        color = const Color(0xFF1565C0); // Blue
        break;
      case BookingStatus.past:
        text = 'COMPLETED';
        color = const Color(0xFF757575); // Grey
        break;
      case BookingStatus.cancelled:
        text = 'CANCELLED';
        color = const Color(0xFFC62828); // Red
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
