import 'dart:async';
import 'dart:io';
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
  final currencyService = Get.find<CurrencyService>();

  String formatPrice(double amount) {
    final cur = currencyService.selectedCurrency.value;
    final digits = cur.code.toUpperCase() == 'NGN' ? 0 : 2;
    final numberFormatter = NumberFormat.decimalPattern();
    numberFormatter.minimumFractionDigits = digits;
    numberFormatter.maximumFractionDigits = digits;
    final formattedNum = numberFormatter.format(amount);
    if (cur.symbolPosition == 'right') {
      return '$formattedNum ${cur.symbol}';
    } else {
      return '${cur.symbol}$formattedNum';
    }
  }

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

  final _refreshTrigger = 0.obs;

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
    if (!isDifferentDropoff.value) {
      dropoffLocation.value = val;
      dropoffLocationCtrl.text = val;
    }
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

void _showLocationNotAvailableDialog() {
    if (Get.context == null ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      debugPrint('[CoverageCheck] Showed Location Not Available Dialog');
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Icon(
          Icons.location_off_rounded,
          color: Get.theme.colorScheme.error,
          size: 28,
        ),
        title: const Text('Location Not Covered'),
        titleTextStyle: Get.theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        content: const Text(
          'Sorry, our services are not available in the selected location at this time. Please choose another location.',
        ),
        contentTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkCoverage(LocationPrediction? prediction, {required bool isPickup}) async {
    if (prediction == null) return;
    logger.f('Check Coverage 1 ${prediction.address}');
    final controller = isPickup ? pickupLocationCtrl : dropoffLocationCtrl;
    final locationVal = isPickup ? pickupLocation : dropoffLocation;
    final predictionVal = isPickup ? selectedPickupPrediction : selectedDropoffPrediction;
    final loadingVal = isPickup ? isLoadingPickup : isLoadingDropoff;

    loadingVal.value = true;
    try {
      logger.f('Check Coverage 2 $prediction');
      final details = await _locationService.fetchLocationDetails(prediction.id);
      final double? lat = details?.latitude ?? prediction.latitude;
      final double? lng = details?.longitude ?? prediction.longitude;
      logger.f('Check Coverage 21 $lat $lng ${details?.address}');
      if (lat != null && lng != null) {
        final sType = isSelfDrive.value ? 'self_drive' : (isAirportTransfer ? 'airport_transfer' : 'chauffeur');
        final coverage = await _locationService.checkCoverage(
          lat: lat,
          lng: lng,
          serviceType: sType,
        );
        logger.f('Check Coverage 3 ${coverage.covered}');
        if (!coverage.covered) {
          _showLocationNotAvailableDialog();
          controller.clear();
          locationVal.value = '';
          predictionVal.value = null;
          if (isPickup && !isDifferentDropoff.value) {
            dropoffLocationCtrl.clear();
            dropoffLocation.value = '';
            selectedDropoffPrediction.value = null;
          }
        }
      }
    } catch (e) {
      logger.e('Coverage check failed: $e');
    } finally {
      loadingVal.value = false;
    }
  }

  void selectPickupSuggestion(LocationPrediction suggestion) async {
    pickupSuggestions.clear();
    pickupLocationCtrl.text = suggestion.name;
    pickupLocation.value = suggestion.name;
    selectedPickupPrediction.value = suggestion;
    if (!isDifferentDropoff.value) {
      dropoffLocationCtrl.text = suggestion.name;
      dropoffLocation.value = suggestion.name;
      selectedDropoffPrediction.value = suggestion;
    }
    await _checkCoverage(suggestion, isPickup: true);
    logger.f('Check Coverage ${selectedPickupPrediction.value}');
  }

  void selectDropoffSuggestion(LocationPrediction suggestion) async {
    dropoffSuggestions.clear();
    dropoffLocationCtrl.text = suggestion.name;
    dropoffLocation.value = suggestion.name;
    selectedDropoffPrediction.value = suggestion;
    await _checkCoverage(suggestion, isPickup: false);
  }

  CategoryService get _categoryService => Get.find<CategoryService>();

  @override
  void onInit() {
    super.onInit();
    // Vehicle is passed via Get.arguments (from list page)
    vehicle = Get.arguments as VehicleModel;
    vehicleRx.value = vehicle;

    // Set up debounced detail/pricing refresher to consolidate simultaneous updates
    debounce(
      _refreshTrigger,
      (_) => _fetchVehicleDetail(),
      time: const Duration(milliseconds: 300),
    );

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
      if (additionalDriverAddon.value) {
        if (exploreCtrl.isDifferentDropoff.value && exploreCtrl.dropoffLocation.value.isNotEmpty) {
          isDifferentDropoff.value = true;
          dropoffLocation.value = exploreCtrl.dropoffLocation.value;
          dropoffLocationCtrl.text = exploreCtrl.dropoffLocation.value;
          selectedDropoffPrediction.value = exploreCtrl.selectedDropoffPrediction.value;
        }
      } else {
        isDifferentDropoff.value = false;
        dropoffLocation.value = pickupLocation.value;
        dropoffLocationCtrl.text = pickupLocationCtrl.text;
        selectedDropoffPrediction.value = selectedPickupPrediction.value;
      }

      if (selectedPickupPrediction.value != null) {
        _checkCoverage(selectedPickupPrediction.value, isPickup: true);
      }
      if (selectedDropoffPrediction.value != null) {
        _checkCoverage(selectedDropoffPrediction.value, isPickup: false);
      }
    }

    // Bind driving mode and reset drop-off details if additional driver addon changes
    ever(additionalDriverAddon, (bool hasDriver) {
      isSelfDrive.value = !hasDriver;
      if (!hasDriver) {
        isDifferentDropoff.value = false;
        dropoffLocation.value = pickupLocation.value;
        dropoffLocationCtrl.text = pickupLocationCtrl.text;
        selectedDropoffPrediction.value = selectedPickupPrediction.value;
      }
      _refreshTrigger.value++;
    });

    ever(isSelfDrive, (_) => _refreshTrigger.value++);

    // Sync drop-off with pickup if "Different Drop-off Location" is toggled off
    ever(isDifferentDropoff, (bool diff) {
      if (!diff) {
        dropoffLocation.value = pickupLocation.value;
        dropoffLocationCtrl.text = pickupLocationCtrl.text;
        selectedDropoffPrediction.value = selectedPickupPrediction.value;
      }
      _refreshTrigger.value++;
    });

    // Also sync if pickup details change while different dropoff is disabled
    ever(pickupLocation, (String pickup) {
      if (!isDifferentDropoff.value) {
        dropoffLocation.value = pickup;
        dropoffLocationCtrl.text = pickupLocationCtrl.text;
      }
    });

    ever(selectedPickupPrediction, (LocationPrediction? pred) {
      if (!isDifferentDropoff.value) {
        selectedDropoffPrediction.value = pred;
      }
      _refreshTrigger.value++;
    });

    ever(selectedDropoffPrediction, (_) => _refreshTrigger.value++);

    // Auto-adjust selectedPriceTab based on date range duration
    ever(pickupDate, (_) => _updatePriceTabAutomatically());
    ever(returnDate, (_) => _updatePriceTabAutomatically());

    _updatePriceTabAutomatically();
  }

  /// Fetches the full vehicle detail from the API endpoint
  /// GET /api/v2/vehicles/{id}
  Future<void> _fetchVehicleDetail() async {
    isLoadingDetail.value = true;
    detailError.value = '';

    try {
      double? pickupLat;
      double? pickupLng;
      double? dropoffLat;
      double? dropoffLng;

      if (selectedPickupPrediction.value != null) {
        try {
          final details = await _locationService.fetchLocationDetails(selectedPickupPrediction.value!.id);
          pickupLat = details?.latitude ?? selectedPickupPrediction.value?.latitude;
          pickupLng = details?.longitude ?? selectedPickupPrediction.value?.longitude;
        } catch (e) {
          logger.e('[VehicleDetailController] Error resolving pickup coordinates: $e');
        }
      }

      if (isDifferentDropoff.value && selectedDropoffPrediction.value != null) {
        try {
          final details = await _locationService.fetchLocationDetails(selectedDropoffPrediction.value!.id);
          dropoffLat = details?.latitude ?? selectedDropoffPrediction.value?.latitude;
          dropoffLng = details?.longitude ?? selectedDropoffPrediction.value?.longitude;
        } catch (e) {
          logger.e('[VehicleDetailController] Error resolving dropoff coordinates: $e');
        }
      } else {
        dropoffLat = pickupLat;
        dropoffLng = pickupLng;
      }

      final String sType = isSelfDrive.value ? 'self_drive' : (isAirportTransfer ? 'airport_transfer' : 'chauffeur');

      final result = await _categoryService.fetchVehicleDetail(
        vehicle.id,
        serviceType: sType,
        pickupLatitude: pickupLat,
        pickupLongitude: pickupLng,
        dropoffLatitude: dropoffLat,
        dropoffLongitude: dropoffLng,
      );

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

  void _updatePriceTabAutomatically() {
    final days = totalDays;
    if (days >= 30) {
      selectedPriceTab.value = 2;
    } else if (days >= 7) {
      selectedPriceTab.value = 1;
    } else {
      selectedPriceTab.value = 0;
    }
  }

  void toggleDriveMode() {
    additionalDriverAddon.value = !additionalDriverAddon.value;
  }

  void toggleWishlist() {
    isWishlisted.value = !isWishlisted.value;
    SnackbarHelper.showSuccess(
      '${isWishlisted.value ? 'wishlisted'.tr : 'removed_wishlist'.tr}: ${vehicle.name}',
    );
  }

  double get displayPrice {
    final v = vehicleRx.value ?? vehicle;
    if (isAirportTransfer) {
      final app = v.servicePricing?.applicable;
      if (app != null) {
        if (app.estimated != null) {
          return app.estimated!.amount;
        } else {
          return app.perKmRate;
        }
      }
    }
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
    if (isAirportTransfer) {
      final v = vehicleRx.value ?? vehicle;
      if (v.servicePricing?.applicable?.estimated != null) {
        return '/transfer';
      }
      return '/km';
    }
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
    if (isAirportTransfer) {
      final est = v.servicePricing?.applicable?.estimated;
      if (est != null) {
        return est.amount;
      }
    }
    switch (selectedPriceTab.value) {
      case 1:
        return totalDays * (v.pricePerWeek / 7.0);
      case 2:
        return totalDays * (v.pricePerMonth / 30.0);
      default:
        return totalDays * v.pricePerDay;
    }
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
    if (v.chauffeurRatePerDay != null && v.chauffeurRatePerDay! > 0) {
      return v.chauffeurRatePerDay!;
    }
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('driver') || a.title.toLowerCase().contains('chauffeur'));
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
    if (additionalDriverAddon.value && !isAirportTransfer) cost += additionalDriverAddonPrice * totalDays;
    if (childSeatAddon.value) cost += childSeatAddonPrice * totalDays;
    if (prepaidFuelAddon.value) cost += prepaidFuelAddonPrice; // Flat/One-time fee
    return cost;
  }

  double get taxesFeesValue {
    final v = vehicleRx.value ?? vehicle;
    
    double scale = 1.0;
    final currency = v.currency;
    if (currency.isNotEmpty) {
      if (Get.isRegistered<CurrencyService>()) {
        final curService = Get.find<CurrencyService>();
        final match = curService.currencies.firstWhereOrNull((c) => c.code.toUpperCase() == currency.toUpperCase());
        if (match != null && match.exchangeRate > 0) {
          scale = 1.0 / match.exchangeRate;
        } else if (currency.toUpperCase() == 'USD') {
          scale = 1600.0;
        }
      } else {
        if (currency.toUpperCase() == 'USD') {
          scale = 1600.0;
        }
      }
    }

    final pricing = v.servicePricing;
    if (pricing != null) {
      if (isAirportTransfer) {
        final app = pricing.applicable;
        if (app != null) {
          if (app.serviceType == 'self_drive') {
            switch (selectedPriceTab.value) {
              case 1:
                if (app.weeklyRate?.taxesFees != null) {
                  return app.weeklyRate!.taxesFees!.amount * scale;
                }
                break;
              case 2:
                if (app.monthlyRate?.taxesFees != null) {
                  return app.monthlyRate!.taxesFees!.amount * scale;
                }
                break;
              default:
                if (app.dailyRate?.taxesFees != null) {
                  return app.dailyRate!.taxesFees!.amount * scale;
                }
                break;
            }
          }
        }
      } else if (isSelfDrive.value) {
        final sd = pricing.selfDrive;
        if (sd != null) {
          switch (selectedPriceTab.value) {
            case 1:
              if (sd.weekly?.taxesFees != null) {
                return sd.weekly!.taxesFees!.amount * scale;
              }
              break;
            case 2:
              if (sd.monthly?.taxesFees != null) {
                return sd.monthly!.taxesFees!.amount * scale;
              }
              break;
            default:
              if (sd.daily?.taxesFees != null) {
                return sd.daily!.taxesFees!.amount * scale;
              }
              break;
          }
        }
      } else {
        final ch = pricing.chauffeur;
        if (ch != null && ch.rate?.taxesFees != null) {
          return ch.rate!.taxesFees!.amount * scale;
        }
      }
    }

    if (v.taxesFees != null) {
      return v.taxesFees!;
    }

    return 4.0;
  }

  double get serviceFee => taxesFeesValue;

  String get taxes_fees => formatPrice(taxesFeesValue);

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

  void showRatePlansSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final v = vehicleRx.value ?? vehicle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 8,
            left: 20,
            right: 20,
          ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rental Rate Plans',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                return Column(
                  children: [
                    _buildRatePlanCard(
                      title: 'Daily Plan',
                      subtitle: 'Standard rate for daily bookings',
                      priceText: v.dailyRateFormatted.isNotEmpty
                          ? '${v.dailyRateFormatted}/day'
                          : '${formatPrice(v.pricePerDay)}/day',
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    if (v.pricePerWeek > 0) ...[
                      _buildRatePlanCard(
                        title: 'Weekly Plan',
                        subtitle: 'Best value for 7+ days rentals',
                        priceText: v.weeklyRateFormatted.isNotEmpty
                            ? '${v.weeklyRateFormatted}/week'
                            : '${formatPrice(v.pricePerWeek)}/week',
                        equivalentText: 'Equivalent to ${formatPrice(v.pricePerWeek / 7.0)}/day',
                        badgeText: 'Save 14%',
                        theme: theme,
                        cs: cs,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (v.pricePerMonth > 0) ...[
                      _buildRatePlanCard(
                        title: 'Monthly Plan',
                        subtitle: 'Super saver for 30+ days rentals',
                        priceText: v.monthlyRateFormatted.isNotEmpty
                            ? '${v.monthlyRateFormatted}/month'
                            : '${formatPrice(v.pricePerMonth)}/month',
                        equivalentText: 'Equivalent to ${formatPrice(v.pricePerMonth / 30.0)}/day',
                        badgeText: 'Save 20%',
                        theme: theme,
                        cs: cs,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Total rental prices will be adjusted automatically during checkout according to your selected dates.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatePlanCard({
    required String title,
    required String subtitle,
    required String priceText,
    String? equivalentText,
    String? badgeText,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (equivalentText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    equivalentText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            priceText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
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
      'selectedPriceTab': selectedPriceTab.value,
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
