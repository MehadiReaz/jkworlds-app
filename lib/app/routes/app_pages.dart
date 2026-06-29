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
import 'package:jkworlds/modules/profile/post_rating_view.dart';
import 'package:jkworlds/modules/profile/report_damage_view.dart';
import 'package:jkworlds/modules/profile/car_damage_reports_view.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_view.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_binding.dart';
import 'package:jkworlds/modules/booking/checkout_view.dart';
import 'package:jkworlds/modules/booking/checkout_binding.dart';
import 'package:jkworlds/modules/static_pages/about_us_view.dart';
import 'package:jkworlds/modules/static_pages/terms_conditions_view.dart';
import 'package:jkworlds/modules/static_pages/privacy_policy_view.dart';
import 'package:jkworlds/modules/static_pages/help_support_view.dart';
import 'package:jkworlds/modules/support_tickets/support_tickets_list_view.dart';
import 'package:jkworlds/modules/support_tickets/create_support_ticket_view.dart';
import 'package:jkworlds/modules/support_tickets/support_ticket_chat_view.dart';
import 'package:jkworlds/modules/support_tickets/support_tickets_binding.dart';
import 'package:jkworlds/modules/booking/payment_webview_screen.dart';
import 'package:jkworlds/modules/booking/payment_status_view.dart';
import 'package:jkworlds/modules/booking/payment_status_binding.dart';
import 'package:jkworlds/modules/booking_detail/booking_detail_view.dart';
import 'package:jkworlds/modules/booking_detail/booking_detail_binding.dart';
import 'package:jkworlds/modules/onboarding/onboarding_wizard_view.dart';
import 'package:jkworlds/modules/onboarding/onboarding_wizard_binding.dart';

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
      name: AppRoutes.onboarding,
      page: () => const OnboardingWizardView(),
      binding: OnboardingWizardBinding(),
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
      name: AppRoutes.postRating,
      page: () => const PostRatingView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.reportDamage,
      page: () => const ReportDamageView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.damageReports,
      page: () => const CarDamageReportsView(),
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
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutUsView(),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsConditionsView(),
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportView(),
    ),
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const SupportTicketsListView(),
      binding: SupportTicketsBinding(),
    ),
    GetPage(
      name: AppRoutes.createSupportTicket,
      page: () => const CreateSupportTicketView(),
      binding: SupportTicketsBinding(),
    ),
    GetPage(
      name: AppRoutes.supportTicketChat,
      page: () => const SupportTicketChatView(),
      binding: SupportTicketsBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentWebView,
      page: () => const PaymentWebViewScreen(),
    ),
    GetPage(
      name: AppRoutes.paymentStatus,
      page: () => const PaymentStatusView(),
      binding: PaymentStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingDetail,
      page: () => const BookingDetailsView(),
      binding: BookingDetailsBinding(),
    ),
  ];
}


