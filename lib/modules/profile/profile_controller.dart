import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  static const _localeKey = 'locale';

  // ── Supported Locales ─────────────────────────────────────────
  final locales = const [
    {'name': 'English', 'locale': Locale('en', 'US')},
    {'name': 'Yorùbá', 'locale': Locale('yo', 'NG')},
    {'name': 'Hausa', 'locale': Locale('ha', 'NG')},
    {'name': 'Igbo', 'locale': Locale('ig', 'NG')},
  ];

  /// Change the app locale and persist the choice.
  void changeLocale(Locale locale) {
    Get.updateLocale(locale);
    Get.find<SharedPreferences>()
        .setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
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
