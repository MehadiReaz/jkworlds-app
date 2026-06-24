/// Named route constants.
abstract class AppRoutes {
  static const splash          = '/splash';
  static const main            = '/main';
  static const home            = '/home';
  static const explore         = '/explore';
  static const orders          = '/orders';
  static const profile         = '/profile';

  // ── Auth ────────────────────────────────────────────────────
  static const login           = '/login';
  static const signup          = '/signup';
  static const forgotPassword  = '/forgot-password';
  static const verifyOtp       = '/verify-otp';
  static const resetPassword   = '/reset-password';
  static const preferences     = '/preferences';
  static const notificationSettings = '/notification-settings';
  static const contactUs       = '/contact-us';
  static const promoCodes      = '/promo-codes';
  static const editProfile     = '/edit-profile';
  static const vehicleDetail   = '/vehicle-detail';
  static const checkout        = '/checkout';
  static const about           = '/about';
  static const terms           = '/terms';
  static const privacy         = '/privacy';
  static const helpSupport     = '/help-support';

  // ── Support Tickets ──────────────────────────────────────────
  static const supportTickets       = '/support-tickets';
  static const createSupportTicket = '/support-tickets/create';
  static const supportTicketChat   = '/support-tickets/chat';
}
