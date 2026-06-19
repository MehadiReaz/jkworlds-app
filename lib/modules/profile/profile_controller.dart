import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/data/services/auth_service.dart';

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

  SharedPreferences get _prefs => Get.find<SharedPreferences>();
  AuthService get _auth => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _restoreDarkMode();
    // Refresh user profile from server in the background (non-blocking)
    _auth.fetchProfile();
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
}
