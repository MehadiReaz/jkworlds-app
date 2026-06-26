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
      backgroundColor: isLight ? Colors.white : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            Widget buildBookingSummaryCard() {
              Widget buildTotalAmountCard() {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isLight ? const Color(0xFFFFD4C1) : const Color(0xFF4C2A1E),
                      width: 1.2,
                    ),
                  ),
                  color: isLight ? const Color(0xFFFFF2EC) : const Color(0xFF2C1E1A),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Total Amount',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Obx(() => Text(
                                ctrl.calculatedPayableTotalFormatted.value.isNotEmpty
                                    ? ctrl.calculatedPayableTotalFormatted.value
                                    : '0.00',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFF5403),
                                    fontSize: 24,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Includes all selected services & fees',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget buildPromoCodeCard() {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  color: isLight ? const Color(0xFFF2F4F7) : const Color(0xFF1E293B),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'PROMO CODE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: TextField(
                                  controller: ctrl.promoCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter promo code',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    filled: true,
                                    fillColor: isLight ? Colors.white : const Color(0xFF1E293B),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: ctrl.applyPromoCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5403),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        Obx(() => ctrl.appliedPromoCode.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Code ${ctrl.appliedPromoCode.value} applied successfully! Discount: -${ctrl.calculatedDiscountFormatted.value.isNotEmpty ? ctrl.calculatedDiscountFormatted.value : currencyService.formatPrice(ctrl.calculatedDiscount.value)}',
                                  style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                );
              }

              Widget buildDetailsCard() {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  color: isLight ? const Color(0xFFF2F4F7) : const Color(0xFF1E293B),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'BOOKING SUMMARY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                height: 54,
                                color: isLight ? Colors.white : const Color(0xFF0F172A),
                                child: ctrl.vehicle.images.isNotEmpty
                                    ? Image.network(
                                        ctrl.vehicle.images[0],
                                        fit: BoxFit.contain,
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
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
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
                        Obx(() {
                          final dailyRateText = ctrl.vehicle.dailyRateFormatted.isNotEmpty
                              ? ctrl.vehicle.dailyRateFormatted
                              : currencyService.formatPrice(ctrl.vehicle.pricePerDay);
                          return _buildSummaryRow(
                            'Base (${ctrl.base}d x $dailyRateText)',
                            ctrl.calculatedSubtotalFormatted.value.isNotEmpty
                                ? ctrl.calculatedSubtotalFormatted.value
                                : currencyService.formatPrice(ctrl.calculatedSubtotal.value),
                            cs,
                          );
                        }),
                        Obx(() => _buildSummaryRow(
                              'Insurance',
                              ctrl.calculatedProtectionTitle.value.isNotEmpty
                                  ? ctrl.calculatedProtectionTitle.value
                                  : ctrl.selectedProtection,
                              cs,
                            )),
                        Obx(() => _buildSummaryRow(
                              'Protection Amount',
                              ctrl.calculatedProtectionFormatted.value.isNotEmpty
                                  ? ctrl.calculatedProtectionFormatted.value
                                  : currencyService.formatPrice(ctrl.calculatedProtectionCost.value),
                              cs,
                            )),
                        _buildSummaryRow('Service Type', ctrl.isSelfDrive ? 'Self Drive' : 'Chauffeur', cs),
                        _buildSummaryRow('Pickup', ctrl.resolvedPickupAddress, cs),
                        _buildSummaryRow(
                          'Pickup Date',
                          '${DateFormat('MMM d yyyy').format(ctrl.pickupDate)}, ${ctrl.pickupTime}',
                          cs,
                        ),
                        _buildSummaryRow(
                          'Return Date',
                          '${DateFormat('MMM d yyyy').format(ctrl.returnDate)}, ${ctrl.returnTime}',
                          cs,
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget buildSelectedAddonsCard() {
                return Obx(() {
                  final hasCalculatedAddons = ctrl.calculatedAddons.isNotEmpty;
                  final hasLocalAddons = ctrl.gpsAddon || ctrl.additionalDriverAddon || ctrl.childSeatAddon || ctrl.prepaidFuelAddon;

                  if (!hasCalculatedAddons && !hasLocalAddons) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    color: isLight ? const Color(0xFFF2F4F7) : const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'SELECTED ADD-ONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (hasCalculatedAddons)
                            ...ctrl.calculatedAddons.map((addon) {
                              return _buildSummaryRow(
                                addon['title']?.toString() ?? '',
                                '+${addon['amount_formatted']?.toString() ?? currencyService.formatPrice(double.tryParse(addon['amount']?.toString() ?? '') ?? 0.0)}',
                                cs,
                                isAddon: true,
                              );
                            })
                          else ...[
                            if (ctrl.gpsAddon)
                              _buildSummaryRow('GPS Navigation', '+${currencyService.formatPrice(ctrl.gpsAddonPrice)}', cs, isAddon: true),
                            if (ctrl.additionalDriverAddon)
                              _buildSummaryRow('Additional Driver', '+${currencyService.formatPrice(ctrl.additionalDriverAddonPrice)}', cs, isAddon: true),
                            if (ctrl.childSeatAddon)
                              _buildSummaryRow('Child Seat', '+${currencyService.formatPrice(ctrl.childSeatAddonPrice)}', cs, isAddon: true),
                            if (ctrl.prepaidFuelAddon)
                              _buildSummaryRow('Prepaid Fuel', '+${currencyService.formatPrice(ctrl.prepaidFuelAddonPrice)}', cs, isAddon: true),
                          ],
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Add-ons Total',
                            ctrl.calculatedAddonsFormatted.value.isNotEmpty
                                ? ctrl.calculatedAddonsFormatted.value
                                : currencyService.formatPrice(ctrl.calculatedAddonsCost.value),
                            cs,
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }

              Widget buildTaxesAndFeesCard() {
                return Obx(() {
                  final hasCalculatedFees = ctrl.calculatedFees.isNotEmpty;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    color: isLight ? const Color(0xFFF2F4F7) : const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'TAXES & FEES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (hasCalculatedFees)
                            ...ctrl.calculatedFees.map((fee) {
                              return _buildSummaryRow(
                                fee['title']?.toString() ?? '',
                                '+${fee['amount_formatted']?.toString() ?? currencyService.formatPrice(double.tryParse(fee['amount']?.toString() ?? '') ?? 0.0)}',
                                cs,
                                isAddon: true,
                              );
                            })
                          else ...[
                            _buildSummaryRow(
                              'VAT',
                              '+${ctrl.calculatedServiceFeeFormatted.value.isNotEmpty ? ctrl.calculatedServiceFeeFormatted.value : currencyService.formatPrice(ctrl.calculatedServiceFee.value)}',
                              cs,
                              isAddon: true,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Taxes & Fees Total',
                            ctrl.calculatedServiceFeeFormatted.value.isNotEmpty
                                ? ctrl.calculatedServiceFeeFormatted.value
                                : currencyService.formatPrice(ctrl.calculatedServiceFee.value),
                              cs,
                              isBoldValue: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTotalAmountCard(),
                  const SizedBox(height: 12),
                  buildPromoCodeCard(),
                  const SizedBox(height: 12),
                  buildDetailsCard(),
                  const SizedBox(height: 12),
                  buildSelectedAddonsCard(),
                  const SizedBox(height: 12),
                  buildTaxesAndFeesCard(),
                  const SizedBox(height: 12),
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
                  if (isWide) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildFormInput(
                            label: 'FULL NAME *',
                            controller: ctrl.fullNameController,
                            hint: 'Your full name',
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormInput(
                            label: 'EMAIL *',
                            controller: ctrl.emailController,
                            hint: 'Your email address',
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildFormInput(
                            label: 'PHONE NUMBER *',
                            controller: ctrl.phoneController,
                            hint: 'Enter your phone number',
                            cs: cs,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ctrl.isSelfDrive
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'DRIVER LICENSE *',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                          letterSpacing: 0.5),
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
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildFormInput(
                      label: 'FULL NAME *',
                      controller: ctrl.fullNameController,
                      hint: 'Your full name',
                      cs: cs,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildFormInput(
                      label: 'EMAIL *',
                      controller: ctrl.emailController,
                      hint: 'Your email address',
                      cs: cs,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildFormInput(
                      label: 'PHONE NUMBER *',
                      controller: ctrl.phoneController,
                      hint: 'Enter your phone number',
                      cs: cs,
                      theme: theme,
                    ),
                    if (ctrl.isSelfDrive) ...[
                      const SizedBox(height: 16),
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
                                letterSpacing: 0.5),
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
                  ],
                  const SizedBox(height: 16),

                  // Flight number
                  if (!ctrl.isSelfDrive) ...[
                    _buildFormInput(
                      label: 'FLIGHT NUMBER (optional)',
                      controller: ctrl.flightNumberController,
                      hint: 'Enter your flight number',
                      cs: cs,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                  ],

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
                  
                  // Dynamic Payment Gateways from API
                  Obx(() => ctrl.paymentMethods.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              'No payment methods available for the selected currency.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 3 : 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: isWide ? 1.6 : 3.2,
                          ),
                          itemCount: ctrl.paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = ctrl.paymentMethods[index];
                            final key = method['key']?.toString() ?? 'stripe';
                            final label = method['label']?.toString() ?? 'Stripe';
                            final subtitle = method['subtitle']?.toString() ?? '';
                            final enabled = method['enabled'] as bool? ?? true;

                            return IgnorePointer(
                              ignoring: !enabled,
                              child: Opacity(
                                opacity: enabled ? 1.0 : 0.5,
                                child: _buildPaymentRadio(
                                  value: key,
                                  title: label,
                                  subtitle: subtitle,
                                  logoWidget: _buildGatewayLogo(key),
                                  ctrl: ctrl,
                                  theme: theme,
                                  cs: cs,
                                ),
                              ),
                            );
                          },
                        )),
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

  Widget _buildSummaryRow(
    String title,
    String value,
    ColorScheme cs, {
    bool isAddon = false,
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: (isAddon || isBoldValue) ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

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
      final isSelected = ctrl.selectedPaymentMethod.value.toLowerCase() == value.toLowerCase();
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

  Widget _buildGatewayLogo(String key) {
    switch (key.toLowerCase()) {
      case 'stripe':
        return _buildStripeLogo();
      case 'paypal':
        return _buildPayPalLogo();
      case 'flutterwave':
      default:
        return _buildFlutterwaveLogo();
    }
  }

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
                color: const Color(0xFF003087),
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
