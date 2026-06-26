import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/location_prediction.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';

class VehicleDetailController extends GetxController {
  // The vehicle starts as the list-page preview; replaced with full detail after fetch.
  late VehicleModel vehicle;
  final vehicleRx = Rxn<VehicleModel>();

  final reviews = <ReviewModel>[].obs;
  final similarVehicles = <VehicleModel>[].obs;
  final selectedPriceTab = 0.obs; // 0=daily, 1=weekly, 2=monthly
  final isSelfDrive = true.obs;
  final isWishlisted = false.obs;
  final currentGalleryIndex = 0.obs; // Track gallery page index
  final scrollController = ScrollController();

  // ── Loading / Error States ──────────────────────────────────────
  final isLoadingDetail = true.obs;
  final detailError = ''.obs;

  // ── Reservation Form States ──────────────────────────────────────
  final pickupDate = Rxn<DateTime>();
  final returnDate = Rxn<DateTime>();
  final pickupTime = ''.obs;
  final returnTime = ''.obs;
  final selectedProtection = 'Basic'.obs; // Basic, Premium, Full
  final gpsAddon = false.obs;
  final additionalDriverAddon = false.obs;
  final childSeatAddon = false.obs;
  final prepaidFuelAddon = false.obs;
  final isLoading = false.obs;

  // ── Location & Autocomplete States ──────────────────────────────
  final pickupLocation = ''.obs;
  final isDifferentDropoff = false.obs;
  final dropoffLocation = ''.obs;

  final selectedPickupPrediction = Rxn<LocationPrediction>();
  final selectedDropoffPrediction = Rxn<LocationPrediction>();

  final pickupLocationCtrl = TextEditingController();
  final dropoffLocationCtrl = TextEditingController();

  final pickupSuggestions = <LocationPrediction>[].obs;
  final dropoffSuggestions = <LocationPrediction>[].obs;
  final isLoadingPickup = false.obs;
  final isLoadingDropoff = false.obs;

  Timer? _pickupDebounceTimer;
  Timer? _dropoffDebounceTimer;

  LocationService get _locationService => Get.find<LocationService>();

  bool get isAirportTransfer {
    final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
    return exploreCtrl?.selectedServiceType.value == 'Chauffeur';
  }

  bool get isFromFeatured {
    final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
    return exploreCtrl == null || exploreCtrl.pickupLocation.value.isEmpty;
  }

  Future<void> _fetchPickupSuggestions(String query) async {
    if (query.trim().isEmpty) {
      pickupSuggestions.clear();
      return;
    }
    isLoadingPickup.value = true;
    try {
      final results = await _locationService.searchLocations(query);
      pickupSuggestions.assignAll(results);
    } catch (_) {
      pickupSuggestions.clear();
    } finally {
      isLoadingPickup.value = false;
    }
  }

  Future<void> _fetchDropoffSuggestions(String query) async {
    if (query.trim().isEmpty) {
      dropoffSuggestions.clear();
      return;
    }
    isLoadingDropoff.value = true;
    try {
      final results = await _locationService.searchLocations(query);
      dropoffSuggestions.assignAll(results);
    } catch (_) {
      dropoffSuggestions.clear();
    } finally {
      isLoadingDropoff.value = false;
    }
  }

