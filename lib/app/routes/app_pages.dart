import 'package:get/get.dart';

import 'package:jkworlds/modules/main_nav/main_nav_view.dart';
import 'package:jkworlds/modules/main_nav/main_nav_binding.dart';

import 'package:jkworlds/modules/auth/login_view.dart';
import 'package:jkworlds/modules/auth/signup_view.dart';
import 'package:jkworlds/modules/auth/forgot_password_view.dart';
import 'package:jkworlds/modules/auth/auth_binding.dart';

import 'app_routes.dart';

/// All route → page mappings for GetX navigation.
class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),

    // ── Auth ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
  ];
}
