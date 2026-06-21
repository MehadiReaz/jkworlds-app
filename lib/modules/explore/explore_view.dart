import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'explore_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Local controller-like states for UI expansion
    final isFiltersExpanded = false.obs;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore Vehicles'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Search Panel (Top Section) ──────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        bottom: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Search Options',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedAlignment: Alignment.topLeft,
                      children: [
                        // Pick-up Location Input
                        TextField(
                          controller: ctrl.pickupLocationCtrl,
                          onChanged: (val) {
                            ctrl.pickupLocation.value = val;
                            ctrl.applyFilters();
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on_rounded, color: cs.primary),
                            labelText: 'Pick-up Location',
                            hintText: 'Enter city or neighborhood',
                            filled: true,
                            fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            suffixIcon: Obx(() => ctrl.isLoadingPickup.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                          ),
                        ),
                        Obx(() {
                          if (ctrl.pickupSuggestions.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: ctrl.pickupSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = ctrl.pickupSuggestions[index];
                                return ListTile(
                                  leading: Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
                                  title: Text(
                                    suggestion.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  dense: true,
                                  onTap: () => ctrl.selectPickupSuggestion(suggestion),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Different Drop-off Toggle
                        Obx(() => CheckboxListTile(
                              value: ctrl.isDifferentDropoff.value,
                              onChanged: (val) {
                                ctrl.isDifferentDropoff.value = val ?? false;
                                if (!ctrl.isDifferentDropoff.value) {
                                  ctrl.dropoffLocation.value = '';
                                }
                                ctrl.applyFilters();
                              },
                              title: const Text('Different Drop-off Location?'),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: cs.primary,
                              contentPadding: EdgeInsets.zero,
                            )),

                        // Drop-off Location Input (Conditional)
                        Obx(() => ctrl.isDifferentDropoff.value
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: ctrl.dropoffLocationCtrl,
                                      onChanged: (val) {
                                        ctrl.dropoffLocation.value = val;
                                        ctrl.applyFilters();
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.location_off_rounded, color: cs.primary),
                                        labelText: 'Drop-off Location',
                                        hintText: 'Enter drop-off city',
                                        filled: true,
                                        fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        suffixIcon: Obx(() => ctrl.isLoadingDropoff.value
                                            ? const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              )
                                            : const SizedBox.shrink()),
                                      ),
                                    ),
                                    Obx(() {
                                      if (ctrl.dropoffSuggestions.isEmpty) return const SizedBox.shrink();
                                      return Container(
                                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                                        decoration: BoxDecoration(
                                          color: theme.cardColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: ctrl.dropoffSuggestions.length,
                                          itemBuilder: (context, index) {
                                            final suggestion = ctrl.dropoffSuggestions[index];
                                            return ListTile(
                                              leading: Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
                                              title: Text(
                                                suggestion.description,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              dense: true,
                                              onTap: () => ctrl.selectDropoffSuggestion(suggestion),
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()),

                        // Pick-up and Drop-off Date/Time buttons
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDateTime(context, ctrl.pickupDateTime, ctrl),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('PICK-UP DATE & TIME', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
                                      const SizedBox(height: 4),
                                      Obx(() => Text(
                                            ctrl.pickupDateTime.value == null
                                                ? 'Select Date & Time'
                                                : DateFormat('MMM d, h:mm a').format(ctrl.pickupDateTime.value!),
                                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDateTime(context, ctrl.dropoffDateTime, ctrl),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DROP-OFF DATE & TIME', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
                                      const SizedBox(height: 4),
                                      Obx(() => Text(
                                            ctrl.dropoffDateTime.value == null
                                                ? 'Select Date & Time'
                                                : DateFormat('MMM d, h:mm a').format(ctrl.dropoffDateTime.value!),
                                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Chauffeur availability checkbox
                        Obx(() => CheckboxListTile(
                              value: ctrl.isChauffeurRequired.value,
                              onChanged: (val) {
                                ctrl.isChauffeurRequired.value = val ?? false;
                                ctrl.applyFilters();
                              },
                              title: const Text('Require Chauffeur Service?'),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: cs.primary,
                              contentPadding: EdgeInsets.zero,
                            )),
                      ],
                    ),
                  ),

                  // ── Expandable Filters Panel Button ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => isFiltersExpanded.value = !isFiltersExpanded.value,
                          icon: Obx(() => Icon(
                                isFiltersExpanded.value ? Icons.expand_less_rounded : Icons.tune_rounded,
                                color: cs.primary,
                              )),
                          label: Obx(() => Text(
                                isFiltersExpanded.value ? 'Collapse Filters' : 'Filters & Sorting',
                                style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                              )),
                        ),
                        TextButton(
                          onPressed: ctrl.clearFilters,
                          child: Text('Reset', style: TextStyle(color: cs.error)),
                        ),
                      ],
                    ),
                  ),

                  // ── Expanded Filters Panel ──────────────────────────────────
                  Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isFiltersExpanded.value ? 380 : 0,
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: theme.cardColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Category Select
                                _buildFilterHeader('Category'),
                                _buildChoicesRow(
                                  ctrl.categories,
                                  ctrl.selectedCategory,
                                  ctrl,
                                ),
                                const SizedBox(height: 12),

                                // Service Type Select
                                _buildFilterHeader('Service Type'),
                                _buildChoicesRow(
                                  ctrl.serviceTypes,
                                  ctrl.selectedServiceType,
                                  ctrl,
                                ),
                                const SizedBox(height: 12),

                                // Transmission Select
                                _buildFilterHeader('Transmission'),
                                _buildChoicesRow(
                                  ctrl.transmissions,
                                  ctrl.selectedTransmission,
                                  ctrl,
                                ),
                                const SizedBox(height: 12),

                                // Fuel Type Select
                                _buildFilterHeader('Fuel Type'),
                                _buildChoicesRow(
                                  ctrl.fuelTypes,
                                  ctrl.selectedFuelType,
                                  ctrl,
                                ),
                                const SizedBox(height: 12),

                                // Sort Select
                                _buildFilterHeader('Sort By'),
                                _buildChoicesRow(
                                  ctrl.sortTypes,
                                  ctrl.selectedSortType,
                                  ctrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // ── Vehicles List ───────────────────────────────────────────
            Obx(() {
              final vehicles = ctrl.filteredVehicles;
              if (vehicles.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles match your criteria.',
                          style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vehicle = vehicles[index];
                      return _buildCarCard(context, vehicle, currencyService, theme, cs);
                    },
                    childCount: vehicles.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Helper to select DateTime ──────────────────────────────────
  Future<void> _selectDateTime(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: rxDateTime.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(rxDateTime.value ?? DateTime.now()),
    );
    if (time == null) return;

    rxDateTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ctrl.applyFilters();
  }

  // ── Filter Chips Helper ────────────────────────────────────────
  Widget _buildFilterHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildChoicesRow(List<String> options, RxString activeSelection, ExploreController ctrl) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          return Obx(() {
            final isSelected = activeSelection.value == opt;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    activeSelection.value = opt;
                    ctrl.applyFilters();
                  }
                },
                selectedColor: Get.theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  // ── Car Card UI (Matches Screenshot Custom Design) ─────────────
  Widget _buildCarCard(
    BuildContext context,
    VehicleModel vehicle,
    CurrencyService currencyService,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isLight = theme.brightness == Brightness.light;

    // Cleaned up category text, e.g. "PREMIUM SUV"
    final categoryText = 'PREMIUM ${vehicle.type.toUpperCase()}';

    // Strips parentheses from vehicle names to match autobiography style
    final cleanCarName = '${vehicle.brand} ${vehicle.name}'.replaceAll(RegExp(r'\s*\(.*\)'), '');

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.vehicleDetail, arguments: vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Car Image Top Portion
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 200,
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
                        child: Icon(Icons.directions_car_rounded, size: 60, color: cs.primary),
                      ),
                    )
                  : Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.directions_car_rounded, size: 60, color: cs.primary),
                    ),
            ),
          ),

          // 2. Info Content Portion
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type & Label Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'FROM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Name & Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cleanCarName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (vehicle.hasDiscount) ...[
                          Text(
                            vehicle.totalPriceFormatted.isNotEmpty
                                ? vehicle.totalPriceFormatted
                                : currencyService.formatPrice(vehicle.totalPrice),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vehicle.dailyRateFormatted.isNotEmpty
                                ? vehicle.dailyRateFormatted
                                : currencyService.formatPrice(vehicle.pricePerDay),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ] else ...[
                          Text(
                            vehicle.dailyRateFormatted.isNotEmpty
                                ? vehicle.dailyRateFormatted
                                : currencyService.formatPrice(vehicle.pricePerDay),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ],
                        Text(
                          '/DAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Specs Icon Row
                Row(
                  children: [
                    _buildIconSpec(Icons.people_outline_rounded, '${vehicle.seats} seats', cs),
                    const SizedBox(width: 16),
                    _buildIconSpec(Icons.settings_input_component_rounded, vehicle.transmission, cs),
                    const SizedBox(width: 16),
                    _buildIconSpec(Icons.local_gas_station_rounded, vehicle.fuelType, cs),
                  ],
                ),
                const SizedBox(height: 16),

                // RESERVE NOW Button (Full width orange buttons)
                FilledButton(
                  onPressed: () => Get.toNamed(AppRoutes.vehicleDetail, arguments: vehicle),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary, // Orange color
                    foregroundColor: cs.onPrimary,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'RESERVE NOW',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
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

  Widget _buildIconSpec(IconData icon, String text, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

