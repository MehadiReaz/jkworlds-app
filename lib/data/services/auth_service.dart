import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global auth service — single source of truth for authentication state.
///
/// Uses [SharedPreferences] to simulate token-based auth locally.
/// Register once in [InitialBinding] as a permanent service.
class AuthService extends GetxService {
  // ── Keys ──────────────────────────────────────────────────────
  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_user_name';
  static const _emailKey = 'auth_user_email';

  // ── Reactive State ────────────────────────────────────────────
  final isLoggedIn = false.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;

  SharedPreferences get _prefs => Get.find<SharedPreferences>();

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  /// Restore any persisted session on app start.
  void _restoreSession() {
    final token = _prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
      userName.value = _prefs.getString(_nameKey) ?? '';
      userEmail.value = _prefs.getString(_emailKey) ?? '';
    }
  }

  // ── Auth Actions ──────────────────────────────────────────────

  /// Simulate login with email & password.
  /// Returns `true` on success.
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock: accept any non-empty credentials
    if (email.isEmpty || password.isEmpty) return false;

    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _prefs.setString(_tokenKey, mockToken);
    await _prefs.setString(_emailKey, email);

    // If we already have a stored name, keep it; otherwise use email prefix
    final existingName = _prefs.getString(_nameKey);
    if (existingName == null || existingName.isEmpty) {
      final fallbackName = email.split('@').first;
      await _prefs.setString(_nameKey, fallbackName);
      userName.value = fallbackName;
    } else {
      userName.value = existingName;
    }

    userEmail.value = email;
    isLoggedIn.value = true;
    return true;
  }

  /// Simulate signup with name, email & password.
  /// Returns `true` on success.
  Future<bool> signup(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isEmpty || email.isEmpty || password.isEmpty) return false;

    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _prefs.setString(_tokenKey, mockToken);
    await _prefs.setString(_nameKey, name);
    await _prefs.setString(_emailKey, email);

    userName.value = name;
    userEmail.value = email;
    isLoggedIn.value = true;
    return true;
  }

  /// Simulate forgot-password request.
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));

    Get.snackbar(
      'reset_email_sent'.tr,
      email,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear all auth data and log out.
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);

    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
  }
}