  void updatePickupLocation(String val) {
    pickupLocation.value = val;
    _pickupDebounceTimer?.cancel();
    _pickupDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchPickupSuggestions(val);
    });
  }

  void updateDropoffLocation(String val) {
    dropoffLocation.value = val;
    _dropoffDebounceTimer?.cancel();
    _dropoffDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchDropoffSuggestions(val);
    });
  }

  void selectPickupSuggestion(LocationPrediction suggestion) {
    pickupLocationCtrl.text = suggestion.name;
    pickupLocation.value = suggestion.name;
    selectedPickupPrediction.value = suggestion;
    pickupSuggestions.clear();
  }

  void selectDropoffSuggestion(LocationPrediction suggestion) {
    dropoffLocationCtrl.text = suggestion.name;
    dropoffLocation.value = suggestion.name;
    selectedDropoffPrediction.value = suggestion;
    dropoffSuggestions.clear();
  }

  CategoryService get _categoryService => Get.find<CategoryService>();

  @override
  void onInit() {
    super.onInit();
    // Vehicle is passed via Get.arguments (from list page)
    vehicle = Get.arguments as VehicleModel;
    vehicleRx.value = vehicle;

    // Fetch full details from the API
    _fetchVehicleDetail();

    if (Get.isRegistered<CurrencyService>()) {
      ever(Get.find<CurrencyService>().selectedCurrency, (_) {
        _fetchVehicleDetail();
      });
    }

    // Determine booking mode and pre-populate search criteria
    final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
    if (exploreCtrl != null) {
      if (isAirportTransfer) {
        additionalDriverAddon.value = true;
        isSelfDrive.value = false;
      }
      
      if (exploreCtrl.pickupLocation.value.isNotEmpty) {
        pickupLocation.value = exploreCtrl.pickupLocation.value;
        pickupLocationCtrl.text = exploreCtrl.pickupLocation.value;
        selectedPickupPrediction.value = exploreCtrl.selectedPickupPrediction.value;
      }
      if (exploreCtrl.pickupDateTime.value != null) {
        pickupDate.value = exploreCtrl.pickupDateTime.value;
        pickupTime.value = DateFormat('h:mm a').format(exploreCtrl.pickupDateTime.value!);
      }
      if (exploreCtrl.dropoffDateTime.value != null) {
        returnDate.value = exploreCtrl.dropoffDateTime.value;
        returnTime.value = DateFormat('h:mm a').format(exploreCtrl.dropoffDateTime.value!);
      }
      if (exploreCtrl.isDifferentDropoff.value && exploreCtrl.dropoffLocation.value.isNotEmpty) {
        isDifferentDropoff.value = true;
        dropoffLocation.value = exploreCtrl.dropoffLocation.value;
        dropoffLocationCtrl.text = exploreCtrl.dropoffLocation.value;
        selectedDropoffPrediction.value = exploreCtrl.selectedDropoffPrediction.value;
      }
    }

    // Reset different drop-off if additional driver addon is unchecked
    ever(additionalDriverAddon, (bool hasDriver) {
      if (!hasDriver) {
        isDifferentDropoff.value = false;
        dropoffLocation.value = '';
        dropoffLocationCtrl.clear();
      }
    });
  }

  /// Fetches the full vehicle detail from the API endpoint
  /// GET /api/vehicles/{id}
  Future<void> _fetchVehicleDetail() async {
    isLoadingDetail.value = true;
    detailError.value = '';

    try {
      final result = await _categoryService.fetchVehicleDetail(vehicle.id);

      // Update vehicle with full details from API
      vehicle = result.vehicle;
      vehicleRx.value = result.vehicle;

      // Populate reviews
      reviews.assignAll(result.reviews);

      // Populate similar vehicles
      similarVehicles.assignAll(result.similarVehicles);
    } catch (e) {
      logger.e('[VehicleDetailController] Error fetching vehicle detail: $e');
      detailError.value = e.toString();
      // The page still works with the list-page preview data
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Retry fetching vehicle details (e.g. after a network error)
  Future<void> retryFetchDetail() => _fetchVehicleDetail();

  void selectPriceTab(int tab) {
    selectedPriceTab.value = tab;
  }

  void toggleDriveMode() {
    isSelfDrive.value = !isSelfDrive.value;
  }

  void toggleWishlist() {
    isWishlisted.value = !isWishlisted.value;
    SnackbarHelper.showSuccess(
      '${isWishlisted.value ? 'wishlisted'.tr : 'removed_wishlist'.tr}: ${vehicle.name}',
    );
  }

  double get displayPrice {
    final v = vehicleRx.value ?? vehicle;
    switch (selectedPriceTab.value) {
      case 1:
        return v.pricePerWeek;
      case 2:
        return v.pricePerMonth;
      default:
        return v.pricePerDay;
    }
  }

  String get priceSuffix {
    switch (selectedPriceTab.value) {
      case 1:
        return 'per_week'.tr;
      case 2:
        return 'per_month'.tr;
      default:
        return 'per_day'.tr;
    }
  }

  // ── Pricing Getters & Logic ──────────────────────────────────────
  int get totalDays {
    if (pickupDate.value == null || returnDate.value == null) return 0;
    final diff = returnDate.value!.difference(pickupDate.value!).inDays;
    return diff > 0 ? diff : 0;
  }

  double get subtotal {
    final v = vehicleRx.value ?? vehicle;
    return totalDays * v.pricePerDay;
  }

  double get protectionCost {
    final v = vehicleRx.value ?? vehicle;
    if (v.protectionPlans.isNotEmpty) {
      final plans = v.protectionPlans.where((p) => p.title.toLowerCase().contains(selectedProtection.value.toLowerCase()));
      if (plans.isNotEmpty) {
        final plan = plans.first;
        if (plan.priceType == 'percentage' && plan.priceValue != null) {
          return subtotal * (plan.priceValue! / 100.0);
        } else if (plan.priceType == 'fixed' && plan.priceValue != null) {
          return plan.priceValue! * totalDays;
        }
      }
      return 0.0;
    }
    // Fallback:
    if (selectedProtection.value == 'Premium') {
      return subtotal * 0.15;
    } else if (selectedProtection.value == 'Full') {
      return subtotal * 0.25;
    }
    return 0.0;
  }

  double get gpsAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('gps'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      return addons.first.priceValue!;
    }
    return 5000.0;
  }

  double get additionalDriverAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('driver'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        return (subtotal * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 8000.0;
  }

  double get childSeatAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('seat') || a.title.toLowerCase().contains('child'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        return (subtotal * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 4000.0;
  }

  double get prepaidFuelAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('fuel') || a.title.toLowerCase().contains('prepaid'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        return (subtotal * (addon.priceValue! / 100.0));
      }
      return addon.priceValue!;
    }
    return 15000.0;
  }

  double get addonsCost {
    double cost = 0.0;
    if (gpsAddon.value) cost += gpsAddonPrice * totalDays;
    if (additionalDriverAddon.value) cost += additionalDriverAddonPrice * totalDays;
    if (childSeatAddon.value) cost += childSeatAddonPrice * totalDays;
    if (prepaidFuelAddon.value) cost += prepaidFuelAddonPrice; // Flat/One-time fee
    return cost;
  }

  double get serviceFee => subtotal * 0.05;

  double get securityDeposit {
    final v = vehicleRx.value ?? vehicle;
    if (v.securityDepositAmount != null) {
      return v.securityDepositAmount!;
    }
    if (v.type == 'Luxury') return 150000.0;
    if (v.type == 'SUV') return 100000.0;
    return 50000.0;
  }

  double get total {
    if (totalDays == 0) return 0.0;
    return subtotal + protectionCost + addonsCost + serviceFee + securityDeposit;
  }

  bool get canBook {
    final needsPickupSelection = pickupLocation.value.trim().isEmpty;
    final needsDropoffSelection = isDifferentDropoff.value && dropoffLocation.value.trim().isEmpty;

    return pickupDate.value != null &&
        returnDate.value != null &&
        pickupTime.value.isNotEmpty &&
        returnTime.value.isNotEmpty &&
        totalDays > 0 &&
        !needsPickupSelection &&
        !needsDropoffSelection;
  }

  /// Validates if a date is selectable based on unavailable dates
  bool isDateSelectable(DateTime date) {
    final v = vehicleRx.value ?? vehicle;
    
    // Normalize the date to midnight
    final dateNormalized = DateTime(date.year, date.month, date.day);
    
    // Check against all unavailable date ranges
    for (final unavailableRange in v.unavailableDates) {
      final fromDate = DateTime.tryParse(unavailableRange.from);
      final toDate = DateTime.tryParse(unavailableRange.to);
      if (fromDate == null || toDate == null) continue;
      
      // Normalize to midnight for comparison
      final fromNormalized = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final toNormalized = DateTime(toDate.year, toDate.month, toDate.day);
      
      // Check if date falls within the unavailable range (inclusive)
      if (!dateNormalized.isBefore(fromNormalized) &&
          !dateNormalized.isAfter(toNormalized)) {
        return false;
      }
    }
    
    return true;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final initialRange = pickupDate.value != null && returnDate.value != null
        ? DateTimeRange(start: pickupDate.value!, end: returnDate.value!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (date, start, end) => isDateSelectable(date),
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
      // Validate that all dates in the range are selectable
      bool allSelectable = true;
      for (int i = 0; i <= pickedRange.end.difference(pickedRange.start).inDays; i++) {
        final date = pickedRange.start.add(Duration(days: i));
        if (!isDateSelectable(date)) {
          allSelectable = false;
          break;
        }
      }

      if (allSelectable) {
        pickupDate.value = pickedRange.start;
        returnDate.value = pickedRange.end;
      } else {
        SnackbarHelper.showError('selected_range_contains_booked_dates'.tr);
      }
    }
  }

  Future<void> selectPickupDate(BuildContext context) async {
    await selectDateRange(context);
  }

  Future<void> selectReturnDate(BuildContext context) async {
    await selectDateRange(context);
  }

  Future<void> selectPickupTime(BuildContext context) async {
    _showTimeListBottomSheet(context, pickupTime);
  }

  Future<void> selectReturnTime(BuildContext context) async {
    _showTimeListBottomSheet(context, returnTime);
  }

  void _showTimeListBottomSheet(BuildContext context, RxString timeRx) {
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
      'Morning - Afternoon': [
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
                                final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                                final isSelected = timeRx.value == timeStr;
                                
                                return InkWell(
                                  onTap: () {
                                    timeRx.value = timeStr;
                                    Get.back(); // Close bottom sheet
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? cs.primary
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

  Future<void> confirmBooking() async {
    if (!canBook) return;

    final currentVehicle = vehicleRx.value ?? vehicle;

    // Serialize the details of the booking configurator to pass to Checkout Screen
    final arguments = {
      'vehicle': currentVehicle,
      'pickupDate': pickupDate.value!,
      'returnDate': returnDate.value!,
      'pickupTime': pickupTime.value,
      'returnTime': returnTime.value,
      'isSelfDrive': isSelfDrive.value,
      'selectedProtection': selectedProtection.value,
      'gpsAddon': gpsAddon.value,
      'additionalDriverAddon': additionalDriverAddon.value,
      'childSeatAddon': childSeatAddon.value,
      'prepaidFuelAddon': prepaidFuelAddon.value,
      'subtotal': subtotal,
      'protectionCost': protectionCost,
      'addonsCost': addonsCost,
      'serviceFee': serviceFee,
      'securityDeposit': securityDeposit,
      'total': total,
      'pickupLocation': pickupLocation.value,
      'dropoffLocation': isDifferentDropoff.value ? dropoffLocation.value : pickupLocation.value,
      'selectedPickupPrediction': selectedPickupPrediction.value,
      'selectedDropoffPrediction': selectedDropoffPrediction.value,
      'isDifferentDropoff': isDifferentDropoff.value,
    };

    // Navigate to Checkout Screen
    Get.toNamed('/checkout', arguments: arguments);
  }

  @override
  void onClose() {
    _pickupDebounceTimer?.cancel();
    _dropoffDebounceTimer?.cancel();
    pickupLocationCtrl.dispose();
    dropoffLocationCtrl.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Navigate to a similar vehicle's detail page
  void navigateToSimilarVehicle(VehicleModel similarVehicle) {
    vehicle = similarVehicle;
    vehicleRx.value = similarVehicle;
    reviews.clear();
    similarVehicles.clear();
    currentGalleryIndex.value = 0;

    // Reset configurator states
    pickupDate.value = null;
    returnDate.value = null;
    selectedProtection.value = 'Basic';
    gpsAddon.value = false;
    additionalDriverAddon.value = isAirportTransfer;
    childSeatAddon.value = false;

    // Reset location states
    isDifferentDropoff.value = false;
    pickupLocation.value = '';
    dropoffLocation.value = '';
    pickupLocationCtrl.clear();
    dropoffLocationCtrl.clear();
    selectedPickupPrediction.value = null;
    selectedDropoffPrediction.value = null;

    _fetchVehicleDetail();

    if (scrollController.hasClients) {
      scrollController.animateTo(
         0.0,
         duration: const Duration(milliseconds: 300),
         curve: Curves.easeOut,
      );
    }
  }
}
