import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService extends GetxService {
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _firstCheck = true;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() {
    // Disable connectivity checks completely in widget tests to avoid pending timers/network lookup requests
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    // Subscribe to system connectivity changes reactively
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // Run initial check on service startup
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      await _handleConnectivityChange(results);
    } catch (_) {
      _updateStatus(false);
    }
  }

  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    // If the system says there is no network interface, mark offline immediately
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _updateStatus(false);
      return;
    }

    // Connected to a network interface, verify if we have actual internet access
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final hasInternet = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      _updateStatus(hasInternet);
    } catch (_) {
      _updateStatus(false);
    }
  }

  void _updateStatus(bool connected) {
    if (isOnline.value == connected) {
      _firstCheck = false;
      return;
    }

    isOnline.value = connected;

    if (_firstCheck) {
      _firstCheck = false;
      // Show offline alert if started offline
      if (!connected) {
        _showOfflineSnackbar();
      }
      return;
    }

    if (connected) {
      _showOnlineSnackbar();
    } else {
      _showOfflineSnackbar();
    }
  }

  void _showOfflineSnackbar() {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      titleText: const Text(
        'Connection Lost',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: const Text(
        'You are currently offline. Some features may not work.',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi_off_rounded,
          color: Color(0xFFFF5252),
          size: 24,
        ),
      ),
      backgroundColor: const Color(0xFF2C1619),
      borderColor: const Color(0xFFFF5252).withValues(alpha: 0.3),
      borderWidth: 1,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      isDismissible: false,
      duration: const Duration(days: 365), // Persistent
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _showOnlineSnackbar() {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      titleText: const Text(
        'Back Online',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: const Text(
        'Your internet connection has been restored.',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi_rounded,
          color: Color(0xFF4CAF50),
          size: 24,
        ),
      ),
      backgroundColor: const Color(0xFF092E16),
      borderColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
      borderWidth: 1,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 2500),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
