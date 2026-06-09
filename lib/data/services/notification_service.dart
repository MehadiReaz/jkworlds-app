import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/utils/logger.dart';

/// Push notification service.
///
/// Currently uses local mock data. When your backend push-notification API
/// is ready, replace the TODO-marked sections with real implementations
/// (e.g. Firebase Cloud Messaging, OneSignal, or your own server).
///
/// Usage:
///   Register in InitialBinding as a permanent service, then
///   call initialize() when ready.
class NotificationService extends GetxService {
  // ── Preference Keys ─────────────────────────────────────────
  static const _keyPushEnabled = 'notif_push_enabled';
  static const _keyBookingUpdates = 'notif_booking_updates';
  static const _keyPromotions = 'notif_promotions';
  static const _keyPriceAlerts = 'notif_price_alerts';
  static const _keyNewVehicles = 'notif_new_vehicles';

  // ── Reactive State ──────────────────────────────────────────
  final pushEnabled = true.obs;
  final bookingUpdates = true.obs;
  final promotions = true.obs;
  final priceAlerts = false.obs;
  final newVehicles = true.obs;

  /// FCM / push token — will be populated after real initialization.
  final deviceToken = ''.obs;

  /// Permission status: 'granted', 'denied', 'not_determined'
  final permissionStatus = 'not_determined'.obs;

  SharedPreferences get _prefs => Get.find<SharedPreferences>();

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _restorePreferences();
  }

  /// Call this early in app startup (e.g. in main() or InitialBinding).
  /// When the real push SDK is available, initialize it here.
  Future<void> initialize() async {
    // TODO: Replace with real push SDK initialization, e.g.:
    //   await Firebase.initializeApp();
    //   final fcm = FirebaseMessaging.instance;
    //   deviceToken.value = await fcm.getToken() ?? '';
    //   fcm.onTokenRefresh.listen((t) => deviceToken.value = t);

    // Mock: simulate token generation
    await Future.delayed(const Duration(milliseconds: 200));
    deviceToken.value = 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
    permissionStatus.value = 'granted';
  }

  /// Request push permission from the OS.
  /// Returns `true` if granted.
  Future<bool> requestPermission() async {
    // TODO: Replace with real permission request, e.g.:
    //   final settings = await FirebaseMessaging.instance.requestPermission();
    //   return settings.authorizationStatus == AuthorizationStatus.authorized;

    await Future.delayed(const Duration(milliseconds: 300));
    permissionStatus.value = 'granted';
    return true;
  }

  // ── Preference Toggles ──────────────────────────────────────

  void _restorePreferences() {
    pushEnabled.value = _prefs.getBool(_keyPushEnabled) ?? true;
    bookingUpdates.value = _prefs.getBool(_keyBookingUpdates) ?? true;
    promotions.value = _prefs.getBool(_keyPromotions) ?? true;
    priceAlerts.value = _prefs.getBool(_keyPriceAlerts) ?? false;
    newVehicles.value = _prefs.getBool(_keyNewVehicles) ?? true;
  }

  void togglePushEnabled(bool value) {
    pushEnabled.value = value;
    _prefs.setBool(_keyPushEnabled, value);

    // TODO: If disabling, unregister token with backend:
    //   if (!value) await _api.unregisterDevice(deviceToken.value);
    //   else await _api.registerDevice(deviceToken.value);
  }

  void toggleBookingUpdates(bool value) {
    bookingUpdates.value = value;
    _prefs.setBool(_keyBookingUpdates, value);
    // TODO: Sync with backend topic subscription
    //   _subscribeOrUnsubscribe('booking_updates', value);
  }

  void togglePromotions(bool value) {
    promotions.value = value;
    _prefs.setBool(_keyPromotions, value);
    // TODO: _subscribeOrUnsubscribe('promotions', value);
  }

  void togglePriceAlerts(bool value) {
    priceAlerts.value = value;
    _prefs.setBool(_keyPriceAlerts, value);
    // TODO: _subscribeOrUnsubscribe('price_alerts', value);
  }

  void toggleNewVehicles(bool value) {
    newVehicles.value = value;
    _prefs.setBool(_keyNewVehicles, value);
    // TODO: _subscribeOrUnsubscribe('new_vehicles', value);
  }

  // ── Foreground Message Handler ──────────────────────────────

  /// Register a handler for foreground messages.
  /// Call from main() or a top-level widget.
  void onForegroundMessage() {
    // TODO: Replace with real handler, e.g.:
    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //     _showLocalNotification(message);
    //   });
  }

  /// Handle a notification tap (when user taps a notification).
  void onNotificationTap(Map<String, dynamic> data) {
    // TODO: Route based on payload, e.g.:
    //   final type = data['type'];
    //   if (type == 'booking') Get.toNamed(AppRoutes.bookingDetail, arguments: data['id']);
    logger.i('[NotificationService] Notification tapped: $data');
  }
}
