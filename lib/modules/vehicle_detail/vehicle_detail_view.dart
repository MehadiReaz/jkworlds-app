import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'vehicle_detail_controller.dart';

class VehicleDetailView extends StatelessWidget {
  const VehicleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VehicleDetailController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final List<String> timeOptions = [
      '00:00', '00:30', '01:00', '01:30', '02:00', '02:30', '03:00', '03:30',
      '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30',
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
    ];

    String formatTimeString(String val) {
      if (val.isEmpty) return 'Select Time';
      final parts = val.split(':');
      if (parts.length < 2) return val;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayHourStr = displayHour.toString().padLeft(2, '0');
      final displayMinuteStr = minute.toString().padLeft(2, '0');
      return '$displayHourStr:$displayMinuteStr $period';
    }

    final VehicleModel vehicle = ctrl.vehicle;
    final cleanCarName = '${vehicle.brand} ${vehicle.name}'.replaceAll(RegExp(r'\s*\(.*\)'), '');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(cleanCarName),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  ctrl.isWishlisted.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: ctrl.isWishlisted.value ? Colors.red : cs.onSurface,
                ),
                onPressed: ctrl.toggleWishlist,
              )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Car Image Top Portion
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: vehicle.images.isNotEmpty
                      ? Image.network(
                          vehicle.images[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.directions_car_rounded, size: 80, color: cs.primary),
                          ),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.directions_car_rounded, size: 80, color: cs.primary),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Info Row (Brand, Name, Rating)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.brand.toUpperCase()} • ${vehicle.name.toUpperCase()} • ${vehicle.year}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cleanCarName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: index < vehicle.rating.floor() ? Colors.amber : Colors.grey.shade300,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.reviewCount} verified reviews',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Specifications Grid (Seats, Transmission, Fuel, Location)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.45,
                children: [
                  _buildSpecCard(
                    context: context,
                    icon: Icons.people_alt_outlined,
                    label: 'SEATS',
                    value: '${vehicle.seats}',
                    cs: cs,
                    theme: theme,
                  ),
                  _buildSpecCard(
                    context: context,
                    icon: Icons.settings_input_component_rounded,
                    label: 'TRANSMISSION',
                    value: vehicle.transmission == 'Automatic' ? 'Auto' : 'Manual',
                    cs: cs,
                    theme: theme,
                  ),
                  _buildSpecCard(
                    context: context,
                    icon: Icons.local_gas_station_outlined,
                    label: 'FUEL',
                    value: vehicle.fuelType,
                    cs: cs,
                    theme: theme,
                  ),
                  _buildSpecCard(
                    context: context,
                    icon: Icons.location_on_outlined,
                    label: 'LOCATION',
                    value: vehicle.location.split(',')[0],
                    cs: cs,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 4. Features Checklist
              Text(
                'Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: vehicle.features.map((feature) {
                  return IntrinsicWidth(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded, size: 12, color: cs.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Plate & Mileage Card
              Row(
                children: [
                  Icon(Icons.directions_car_filled_outlined, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Plate: ',
                    style: TextStyle(fontWeight: FontWeight.normal, color: cs.onSurfaceVariant),
                  ),
                  const Text(
                    'LG-890-IKJ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                  Icon(Icons.speed_rounded, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Mileage: ',
                    style: TextStyle(fontWeight: FontWeight.normal, color: cs.onSurfaceVariant),
                  ),
                  const Text(
                    '9,500 km',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 5. About this vehicle
              Text(
                'About this vehicle',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                vehicle.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // 6. Policy Cards
              _buildPolicyCard(
                context: context,
                icon: Icons.timer_outlined,
                title: 'Mileage Policy',
                points: [
                  'Unlimited mileage included',
                  'No extra distance charges',
                  'Travel anywhere within Nigeria'
                ],
                cs: cs,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPolicyCard(
                context: context,
                icon: Icons.assignment_outlined,
                title: 'Rental Requirements',
                points: [
                  'Valid Driver License',
                  'Minimum Driver Age 25+',
                  'Government Issued ID',
                  'Refundable Security Deposit'
                ],
                cs: cs,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPolicyCard(
                context: context,
                icon: Icons.shield_outlined,
                title: "What's Included",
                points: [
                  'Basic Insurance',
                  '24/7 Support',
                  'Roadside Assistance',
                  'Sanitized Vehicle',
                  'Free Cancellation',
                  'Vehicle Inspection'
                ],
                cs: cs,
                theme: theme,
              ),
              const SizedBox(height: 28),

              // 7. Security Deposit Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withValues(alpha: isLight ? 1.0 : 0.05),
                  border: Border.all(color: Colors.amber.shade300, width: 1.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100.withValues(alpha: isLight ? 1.0 : 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refundable Security Deposit',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₦${NumberFormat('#,###').format(ctrl.securityDeposit)} deposit is authorized at pickup and fully released after vehicle inspection upon return.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.amber.shade900 : Colors.amber.shade200,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Free Cancellation Alert Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withValues(alpha: isLight ? 1.0 : 0.05),
                  border: Border.all(color: Colors.green.shade300, width: 1.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100.withValues(alpha: isLight ? 1.0 : 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Cancellation',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cancel up to 24 hours before pickup for a full refund — no questions asked.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.green.shade900 : Colors.green.shade200,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 8. Customer Reviews Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Reviews',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  Obx(() => Text(
                        '${ctrl.reviews.length} reviews',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                final reviews = ctrl.reviews;
                if (reviews.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No reviews yet for this vehicle.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, idx) {
                    final r = reviews[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.userName,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: starIdx < r.rating.floor() ? Colors.amber : Colors.grey.shade300,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vehicle.brand} ${vehicle.name} • ${DateFormat('yyyy-MM-dd').format(r.date)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r.comment,
                            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 36),

              // 9. Booking configurator (Requested Reservation Layout)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Price / day Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyService.formatPrice(vehicle.pricePerDay),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              '/day',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Self-Drive vs Chauffeur toggler
                        Obx(() => ChoiceChip(
                              label: Text(ctrl.isSelfDrive.value ? 'Self-Drive' : 'Chauffeur'),
                              selected: true,
                              onSelected: (_) => ctrl.toggleDriveMode(),
                              selectedColor: cs.primary.withValues(alpha: 0.1),
                              labelStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pickup & Return inputs side-by-side
                    Row(
                      children: [
                        // Pickup Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'PICKUP',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => ctrl.selectPickupDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Obx(() => Text(
                                        ctrl.pickupDate.value == null
                                            ? 'Select date'
                                            : DateFormat('MMM d, yyyy').format(ctrl.pickupDate.value!),
                                        style: TextStyle(
                                          fontWeight: ctrl.pickupDate.value == null ? FontWeight.normal : FontWeight.bold,
                                          color: ctrl.pickupDate.value == null ? cs.onSurfaceVariant.withValues(alpha: 0.7) : cs.onSurface,
                                        ),
                                      )),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: ctrl.pickupTime.value.isEmpty ? null : ctrl.pickupTime.value,
                                        hint: Text('Select Time', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
                                        isExpanded: true,
                                        items: timeOptions.map((time) {
                                          return DropdownMenuItem<String>(
                                            value: time,
                                            child: Text(formatTimeString(time), style: const TextStyle(fontSize: 14)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) ctrl.pickupTime.value = val;
                                        },
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Return Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'RETURN',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => ctrl.selectReturnDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Obx(() => Text(
                                        ctrl.returnDate.value == null
                                            ? 'Select date'
                                            : DateFormat('MMM d, yyyy').format(ctrl.returnDate.value!),
                                        style: TextStyle(
                                          fontWeight: ctrl.returnDate.value == null ? FontWeight.normal : FontWeight.bold,
                                          color: ctrl.returnDate.value == null ? cs.onSurfaceVariant.withValues(alpha: 0.7) : cs.onSurface,
                                        ),
                                      )),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: ctrl.returnTime.value.isEmpty ? null : ctrl.returnTime.value,
                                        hint: Text('Select Time', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
                                        isExpanded: true,
                                        items: timeOptions.map((time) {
                                          return DropdownMenuItem<String>(
                                            value: time,
                                            child: Text(formatTimeString(time), style: const TextStyle(fontSize: 14)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) ctrl.returnTime.value = val;
                                        },
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Protection Plans
                    Text(
                      'Protection Plans',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        _buildProtectionRadio(
                          value: 'Basic',
                          title: 'Basic Protection',
                          desc: 'Third-party liability coverage',
                          badge: 'Included',
                          ctrl: ctrl,
                          theme: theme,
                          cs: cs,
                        ),
                        const SizedBox(height: 8),
                        _buildProtectionRadio(
                          value: 'Premium',
                          title: 'Premium Protection',
                          desc: 'Collision damage waiver',
                          badge: '+15%',
                          ctrl: ctrl,
                          theme: theme,
                          cs: cs,
                        ),
                        const SizedBox(height: 8),
                        _buildProtectionRadio(
                          value: 'Full',
                          title: 'Full Coverage',
                          desc: 'Zero excess & full protection',
                          badge: '+25%',
                          ctrl: ctrl,
                          theme: theme,
                          cs: cs,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Rental Add-ons
                    Text(
                      'Rental Add-ons',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        _buildAddonCheckbox(
                          labelRx: ctrl.gpsAddon,
                          title: 'GPS Navigation',
                          desc: 'Turn-by-turn navigation',
                          price: '+₦5,000 /day',
                          theme: theme,
                          cs: cs,
                        ),
                        const SizedBox(height: 8),
                        _buildAddonCheckbox(
                          labelRx: ctrl.additionalDriverAddon,
                          title: 'Additional Driver',
                          desc: 'Add another licensed driver',
                          price: '+₦8,000 /day',
                          theme: theme,
                          cs: cs,
                        ),
                        const SizedBox(height: 8),
                        _buildAddonCheckbox(
                          labelRx: ctrl.childSeatAddon,
                          title: 'Child Seat',
                          desc: 'Safety seat for children',
                          price: '+₦4,000 /day',
                          theme: theme,
                          cs: cs,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Interactive Calculations / Breakdown
                    Obx(() {
                      final days = ctrl.totalDays;
                      if (days == 0) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Select pickup & return dates to see price breakdown.',
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildBreakdownRow('Rental Rate', '${currencyService.formatPrice(vehicle.pricePerDay)} x $days days', currencyService.formatPrice(ctrl.subtotal), cs),
                            if (ctrl.selectedProtection.value != 'Basic')
                              _buildBreakdownRow(
                                '${ctrl.selectedProtection.value} Protection',
                                ctrl.selectedProtection.value == 'Premium' ? '+15%' : '+25%',
                                currencyService.formatPrice(ctrl.protectionCost),
                                cs,
                              ),
                            if (ctrl.addonsCost > 0)
                              _buildBreakdownRow('Add-ons', 'GPS/Driver/Seat config', currencyService.formatPrice(ctrl.addonsCost), cs),
                            _buildBreakdownRow('Service Fee', '5%', currencyService.formatPrice(ctrl.serviceFee), cs),
                            _buildBreakdownRow('Security Deposit', 'Refundable', currencyService.formatPrice(ctrl.securityDeposit), cs),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Price', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                Text(
                                  currencyService.formatPrice(ctrl.total),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Reserve Now Action Button
                    Obx(() => FilledButton(
                          onPressed: ctrl.canBook && !ctrl.isLoading.value ? ctrl.confirmBooking : null,
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
                                  'Reserve Now',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Spec Card Widget Generator ─────────────────────────────────
  Widget _buildSpecCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    final isLight = theme.brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ── Policy Card Widget Generator ───────────────────────────────
  Widget _buildPolicyCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<String> points,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: cs.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: points.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Protection Radio Generator ──────────────────────────────────
  Widget _buildProtectionRadio({
    required String value,
    required String title,
    required String desc,
    required String badge,
    required VehicleDetailController ctrl,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      final isSelected = ctrl.selectedProtection.value == value;
      return InkWell(
        onTap: () => ctrl.selectedProtection.value = value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              // Custom radio circle
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
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Addon Checkbox Generator ────────────────────────────────────
  Widget _buildAddonCheckbox({
    required RxBool labelRx,
    required String title,
    required String desc,
    required String price,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      final isChecked = labelRx.value;
      return InkWell(
        onTap: () => labelRx.toggle(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isChecked ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
            border: Border.all(
              color: isChecked ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
              width: isChecked ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    price,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Custom checkbox
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isChecked ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: isChecked ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isChecked
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Price Breakdown Row Generator ──────────────────────────────
  Widget _buildBreakdownRow(String title, String subtitle, String price, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11)),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
