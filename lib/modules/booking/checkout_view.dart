import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'checkout_controller.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CheckoutController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            // Define the details card content so we can place it either inside sidebar or top/bottom
            Widget buildBookingSummaryCard() {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'BOOKING SUMMARY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle overview
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 54,
                              child: ctrl.vehicle.images.isNotEmpty
                                  ? Image.network(
                                      ctrl.vehicle.images[0],
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ctrl.vehicle.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${ctrl.vehicle.brand} • ${ctrl.vehicle.type}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Breakdown rows
                      _buildSummaryRow(
                        'Base (${ctrl.totalDays}d x ${ctrl.vehicle.dailyRateFormatted.isNotEmpty ? ctrl.vehicle.dailyRateFormatted : currencyService.formatPrice(ctrl.vehicle.pricePerDay)})',
                        currencyService.formatPrice(ctrl.initialSubtotal),
                        cs,
                      ),
                      _buildSummaryRow('Insurance', ctrl.selectedProtection, cs),
                      _buildSummaryRow('Rental Type', ctrl.isSelfDrive ? 'Self Drive' : 'Chauffeur', cs),
                      _buildSummaryRow('Pickup Date', DateFormat('MMM d, yyyy').format(ctrl.pickupDate), cs),
                      _buildSummaryRow('Return Date', DateFormat('MMM d, yyyy').format(ctrl.returnDate), cs),

                      // Selected Add-ons
                      if (ctrl.gpsAddon || ctrl.additionalDriverAddon || ctrl.childSeatAddon) ...[
                        const Divider(height: 24),
                        Text(
                          'SELECTED ADD-ONS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (ctrl.gpsAddon)
                          _buildSummaryRow('GPS Navigation', '+${currencyService.formatPrice(5000.0 * ctrl.totalDays)}', cs, isAddon: true),
                        if (ctrl.additionalDriverAddon)
                          _buildSummaryRow('Additional Driver', '+${currencyService.formatPrice(8000.0 * ctrl.totalDays)}', cs, isAddon: true),
                        if (ctrl.childSeatAddon)
                          _buildSummaryRow('Child Seat', '+${currencyService.formatPrice(4000.0 * ctrl.totalDays)}', cs, isAddon: true),
                      ],

                      // Promo Code Card
                      const Divider(height: 24),
                      Text(
                        'PROMO CODE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrl.promoCodeController,
                              decoration: InputDecoration(
                                hintText: 'Enter promo code',
                                isDense: true,
                                filled: true,
                                fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: ctrl.applyPromoCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Obx(() => ctrl.appliedPromoCode.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Code ${ctrl.appliedPromoCode.value} applied successfully! Discount: -${currencyService.formatPrice(ctrl.discountAmount.value)}',
                                style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          : const SizedBox.shrink()),

                      const Divider(height: 24),

                      // Total Amount Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50.withValues(alpha: isLight ? 1.0 : 0.05),
                          border: Border.all(color: Colors.orange.shade200, width: 1.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total Amount',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Obx(() => Text(

                                      currencyService.formatPrice(ctrl.totalAmount),
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: cs.primary,
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Includes all selected services & fees',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secure Checkout badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Secure checkout - No hidden fees',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget buildFormFields() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Header
                  Text(
                    'Your Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Inputs Layout
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 2 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWide ? 2.5 : 4.5,
                    children: [
                      // Full name input
                      _buildFormInput(
                        label: 'FULL NAME *',
                        controller: ctrl.fullNameController,
                        hint: 'Your full name',
                        cs: cs,
                        theme: theme,
                      ),
                      // Email input
                      _buildFormInput(
                        label: 'EMAIL *',
                        controller: ctrl.emailController,
                        hint: 'Your email address',
                        cs: cs,
                        theme: theme,
                      ),
                      // Phone input
                      _buildFormInput(
                        label: 'PHONE NUMBER *',
                        controller: ctrl.phoneController,
                        hint: 'Enter your phone number',
                        cs: cs,
                        theme: theme,
                      ),
                      // Driver's License file selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'DRIVER LICENSE *',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: ctrl.chooseLicenseFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Choose file', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() {
                                    final path = ctrl.selectedLicensePath.value;
                                    final displayPath = path.isEmpty
                                        ? 'No file chosen'
                                        : path.split('/').last.split('\\').last;
                                    return Text(
                                      displayPath,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: path.isEmpty ? FontWeight.normal : FontWeight.bold,
                                        color: path.isEmpty ? cs.onSurfaceVariant.withValues(alpha: 0.7) : cs.onSurface,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Flight number
                  _buildFormInput(
                    label: 'FLIGHT NUMBER (optional)',
                    controller: ctrl.flightNumberController,
                    hint: 'Enter your flight number',
                    cs: cs,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Special Requests
                  Text(
                    'SPECIAL REQUESTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ctrl.specialRequestsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Child seat, airport terminal, or any other requests...',
                      filled: true,
                      fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Payment method selector
                  Text(
                    'PAYMENT METHOD',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 1.6 : 3.2,
                    children: [
                      _buildPaymentRadio(
                        value: 'Stripe',
                        title: 'Stripe',
                        subtitle: 'Credit / Debit Card',
                        logoWidget: _buildStripeLogo(),
                        ctrl: ctrl,
                        theme: theme,
                        cs: cs,
                      ),
                      _buildPaymentRadio(
                        value: 'PayPal',
                        title: 'PayPal',
                        subtitle: 'PayPal account',
                        logoWidget: _buildPayPalLogo(),
                        ctrl: ctrl,
                        theme: theme,
                        cs: cs,
                      ),
                      _buildPaymentRadio(
                        value: 'Flutterwave',
                        title: 'Flutterwave',
                        subtitle: 'Card, bank, or USSD',
                        logoWidget: _buildFlutterwaveLogo(),
                        ctrl: ctrl,
                        theme: theme,
                        cs: cs,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Confirm & Pay button
                  Obx(() => FilledButton(
                        onPressed: ctrl.canPay && !ctrl.isLoading.value ? ctrl.confirmAndPay : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: ctrl.isLoading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                              )
                            : const Text(
                                'Confirm & Pay',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )),
                  const SizedBox(height: 24),
                ],
              );
            }

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: fields
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: buildFormFields(),
                    ),
                  ),
                  // Right: Booking Summary
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                      child: buildBookingSummaryCard(),
                    ),
                  ),
                ],
              );
            }

            // Mobile: Summary on top, form fields on bottom
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildBookingSummaryCard(),
                  const SizedBox(height: 24),
                  buildFormFields(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helper to build summary row ────────────────────────────────
  Widget _buildSummaryRow(String title, String value, ColorScheme cs, {bool isAddon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isAddon ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Helper to build form inputs ────────────────────────────────
  Widget _buildFormInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    final isLight = theme.brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Payment Card Radio widget ──────────────────────────────────
  Widget _buildPaymentRadio({
    required String value,
    required String title,
    required String subtitle,
    required Widget logoWidget,
    required CheckoutController ctrl,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      final isSelected = ctrl.selectedPaymentMethod.value == value;
      return InkWell(
        onTap: () => ctrl.selectedPaymentMethod.value = value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // radio checkmark
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
              logoWidget,
            ],
          ),
        ),
      );
    });
  }

  // ── Representational Logos ─────────────────────────────────────
  Widget _buildStripeLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/pictures/stripe.png',
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF635BFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontFamily: 'serif',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayPalLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/pictures/paypal.png',
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                color: Color(0xFF003087),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlutterwaveLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/pictures/flutterwave.png',
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Icon(Icons.waves_rounded, color: Colors.orange, size: 24),
          ),
        ),
      ),
    );
  }
}
