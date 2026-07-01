import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'explore_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import 'package:jkworlds/core/constants/app_constants.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore Vehicles'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: ctrl.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBookingFormSection(context, ctrl, theme, cs),
                ],
              ),
            ),

            // ── Vehicles List ───────────────────────────────────────────
            Obx(() {
              if (ctrl.isLoading.value && ctrl.filteredVehicles.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: cs.primary,
                    ),
                  ),
                );
              }

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

            // ── Pagination Loading / End of List Indicator ──────────────
            Obx(() {
              if (ctrl.isLoadMoreLoading.value) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.primary,
                      ),
                    ),
                  ),
                );
              }
              if (!ctrl.hasNextPage.value && ctrl.filteredVehicles.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No more vehicles to display',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }),
          ],
        ),
      ),
    );
  }

  // ── Helper to select DateTime ──────────────────────────────────
  Future<void> _selectDateRange(BuildContext context, ExploreController ctrl, bool isPickupFirst) async {
    final initialRange = ctrl.pickupDateTime.value != null && ctrl.dropoffDateTime.value != null
        ? DateTimeRange(start: ctrl.pickupDateTime.value!, end: ctrl.dropoffDateTime.value!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              secondaryContainer: theme.colorScheme.primary.withValues(alpha: 0.15),
              onSecondaryContainer: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      final pickupCurrent = ctrl.pickupDateTime.value;
      final dropoffCurrent = ctrl.dropoffDateTime.value;

      ctrl.pickupDateTime.value = DateTime(
        pickedRange.start.year,
        pickedRange.start.month,
        pickedRange.start.day,
        pickupCurrent?.hour ?? 9,
        pickupCurrent?.minute ?? 0,
      );

      ctrl.dropoffDateTime.value = DateTime(
        pickedRange.end.year,
        pickedRange.end.month,
        pickedRange.end.day,
        dropoffCurrent?.hour ?? 17,
        dropoffCurrent?.minute ?? 0,
      );

      ctrl.applyFilters();

      if (!context.mounted) return;

      if (isPickupFirst) {
        _showTimeListBottomSheet(context, ctrl.pickupDateTime, ctrl, onConfirm: () {
          if (context.mounted) {
            _showTimeListBottomSheet(context, ctrl.dropoffDateTime, ctrl);
          }
        });
      } else {
        _showTimeListBottomSheet(context, ctrl.dropoffDateTime, ctrl);
      }
    }
  }

  void _showTimeListBottomSheet(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl, {VoidCallback? onConfirm}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    
    final categories = AppConstants.bookingTimeSlots;

    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$displayHour:$minuteStr $period';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 20, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Opening Times: 6:00 AM - 12:00 AM',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              
              // Scrollable list of categories
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.entries.map((entry) {
                      final categoryTitle = entry.key;
                      final times = entry.value;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.8,
                            children: times.map((t) {
                              return Obx(() {
                                final isSelected = rxDateTime.value != null &&
                                    rxDateTime.value!.hour == t.hour &&
                                    rxDateTime.value!.minute == t.minute;
                                
                                return InkWell(
                                  onTap: () {
                                    final current = rxDateTime.value ?? DateTime.now();
                                    rxDateTime.value = DateTime(
                                      current.year,
                                      current.month,
                                      current.day,
                                      t.hour,
                                      t.minute,
                                    );
                                    ctrl.applyFilters();
                                    Get.back(); // Close bottom sheet
                                    if (onConfirm != null) {
                                      onConfirm();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isLight ? const Color(0xFF161A22) : cs.primary)
                                          : (isLight ? Colors.grey.shade100 : const Color(0xFF161A22)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      formatTimeOfDay(t),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                          Text(
                            vehicle.dailyRateFormatted.isNotEmpty
                                ? vehicle.dailyRateFormatted
                                : '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
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

  Widget _buildBookingFormSection(
    BuildContext context,
    ExploreController ctrl,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isLight = theme.brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Obx(() {
        final activeTab = ctrl.selectedBookingTab.value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1C22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tab Selectors ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Cars',
                      isActive: activeTab == 'Cars',
                      onTap: () {
                        ctrl.selectedBookingTab.value = 'Cars';
                        ctrl.selectedServiceType.value = 'All';
                        ctrl.isChauffeurRequired.value = false;
                        ctrl.isDifferentDropoff.value = false;
                        ctrl.dropoffLocation.value = '';
                        ctrl.dropoffLocationCtrl.clear();
                        ctrl.applyFilters();
                      },
                      cs: cs,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Airport Transfer',
                      isActive: activeTab == 'Airport Transfer',
                      onTap: () {
                        ctrl.selectedBookingTab.value = 'Airport Transfer';
                        ctrl.selectedServiceType.value = 'Chauffeur';
                        ctrl.isChauffeurRequired.value = true;
                        ctrl.isDifferentDropoff.value = true;
                        ctrl.dropoffLocation.value = ctrl.dropoffLocationCtrl.text;
                        ctrl.applyFilters();
                      },
                      cs: cs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── COMPACT PICK-UP LOCATION BUTTON WITH FILTER ────────────────────
              _buildInputLabel(
                activeTab == 'Cars' ? 'PICK-UP LOCATION' : 'PICKUP LOCATION',
                cs,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showTripDetailsBottomSheet(context, ctrl),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              activeTab == 'Cars' ? Icons.location_on_rounded : Icons.flight_takeoff_rounded,
                              color: cs.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => Text(
                                    ctrl.pickupLocation.value.isEmpty
                                        ? (activeTab == 'Cars' ? 'Enter pick-up location' : 'Enter pickup location')
                                        : ctrl.pickupLocation.value,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: ctrl.pickupLocation.value.isEmpty
                                          ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                          : cs.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune_rounded, color: cs.primary, size: 20),
                      onPressed: () => _showFiltersBottomSheet(context, ctrl),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      tooltip: 'Filters & Sorting',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInputLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? cs.primary : (Get.isDarkMode ? const Color(0xFF161A22) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : (Get.isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showTripDetailsBottomSheet(
    BuildContext context,
    ExploreController ctrl,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        final sheetHeight = screenHeight * 0.88 - keyboardHeight;
        return Padding(
          padding: EdgeInsets.only(
            bottom: keyboardHeight,
          ),
          child: Container(
            height: sheetHeight.clamp(200.0, screenHeight * 0.88),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER WITH CLOSE BUTTON ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Book Your Ride',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
                
                // ── SCROLLABLE CONTAINER FOR THE FORM ─────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Obx(() {
                      final activeTab = ctrl.selectedBookingTab.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Cars',
                                  isActive: activeTab == 'Cars',
                                  onTap: () {
                                    ctrl.selectedBookingTab.value = 'Cars';
                                  },
                                  cs: cs,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Airport Transfer',
                                  isActive: activeTab == 'Airport Transfer',
                                  onTap: () {
                                    ctrl.selectedBookingTab.value = 'Airport Transfer';
                                  },
                                  cs: cs,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          if (activeTab == 'Cars') ...[
                            // ── CARS FORM ────────────────────────────────
                            _buildInputLabel('PICK-UP LOCATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: ctrl.pickupLocationCtrl,
                              hint: 'Enter pick-up location',
                              icon: Icons.location_on_rounded,
                              onChanged: (val) {
                                ctrl.updatePickupLocation(val);
                              },
                              isLoading: ctrl.isLoadingPickup.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: ctrl.pickupSuggestions,
                              onSelect: (val) => ctrl.selectPickupSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),

                            _buildDateTimeRow(
                              label: 'PICK-UP DATE & TIME',
                              dateTimeRx: ctrl.pickupDateTime,
                              exploreCtrl: ctrl,
                              theme: theme,
                              cs: cs,
                              isLight: isLight,
                              context: context,
                            ),
                            const SizedBox(height: 14),

                            _buildDateTimeRow(
                              label: 'DROP-OFF DATE & TIME',
                              dateTimeRx: ctrl.dropoffDateTime,
                              exploreCtrl: ctrl,
                              theme: theme,
                              cs: cs,
                              isLight: isLight,
                              context: context,
                            ),
                            const SizedBox(height: 24),

                            _buildSubmitButton(
                              title: 'Show Vehicles',
                              onTap: () {
                                Get.back(); // Dismiss bottom sheet
                                ctrl.selectedBookingTab.value = 'Cars';
                                ctrl.selectedServiceType.value = 'All';
                                ctrl.isChauffeurRequired.value = false;
                                ctrl.isDifferentDropoff.value = false;
                                ctrl.dropoffLocation.value = '';
                                ctrl.dropoffLocationCtrl.clear();
                                ctrl.applyFilters();
                              },
                              cs: cs,
                            ),
                          ] else ...[
                            // ── AIRPORT TRANSFER FORM ────────────────────
                            Text(
                              'Ride your way',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildInputLabel('PICKUP LOCATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: ctrl.pickupLocationCtrl,
                              hint: 'Enter pickup location',
                              icon: Icons.flight_takeoff_rounded,
                              onChanged: (val) {
                                ctrl.updatePickupLocation(val);
                              },
                              isLoading: ctrl.isLoadingPickup.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: ctrl.pickupSuggestions,
                              onSelect: (val) => ctrl.selectPickupSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('DESTINATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: ctrl.dropoffLocationCtrl,
                              hint: 'Enter destination',
                              icon: Icons.flight_land_rounded,
                              onChanged: (val) {
                                ctrl.updateDropoffLocation(val);
                              },
                              isLoading: ctrl.isLoadingDropoff.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: ctrl.dropoffSuggestions,
                              onSelect: (val) => ctrl.selectDropoffSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('PICKUP DATE', cs),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectSingleDate(context, ctrl.pickupDateTime, ctrl),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: cs.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Obx(() => Text(
                                          ctrl.pickupDateTime.value == null
                                              ? 'Select date'
                                              : DateFormat('EEEE, MMMM d, yyyy').format(ctrl.pickupDateTime.value!),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: ctrl.pickupDateTime.value == null
                                                ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                                : cs.onSurface,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('PICKUP TIME', cs),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectTime(context, ctrl.pickupDateTime, ctrl),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, color: cs.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Obx(() => Text(
                                          ctrl.pickupDateTime.value == null
                                              ? 'Select time'
                                              : DateFormat('h:mm a').format(ctrl.pickupDateTime.value!),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: ctrl.pickupDateTime.value == null
                                                ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                                : cs.onSurface,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildSubmitButton(
                              title: 'Show Cars',
                              onTap: () {
                                Get.back(); // Dismiss bottom sheet
                                ctrl.selectedBookingTab.value = 'Airport Transfer';
                                ctrl.selectedServiceType.value = 'Chauffeur';
                                ctrl.isChauffeurRequired.value = true;
                                ctrl.isDifferentDropoff.value = true;
                                ctrl.dropoffLocation.value = ctrl.dropoffLocationCtrl.text;
                                ctrl.applyFilters();
                              },
                              cs: cs,
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required bool isLoading,
    required ColorScheme cs,
    required bool isLight,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.primary, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
        filled: true,
        fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const SizedBox.shrink(),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSuggestionsList({
    required List<dynamic> suggestions,
    required ValueChanged<dynamic> onSelect,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      if (suggestions.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: Icon(Icons.location_on_rounded, color: cs.primary, size: 18),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (suggestion.typeLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (suggestion.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              dense: true,
              onTap: () => onSelect(suggestion),
            );
          },
        ),
      );
    });
  }

  Widget _buildDateTimeRow({
    required String label,
    required Rxn<DateTime> dateTimeRx,
    required ExploreController exploreCtrl,
    required ThemeData theme,
    required ColorScheme cs,
    required bool isLight,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label, cs),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDateRange(context, exploreCtrl, label.contains('PICK-UP')),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Obx(() => Text(
                        dateTimeRx.value == null
                            ? 'Select Date'
                            : DateFormat('MMM d, yyyy').format(dateTimeRx.value!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: dateTimeRx.value == null
                              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _showTimeListBottomSheet(context, dateTimeRx, exploreCtrl),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Obx(() => Text(
                        dateTimeRx.value == null
                            ? 'Select Time'
                            : DateFormat('h:mm a').format(dateTimeRx.value!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: dateTimeRx.value == null
                              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String title,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _selectSingleDate(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) async {
    final isPickup = rxDateTime == ctrl.pickupDateTime;
    
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));
    
    if (isPickup) {
      if (ctrl.dropoffDateTime.value != null) {
        final maxSelectable = ctrl.dropoffDateTime.value!.subtract(const Duration(days: 1));
        if (maxSelectable.isAfter(firstDate)) {
          lastDate = maxSelectable;
        } else {
          lastDate = firstDate;
        }
      }
    } else {
      if (ctrl.pickupDateTime.value == null) {
        SnackbarHelper.showWarning('Please select a pick-up date first.');
        return;
      }
      firstDate = ctrl.pickupDateTime.value!.add(const Duration(days: 1));
      if (lastDate.isBefore(firstDate)) {
        lastDate = firstDate.add(const Duration(days: 365));
      }
    }

    final current = rxDateTime.value ?? (isPickup ? DateTime.now() : ctrl.pickupDateTime.value!.add(const Duration(days: 1)));
    
    DateTime initialDate = current;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return;

    rxDateTime.value = DateTime(
      date.year,
      date.month,
      date.day,
      current.hour,
      current.minute,
    );

    if (isPickup) {
      if (ctrl.dropoffDateTime.value != null && !ctrl.dropoffDateTime.value!.isAfter(rxDateTime.value!)) {
        ctrl.dropoffDateTime.value = null;
      }
    }

    ctrl.applyFilters();
  }

  void _selectTime(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) {
    _showTimeListBottomSheet(context, rxDateTime, ctrl);
  }

  void _showFiltersBottomSheet(BuildContext context, ExploreController ctrl) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Filters & Sorting',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ctrl.clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset All',
                        style: TextStyle(
                          color: cs.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category
                      _buildFilterHeader('Category'),
                      _buildChoicesRow(
                        ctrl.categories,
                        ctrl.selectedCategory,
                        ctrl,
                      ),
                      const SizedBox(height: 16),

                      // Service Type
                      _buildFilterHeader('Service Type'),
                      _buildChoicesRow(
                        ctrl.serviceTypes,
                        ctrl.selectedServiceType,
                        ctrl,
                      ),
                      const SizedBox(height: 16),

                      // Transmission
                      _buildFilterHeader('Transmission'),
                      _buildChoicesRow(
                        ctrl.transmissions,
                        ctrl.selectedTransmission,
                        ctrl,
                      ),
                      const SizedBox(height: 16),

                      // Fuel Type
                      _buildFilterHeader('Fuel Type'),
                      _buildChoicesRow(
                        ctrl.fuelTypes,
                        ctrl.selectedFuelType,
                        ctrl,
                      ),
                      const SizedBox(height: 16),

                      // Sort By
                      _buildFilterHeader('Sort By'),
                      _buildChoicesRow(
                        ctrl.sortTypes,
                        ctrl.selectedSortType,
                        ctrl,
                      ),
                      const SizedBox(height: 24),

                      // Apply Button
                      FilledButton(
                        onPressed: () {
                          ctrl.applyFilters();
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

