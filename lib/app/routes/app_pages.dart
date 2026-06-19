import 'package:get/get.dart';

import 'package:jkworlds/modules/splash/splash_view.dart';
import 'package:jkworlds/modules/splash/splash_binding.dart';
import 'package:jkworlds/modules/main_nav/main_nav_view.dart';
import 'package:jkworlds/modules/main_nav/main_nav_binding.dart';

import 'package:jkworlds/modules/auth/login_view.dart';
import 'package:jkworlds/modules/auth/signup_view.dart';
import 'package:jkworlds/modules/auth/forgot_password_view.dart';
import 'package:jkworlds/modules/auth/verify_otp_view.dart';
import 'package:jkworlds/modules/auth/reset_password_view.dart';
import 'package:jkworlds/modules/auth/auth_binding.dart';

import 'package:jkworlds/modules/preferences/preferences_view.dart';
import 'package:jkworlds/modules/notifications/notification_settings_view.dart';
import 'package:jkworlds/modules/contact/contact_us_view.dart';
import 'package:jkworlds/modules/promo/promo_codes_view.dart';
import 'package:jkworlds/modules/profile/profile_binding.dart';
import 'package:jkworlds/modules/profile/edit_profile_view.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_view.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_binding.dart';
import 'package:jkworlds/modules/booking/checkout_view.dart';
import 'package:jkworlds/modules/booking/checkout_binding.dart';

import 'app_routes.dart';

/// All route → page mappings for GetX navigation.
class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.preferences,
      page: () => const PreferencesView(),
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsView(),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsView(),
    ),
    GetPage(
      name: AppRoutes.promoCodes,
      page: () => const PromoCodesView(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicleDetail,
      page: () => const VehicleDetailView(),
      binding: VehicleDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
  ];
}


