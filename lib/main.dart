import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/translations/app_translations.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences and register globally via GetX
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  runApp(const JKWorldsApp());
}

class JKWorldsApp extends StatelessWidget {
  const JKWorldsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Restore persisted locale if available
    final prefs = Get.find<SharedPreferences>();
    final savedLocale = prefs.getString('locale');
    Locale? locale;
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        locale = Locale(parts[0], parts[1]);
      }
    }

    return GetMaterialApp(
      title: 'JKWorlds',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: (prefs.getBool('dark_mode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light,

      // ── Translations ───────────────────────────────────────────
      translations: AppTranslations(),
      locale: locale ?? const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      // ── Routing ────────────────────────────────────────────────
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // ── Global DI ──────────────────────────────────────────────
      initialBinding: InitialBinding(),
    );
  }
}
