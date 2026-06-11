import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/utils/logger.dart';

/// Global auth service — single source of truth for authentication state.
///
/// Uses [SharedPreferences] to simulate token-based auth locally.
/// Register once in [InitialBinding] as a permanent service.
class AuthService extends GetxService {
  // ── Keys ──────────────────────────────────────────────────────
  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_user_name';
  static const _emailKey = 'auth_user_email';
  static const _phoneKey = 'auth_user_phone';
  static const _addressKey = 'auth_user_address';
  static const _photoKey = 'auth_user_photo';

  // ── Reactive State ────────────────────────────────────────────
  final isLoggedIn = false.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userAddress = ''.obs;
  final userPhotoUrl = ''.obs;

  // ── Social Auth State ────────────────────────────────────────
  final isSocialLoading = false.obs;

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
      userPhone.value = _prefs.getString(_phoneKey) ?? '';
      userAddress.value = _prefs.getString(_addressKey) ?? '';
      userPhotoUrl.value = _prefs.getString(_photoKey) ?? '';
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

  /// Sign in with Google.
  ///
  /// Currently mocks the flow. When the Google Sign-In API is ready,
  /// replace the TODO-marked section with the real implementation.
  /// Returns `true` on success.
  Future<bool> signInWithGoogle() async {
    isSocialLoading.value = true;

    try {
      // TODO: Replace with real Google Sign-In flow:
      //
      //   final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      //   final googleUser = await googleSignIn.signIn();
      //   if (googleUser == null) { isSocialLoading.value = false; return false; }
      //
      //   final googleAuth = await googleUser.authentication;
      //   final credential = GoogleAuthProvider.credential(
      //     accessToken: googleAuth.accessToken,
      //     idToken: googleAuth.idToken,
      //   );
      //
      //   // Send credential/token to your backend for verification:
      //   // final response = await _api.socialLogin('google', googleAuth.idToken);
      //
      //   final name = googleUser.displayName ?? '';
      //   final email = googleUser.email;
      //   final photoUrl = googleUser.photoUrl ?? '';

      // ── Mock implementation ──────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 1000));

      const name = 'John Doe';
      const email = 'john.doe@gmail.com';
      const photoUrl = '';

      final mockToken = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_tokenKey, mockToken);
      await _prefs.setString(_nameKey, name);
      await _prefs.setString(_emailKey, email);

      userName.value = name;
      userEmail.value = email;
      userPhotoUrl.value = photoUrl;
      isLoggedIn.value = true;

      isSocialLoading.value = false;
      return true;
    } catch (e) {
      isSocialLoading.value = false;
      logger.e('[AuthService] Google Sign-In error: $e');
      return false;
    }
  }

  /// Sign in with Apple.
  ///
  /// Currently mocks the flow.
  /// Returns `true` on success.
  Future<bool> signInWithApple() async {
    isSocialLoading.value = true;
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      const name = 'John Doe (Apple)';
      const email = 'john.doe@apple.com';
      const photoUrl = '';

      final mockToken = 'apple_token_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_tokenKey, mockToken);
      await _prefs.setString(_nameKey, name);
      await _prefs.setString(_emailKey, email);

      userName.value = name;
      userEmail.value = email;
      userPhotoUrl.value = photoUrl;
      isLoggedIn.value = true;

      isSocialLoading.value = false;
      return true;
    } catch (e) {
      isSocialLoading.value = false;
      logger.e('[AuthService] Apple Sign-In error: $e');
      return false;
    }
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
    // TODO: If signed in via Google, also sign out:
    //   await GoogleSignIn().signOut();

    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_phoneKey);
    await _prefs.remove(_addressKey);
    await _prefs.remove(_photoKey);

    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    userAddress.value = '';
    userPhotoUrl.value = '';
  }

  /// Update personal profile information.
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String imagePath,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isEmpty || email.isEmpty) return false;

    await _prefs.setString(_nameKey, name);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_phoneKey, phone);
    await _prefs.setString(_addressKey, address);
    if (imagePath.isNotEmpty) {
      await _prefs.setString(_photoKey, imagePath);
      userPhotoUrl.value = imagePath;
    }

    userName.value = name;
    userEmail.value = email;
    userPhone.value = phone;
    userAddress.value = address;
    return true;
  }

  /// Update password mock method.
  Future<bool> updatePassword(String newPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return newPassword.length >= 6;
  }
}
