class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────────
  static const String baseUrl = 'https://jkworldsserviceslimited.nexcoreit4u.com';

  // ── Timeouts (milliseconds) ───────────────────────────────────
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // ── Auth Endpoints ───────────────────────────────────────────
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String user = '/api/user';
  static const String refreshToken = '/api/refresh-token';
  static const String forgotPassword = '/api/forgot-password';
  static const String verifyOtp = '/api/verify-otp';
  static const String resetPassword = '/api/reset-password';
  static const String profile = '/api/profile';
  static const String password = '/api/password';

  // ── Category & Vehicle Endpoints ─────────────────────────────
  static const String categories = '/api/categories';
  static String categoryVehicles(int categoryId) => '/api/categories/$categoryId/vehicles';
  static const String vehicles = '/api/vehicles';
  static String vehicleDetail(dynamic id) => '/api/v2/vehicles/$id';
  static const String vehicleFilters = '/api/vehicles/filters';

  // ── Booking Endpoints ────────────────────────────────────────
  static const String bookings = '/api/bookings';
  static String bookingDetail(int id) => '/api/bookings/$id';
  static const String checkout = '/api/checkout';
  static const String bookingsV2 = '/api/bookings';
  static String paymentSuccess(String gateway) => '/api/payments/$gateway/success';
  static String paymentCancel(String gateway) => '/api/payments/$gateway/cancel';
  static const String airportTransferDistance = '/api/airport-transfer/distance';

  // ── Location Endpoints ───────────────────────────────────────
  static const String locationSearch = '/api/location/search';
  static const String locationDetails = '/api/location/details';
  static const String locationCheckCoverage = '/api/location/check-coverage';

  // ── Support Tickets Endpoints ────────────────────────────────
  static const String supportTickets = '/api/support-tickets';
  static const String supportTicketsUnreadSummary = '/api/support-tickets/unread-summary';
  static const String supportTicketsSync = '/api/support-tickets/sync';
  static String supportTicketDetails(int ticketId) => '/api/support-tickets/$ticketId';
  static String supportTicketMessages(int ticketId) => '/api/support-tickets/$ticketId/messages';
  static String supportTicketSendMessage(int ticketId) => '/api/support-tickets/$ticketId/messages';
  static String supportTicketMarkAsRead(int ticketId) => '/api/support-tickets/$ticketId/read';

  // ── App Data Endpoint ────────────────────────────────────────
  static const String appData = '/api/app-data';
}
