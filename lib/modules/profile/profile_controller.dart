import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/review_service.dart';
import 'package:jkworlds/data/services/damage_report_service.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/damage_report_model.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';

class ProfileController extends GetxController {
  static const _localeKey = 'locale';
  static const _darkModeKey = 'dark_mode';

  // ── Dark Mode ──────────────────────────────────────────────────
  final isDarkMode = false.obs;

  // ── Supported Locales ─────────────────────────────────────────
  final locales = const [
    {'name': 'English', 'locale': Locale('en', 'US')},
    {'name': 'Yorùbá', 'locale': Locale('yo', 'NG')},
    {'name': 'Hausa', 'locale': Locale('ha', 'NG')},
    {'name': 'Igbo', 'locale': Locale('ig', 'NG')},
  ];

  // ── Rating Form State ────────────────────────────────────────
  final selectedBookingId = RxnString();
  final selectedRating = RxnDouble();
  final commentController = TextEditingController();
  final isSubmittingRating = false.obs;

  // ── Damage Report Form State ─────────────────────────────────
  final damageSelectedBookingId = RxnString();
  final damageTitleController = TextEditingController();
  final damageSeverity = 'minor'.obs; // 'minor', 'moderate', 'severe'
  final damageDescriptionController = TextEditingController();
  final damageSelectedImages = <String>[].obs;
  final isSubmittingDamageReport = false.obs;

  // ── Damage Reports Dashboard State ───────────────────────────
  final damageReports = <DamageReportModel>[].obs;
  final totalDamageReports = 0.obs;
  final pendingDamageReports = 0.obs;
  final resolvedDamageReports = 0.obs;
  final isLoadingReportsList = false.obs;

  SharedPreferences get _prefs => Get.find<SharedPreferences>();
  AuthService get _auth => Get.find<AuthService>();
  BookingService get _bookingService => Get.find<BookingService>();
  ReviewService get _reviewService => Get.find<ReviewService>();
  DamageReportService get _damageReportService => Get.find<DamageReportService>();

  List<BookingModel> get bookings => _bookingService.bookings;
  bool get isLoadingBookings => _bookingService.isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _restoreDarkMode();
    // Refresh user profile from server in the background (non-blocking)
    _auth.fetchProfile();

    // Fetch bookings if user is logged in, and listen to login state changes
    if (_auth.isLoggedIn.value) {
      _bookingService.fetchBookings();
      loadDamageReportsDashboard();
    }
    ever(_auth.isLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        _bookingService.fetchBookings();
        loadDamageReportsDashboard();
      } else {
        // Clear bookings if logged out
        _bookingService.bookings.clear();
        damageReports.clear();
        _resetRatingForm();
        _resetDamageForm();
      }
    });
  }

  void _resetRatingForm() {
    selectedBookingId.value = null;
    selectedRating.value = null;
    commentController.clear();
  }

  void _resetDamageForm() {
    damageSelectedBookingId.value = null;
    damageTitleController.clear();
    damageSeverity.value = 'minor';
    damageDescriptionController.clear();
    damageSelectedImages.clear();
  }

  // ── Submit Rating ─────────────────────────────────────────────
  Future<void> submitRating() async {
    final bookingId = selectedBookingId.value;
    final rating = selectedRating.value;
    final comment = commentController.text.trim();

    if (bookingId == null || bookingId.isEmpty) {
      SnackbarHelper.showError('Please select a booking.');
      return;
    }

    if (rating == null) {
      SnackbarHelper.showError('Please select a rating.');
      return;
    }

    if (comment.isEmpty) {
      SnackbarHelper.showError('Please write your experience.');
      return;
    }

    isSubmittingRating.value = true;
    try {
      await _reviewService.createRating(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      SnackbarHelper.showSuccess('Rating submitted successfully!');
      _resetRatingForm();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isSubmittingRating.value = false;
    }
  }

  // ── Submit Damage Report ──────────────────────────────────────
  Future<void> submitDamageReport() async {
    final bookingId = damageSelectedBookingId.value;
    final title = damageTitleController.text.trim();
    final severity = damageSeverity.value;
    final description = damageDescriptionController.text.trim();

    if (bookingId == null || bookingId.isEmpty) {
      SnackbarHelper.showError('Please select a booking.');
      return;
    }

    if (title.isEmpty) {
      SnackbarHelper.showError('Please enter a damage title.');
      return;
    }

    if (severity.isEmpty) {
      SnackbarHelper.showError('Please select severity level.');
      return;
    }

    isSubmittingDamageReport.value = true;
    try {
      await _damageReportService.createDamageReport(
        bookingId: bookingId,
        title: title,
        severity: severity,
        description: description,
        imagePaths: damageSelectedImages,
      );
      SnackbarHelper.showSuccess('Damage report submitted successfully!');
      _resetDamageForm();
      loadDamageReportsDashboard();
      Get.back();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isSubmittingDamageReport.value = false;
    }
  }

  // ── Load Damage Reports Dashboard ─────────────────────────────
  Future<void> loadDamageReportsDashboard() async {
    isLoadingReportsList.value = true;
    try {
      final data = await _damageReportService.fetchDamageReportsDashboard();
      
      final reportsList = data['reports'] as List<DamageReportModel>;
      damageReports.assignAll(reportsList);

      final stats = data['stats'] as Map<String, dynamic>;
      totalDamageReports.value = stats['total'] ?? 0;
      pendingDamageReports.value = stats['pending'] ?? 0;
      resolvedDamageReports.value = stats['resolved'] ?? 0;
    } catch (e) {
      SnackbarHelper.showError('Failed to load damage reports: ${e.toString()}');
    } finally {
      isLoadingReportsList.value = false;
    }
  }

  // ── Image Picker Handlers ─────────────────────────────────────
  Future<void> pickDamageImage() async {
    final path = await ImagePickerHelper.pickImageWithBottomSheet(
      title: 'select_image_source'.tr,
    );
    if (path != null) {
      damageSelectedImages.add(path);
    }
  }

  void removeDamageImage(int index) {
    if (index >= 0 && index < damageSelectedImages.length) {
      damageSelectedImages.removeAt(index);
    }
  }

  // ── Dark Mode ────────────────────────────────────────────────
  void _restoreDarkMode() {
    final saved = _prefs.getBool(_darkModeKey) ?? false;
    isDarkMode.value = saved;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(saved ? ThemeMode.dark : ThemeMode.light);
    });
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _prefs.setBool(_darkModeKey, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // ── Locale ───────────────────────────────────────────────────
  /// Change the app locale and persist the choice.
  void changeLocale(Locale locale) {
    Get.updateLocale(locale);
    Get.find<SharedPreferences>().setString(
      _localeKey,
      '${locale.languageCode}_${locale.countryCode}',
    );
  }

  /// Read saved locale from storage; returns null if none saved.
  Locale? get savedLocale {
    final saved = Get.find<SharedPreferences>().getString(_localeKey);
    if (saved == null) return null;
    final parts = saved.split('_');
    if (parts.length != 2) return null;
    return Locale(parts[0], parts[1]);
  }

  @override
  void onClose() {
    commentController.dispose();
    damageTitleController.dispose();
    damageDescriptionController.dispose();
    super.onClose();
  }
}
