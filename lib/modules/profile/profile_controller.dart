import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/review_service.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';

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

  SharedPreferences get _prefs => Get.find<SharedPreferences>();
  AuthService get _auth => Get.find<AuthService>();
  BookingService get _bookingService => Get.find<BookingService>();
  ReviewService get _reviewService => Get.find<ReviewService>();

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
    }
    ever(_auth.isLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        _bookingService.fetchBookings();
      } else {
        // Clear bookings if logged out
        _bookingService.bookings.clear();
        _resetRatingForm();
      }
    });
  }

  void _resetRatingForm() {
    selectedBookingId.value = null;
    selectedRating.value = null;
    commentController.clear();
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
    super.onClose();
  }
}
