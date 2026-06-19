import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    logger.i('[NotificationService] Handling background message: ${message.messageId}');
  } catch (e) {
    logger.w('[NotificationService] Background message handler Firebase initialization failed (non-fatal): $e');
  }
}

/// Push notification service.
///
/// Integrates Firebase Cloud Messaging for notification updates.
/// Usage:
///   Register in InitialBinding as a permanent service.
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
    initialize();
  }

  /// Call this early in app startup.
  /// Initializes Firebase and configures messaging listeners.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      final fcm = FirebaseMessaging.instance;

      // Request permission
      await requestPermission();

      // Get FCM token
      deviceToken.value = await fcm.getToken() ?? '';
      logger.i('[NotificationService] FCM Device Token: ${deviceToken.value}');

      // Listen for token updates
      fcm.onTokenRefresh.listen((t) {
        deviceToken.value = t;
        logger.i('[NotificationService] FCM Token Refreshed: $t');
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      onForegroundMessage();

      // Handle message clicks when app is in background/terminated
      _setupMessageTaps();

    } catch (e, st) {
      logger.e('[NotificationService] Firebase failed to initialize. Make sure google-services.json / GoogleService-Info.plist is configured.', error: e, stackTrace: st);
      // Fallback: simulate token generation so app remains functional
      deviceToken.value = 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
      permissionStatus.value = 'granted';
    }
  }

  /// Request push permission from the OS.
  /// Returns `true` if granted.
  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                      settings.authorizationStatus == AuthorizationStatus.provisional;
      permissionStatus.value = granted ? 'granted' : 'denied';
      return granted;
    } catch (_) {
      permissionStatus.value = 'denied';
      return false;
    }
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

    if (value) {
      initialize();
    } else {
      FirebaseMessaging.instance.deleteToken().catchError((_) {});
      deviceToken.value = '';
    }
  }

  void toggleBookingUpdates(bool value) {
    bookingUpdates.value = value;
    _prefs.setBool(_keyBookingUpdates, value);
    _subscribeOrUnsubscribe('booking_updates', value);
  }

  void togglePromotions(bool value) {
    promotions.value = value;
    _prefs.setBool(_keyPromotions, value);
    _subscribeOrUnsubscribe('promotions', value);
  }

  void togglePriceAlerts(bool value) {
    priceAlerts.value = value;
    _prefs.setBool(_keyPriceAlerts, value);
    _subscribeOrUnsubscribe('price_alerts', value);
  }

  void toggleNewVehicles(bool value) {
    newVehicles.value = value;
    _prefs.setBool(_keyNewVehicles, value);
    _subscribeOrUnsubscribe('new_vehicles', value);
  }

  Future<void> _subscribeOrUnsubscribe(String topic, bool subscribe) async {
    try {
      final fcm = FirebaseMessaging.instance;
      if (subscribe) {
        await fcm.subscribeToTopic(topic);
        logger.i('[NotificationService] Subscribed to topic: $topic');
      } else {
        await fcm.unsubscribeFromTopic(topic);
        logger.i('[NotificationService] Unsubscribed from topic: $topic');
      }
    } catch (e) {
      logger.w('[NotificationService] Topic subscription change failed: $e');
    }
  }

  // ── Foreground Message Handler ──────────────────────────────

  /// Register a handler for foreground messages.
  void onForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('[NotificationService] Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      onTap: (_) {
        onNotificationTap(message.data);
      },
    );
  }

  Future<void> _setupMessageTaps() async {
    try {
      final fcm = FirebaseMessaging.instance;

      // 1. Terminated state: Get any message that caused the app to open
      final initialMessage = await fcm.getInitialMessage();
      if (initialMessage != null) {
        onNotificationTap(initialMessage.data);
      }

      // 2. Background state: Listen to clicks while app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onNotificationTap(message.data);
      });
    } catch (e) {
      logger.w('[NotificationService] Message taps setup failed: $e');
    }
  }

  /// Handle a notification tap (when user taps a notification).
  void onNotificationTap(Map<String, dynamic> data) {
    logger.i('[NotificationService] Notification tapped: $data');
  }
}
