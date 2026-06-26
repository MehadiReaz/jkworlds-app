import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/services/category_service.dart';
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
                  _buildTripSummaryCard(context, ctrl, theme, cs),
                  _buildQuickCategorySelector(ctrl, theme, cs),
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
    
    final categories = {
      'Early Morning': [
        const TimeOfDay(hour: 6, minute: 0),
        const TimeOfDay(hour: 6, minute: 30),
        const TimeOfDay(hour: 7, minute: 0),
        const TimeOfDay(hour: 7, minute: 30),
      ],
      'Morning - afternoon': [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 8, minute: 30),
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 9, minute: 30),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 10, minute: 30),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 11, minute: 30),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 12, minute: 30),
        const TimeOfDay(hour: 13, minute: 0),
        const TimeOfDay(hour: 13, minute: 30),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 14, minute: 30),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 15, minute: 30),
        const TimeOfDay(hour: 16, minute: 0),
        const TimeOfDay(hour: 16, minute: 30),
      ],
      'Evening - Night': [
        const TimeOfDay(hour: 17, minute: 0),
        const TimeOfDay(hour: 17, minute: 30),
        const TimeOfDay(hour: 18, minute: 0),
        const TimeOfDay(hour: 18, minute: 30),
        const TimeOfDay(hour: 19, minute: 0),
        const TimeOfDay(hour: 19, minute: 30),
        const TimeOfDay(hour: 20, minute: 0),
        const TimeOfDay(hour: 20, minute: 30),
        const TimeOfDay(hour: 21, minute: 0),
        const TimeOfDay(hour: 21, minute: 30),
        const TimeOfDay(hour: 22, minute: 0),
        const TimeOfDay(hour: 22, minute: 30),
        const TimeOfDay(hour: 23, minute: 0),
        const TimeOfDay(hour: 23, minute: 30),
        const TimeOfDay(hour: 0, minute: 0),
      ],
    };

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
                                : currencyService.formatPrice(vehicle.pricePerDay),
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

  Widget _buildTripSummaryCard(
    BuildContext context,
    ExploreController ctrl,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.light ? 0.04 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Search Icon
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.search_rounded, color: cs.primary, size: 24),
              ),
              // Search Summary Info
              Expanded(
                child: InkWell(
                  onTap: () => _showTripDetailsBottomSheet(context, ctrl),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          String locText = ctrl.pickupLocation.value.isNotEmpty
                              ? ctrl.pickupLocation.value
                              : 'Select Location';
                          if (ctrl.isDifferentDropoff.value && ctrl.dropoffLocation.value.isNotEmpty) {
                            locText = '${ctrl.pickupLocation.value} ➔ ${ctrl.dropoffLocation.value}';
                          }
                          return Text(
                            locText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                        const SizedBox(height: 2),
                        Obx(() {
                          String dateText = 'Select Dates';
                          if (ctrl.pickupDateTime.value != null && ctrl.dropoffDateTime.value != null) {
                            final start = ctrl.pickupDateTime.value!;
                            final end = ctrl.dropoffDateTime.value!;
                            final startStr = DateFormat('MMM d, h:mm a').format(start);
                            final endStr = DateFormat('MMM d, h:mm a').format(end);
                            dateText = '$startStr - $endStr';
                          }
                          return Text(
                            dateText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              // Vertical Divider
              VerticalDivider(
                width: 1,
                indent: 12,
                endIndent: 12,
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
              // Tune/Filter Button
              IconButton(
                icon: Icon(Icons.tune_rounded, color: cs.primary, size: 22),
                onPressed: () => _showFiltersBottomSheet(context, ctrl),
                tooltip: 'Filters & Sorting',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategorySelector(
    ExploreController ctrl,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final Map<String, IconData> categoryIcons = {
      'All': Icons.grid_view_rounded,
      'Sedan': Icons.directions_car_rounded,
      'SUV': Icons.airport_shuttle_rounded,
      'Luxury': Icons.stars_rounded,
      'Van': Icons.directions_bus_rounded,
    };

    final isLight = theme.brightness == Brightness.light;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ctrl.categories.length,
        itemBuilder: (context, index) {
          final cat = ctrl.categories[index];
          final icon = categoryIcons[cat] ?? Icons.directions_car_rounded;
          final catModel = Get.find<CategoryService>().categories.firstWhereOrNull((c) => c.name.toLowerCase() == cat.toLowerCase());
          final imageUrl = catModel?.image;

          return Obx(() {
            final isSelected = ctrl.selectedCategory.value == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  ctrl.selectedCategory.value = cat;
                  ctrl.applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : (isLight ? Colors.grey.shade100 : const Color(0xFF161A22)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : cs.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                          color: isSelected ? Colors.white : cs.onSurfaceVariant,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            icon,
                            size: 16,
                            color: isSelected ? Colors.white : cs.onSurfaceVariant,
                          ),
                        )
                      else
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.white : cs.onSurfaceVariant,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      )),
    );
  }

  void _showTripDetailsBottomSheet(BuildContext context, ExploreController ctrl) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      'Trip Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
                      // Pick-up Location Input
                      TextField(
                        controller: ctrl.pickupLocationCtrl,
                        onChanged: (val) {
                          ctrl.updatePickupLocation(val);
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
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                dense: true,
                                onTap: () => ctrl.selectPickupSuggestion(suggestion),
                              );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Different Drop-off Toggle (Only visible for Chauffeur/Airport Transfer)
                      Obx(() {
                        final isChauffeur = ctrl.selectedServiceType.value == 'Chauffeur' || ctrl.isChauffeurRequired.value;
                        if (!isChauffeur) {
                          return const SizedBox.shrink();
                        }
                        return SwitchListTile.adaptive(
                          value: ctrl.isDifferentDropoff.value,
                          onChanged: (val) {
                            ctrl.isDifferentDropoff.value = val;
                            if (!val) {
                              ctrl.dropoffLocation.value = '';
                            }
                            ctrl.applyFilters();
                          },
                          title: const Text(
                            'Different Drop-off Location',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          activeColor: cs.primary,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),

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
                                      ctrl.updateDropoffLocation(val);
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
                                                    ),
                                                  ),
                                                ],
                                              ],
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
                      const SizedBox(height: 8),

                      // Pick-up and Drop-off Date/Time buttons
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await _selectDateRange(context, ctrl, true);
                              },
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
                              onTap: () async {
                                await _selectDateRange(context, ctrl, false);
                              },
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

                      // Chauffeur availability switch
                      Obx(() => SwitchListTile.adaptive(
                            value: ctrl.isChauffeurRequired.value,
                            onChanged: (val) {
                              ctrl.isChauffeurRequired.value = val;
                              ctrl.applyFilters();
                            },
                            title: const Text(
                              'Require Chauffeur Service',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            activeColor: cs.primary,
                            contentPadding: EdgeInsets.zero,
                          )),
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
                          'Apply Details',
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

