// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/user_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class AuthService extends GetxService {
  // ── Prefs Keys ────────────────────────────────────────────────
  static const _tokenKey     = 'auth_token';
  static const _userKey      = 'auth_user';
  static const _nameKey      = 'auth_user_name';
  static const _emailKey     = 'auth_user_email';
  static const _phoneKey     = 'auth_user_phone';
  static const _addressKey   = 'auth_user_address';
  static const _photoKey     = 'auth_user_photo';

  // ── Reactive State ────────────────────────────────────────────
  final isLoggedIn    = false.obs;
  final userName      = ''.obs;
  final userEmail     = ''.obs;
  final userPhone     = ''.obs;
  final userAddress   = ''.obs;
  final userPhotoUrl  = ''.obs;
  final isSocialLoading = false.obs;

  SharedPreferences get _prefs => Get.find<SharedPreferences>();
  ApiProvider       get _api   => Get.find<ApiProvider>();

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  void _restoreSession() {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) return;

      isLoggedIn.value = true;

      final userJson = _prefs.getString(_userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(userJson) as Map),
        );
        _hydrateState(user);
      } else {
        // Fallback: legacy flat keys
        userName.value     = _prefs.getString(_nameKey)    ?? '';
        userEmail.value    = _prefs.getString(_emailKey)   ?? '';
        userPhone.value    = _prefs.getString(_phoneKey)   ?? '';
        userAddress.value  = _prefs.getString(_addressKey) ?? '';
        userPhotoUrl.value = _prefs.getString(_photoKey)   ?? '';
      }
    } catch (e) {
      // Corrupt prefs — start clean rather than crashing
      logger.e('[AuthService] Failed to restore session: $e');
      _clearPrefs();
    }
  }

  // ── Auth Actions ──────────────────────────────────────────────

  /// Login with email & password.
  /// Throws [ServerException] on API-level failures, [AppException] subtypes
  /// for network/auth errors (propagated from [ApiProvider]).
  Future<void> login(String email, String password) async {
    final response = await _api.post(
      '/api/login',
      data: {'email': email, 'password': password},
    );

    final data = _requireSuccess(response, fallbackMessage: 'Login failed');
    final token   = data['token']  as String?;
    final userMap = data['user']   as Map<String, dynamic>?;

    if (token == null || userMap == null) {
      throw const ServerException('Malformed login response from server.');
    }

    final user = UserModel.fromJson(userMap);
    await _persistSession(token, user);
    _hydrateState(user);
    isLoggedIn.value = true;
  }

  /// Register a new account.
  Future<void> signup(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await _api.post(
      '/api/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = _requireSuccess(response, fallbackMessage: 'Registration failed');
    final token   = data['token'] as String?;
    final userMap = data['user']  as Map<String, dynamic>?;

    if (token == null || userMap == null) {
      throw const ServerException('Malformed registration response from server.');
    }

    final user = UserModel.fromJson(userMap);
    await _persistSession(token, user);
    _hydrateState(user);
    isLoggedIn.value = true;
  }

  /// Forgot password — returns the server's success message (e.g. "OTP sent").
  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      '/api/forgot-password',
      data: {'email': email},
    );

    _requireSuccess(response, fallbackMessage: 'Failed to send OTP');
    return response.data['message'] as String? ?? 'OTP sent successfully';
  }

  /// Reset password with OTP.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post(
      '/api/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    _requireSuccess(response, fallbackMessage: 'Password reset failed');
  }

  /// Update profile on the server, then sync local state and prefs.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? imagePath,
  }) async {
    if (name.isEmpty || email.isEmpty) {
      throw const ServerException('Name and email are required.');
    }

    final response = await _api.put(
      '/api/profile',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        if (imagePath != null && imagePath.isNotEmpty) 'image': imagePath,
      },
    );

    _requireSuccess(response, fallbackMessage: 'Profile update failed');

    // Merge into the stored UserModel so nothing is lost
    await _mergeAndPersistProfileUpdate(
      name: name,
      email: email,
      phone: phone,
      address: address,
      imagePath: imagePath,
    );

    // Sync flat fallback keys
    await _prefs.setString(_nameKey, name);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_phoneKey, phone);
    await _prefs.setString(_addressKey, address);
    if (imagePath != null && imagePath.isNotEmpty) {
      await _prefs.setString(_photoKey, imagePath);
    }

    userName.value     = name;
    userEmail.value    = email;
    userPhone.value    = phone;
    userAddress.value  = address;
    if (imagePath != null && imagePath.isNotEmpty) {
      userPhotoUrl.value = imagePath;
    }
  }

  /// Change password on the server.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _api.put(
      '/api/change-password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    _requireSuccess(response, fallbackMessage: 'Password change failed');
  }

  // ── Social Auth (mocked) ──────────────────────────────────────

  Future<bool> signInWithGoogle() => _mockSocialLogin(
        name: 'John Doe',
        email: 'john.doe@gmail.com',
        tokenPrefix: 'google_token',
      );

  Future<bool> signInWithApple() => _mockSocialLogin(
        name: 'John Doe (Apple)',
        email: 'john.doe@apple.com',
        tokenPrefix: 'apple_token',
      );

  Future<bool> _mockSocialLogin({
    required String name,
    required String email,
    required String tokenPrefix,
  }) async {
    isSocialLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final token = '${tokenPrefix}_${DateTime.now().millisecondsSinceEpoch}';
      final user  = UserModel(name: name, email: email, status: 'active');

      await _persistSession(token, user);
      _hydrateState(user);
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      logger.e('[AuthService] Social sign-in error: $e');
      return false;
    } finally {
      isSocialLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  /// Clears local state and calls the logout endpoint (best-effort).
  Future<void> logout() async {
    try {
      await _api.post('/api/logout');
    } catch (e) {
      // Non-fatal: always clear local state even if the server call fails
      logger.w('[AuthService] Logout API call failed (proceeding anyway): $e');
    } finally {
      await _clearPrefs();
      _clearState();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ── Private Helpers ───────────────────────────────────────────

  /// Asserts that the response carries `"status": true` and returns `data`.
  /// Throws [ServerException] with the server's message on failure.
  Map<String, dynamic> _requireSuccess(
    dynamic response, {
    required String fallbackMessage,
  }) {
    final body = response.data;
    if (body == null) throw ServerException(fallbackMessage);

    final success = body['status'] as bool? ?? false;
    if (!success) {
      final msg = body['message'] as String? ?? fallbackMessage;
      throw ServerException(msg);
    }

    final data = body['data'];
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;

    // Some endpoints return `data` as a plain bool (true/false) on success
    return {};
  }

  /// Writes token + serialised user to SharedPreferences.
  Future<void> _persistSession(String token, UserModel user) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Copies [UserModel] fields into the reactive observables.
  void _hydrateState(UserModel user) {
    userName.value     = user.name    ?? '';
    userEmail.value    = user.email   ?? '';
    userPhone.value    = user.phone   ?? '';
    userAddress.value  = user.address ?? '';
    userPhotoUrl.value = user.image   ?? '';
  }

  /// Reads the stored [UserModel], applies the profile diff, and saves it back.
  Future<void> _mergeAndPersistProfileUpdate({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? imagePath,
  }) async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null || userJson.isEmpty) return;

    try {
      final existing = UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(userJson) as Map),
      );
      final updated = UserModel(
        id: existing.id,
        userCode: existing.userCode,
        username: existing.username,
        name: name,
        email: email,
        emailVerifiedAt: existing.emailVerifiedAt,
        role: existing.role,
        image: (imagePath != null && imagePath.isNotEmpty)
            ? imagePath
            : existing.image,
        status: existing.status,
        onboardingCompleted: existing.onboardingCompleted,
        preferredLanguage: existing.preferredLanguage,
        preferredCountry: existing.preferredCountry,
        preferredCurrency: existing.preferredCurrency,
        preferredTimezone: existing.preferredTimezone,
        preferredService: existing.preferredService,
        locationLatitude: existing.locationLatitude,
        locationLongitude: existing.locationLongitude,
        countryCode: existing.countryCode,
        phone: phone,
        dateOfBirth: existing.dateOfBirth,
        address: address,
        city: existing.city,
        country: existing.country,
        licenseNumber: existing.licenseNumber,
        licenseExpiry: existing.licenseExpiry,
        createdAt: existing.createdAt,
        updatedAt: existing.updatedAt,
        googleId: existing.googleId,
        appleId: existing.appleId,
      );
      await _prefs.setString(_userKey, jsonEncode(updated.toJson()));
    } catch (e) {
      logger.e('[AuthService] Failed to merge profile update: $e');
    }
  }

  Future<void> _clearPrefs() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_userKey),
      _prefs.remove(_nameKey),
      _prefs.remove(_emailKey),
      _prefs.remove(_phoneKey),
      _prefs.remove(_addressKey),
      _prefs.remove(_photoKey),
    ]);
  }

  void _clearState() {
    isLoggedIn.value   = false;
    userName.value     = '';
    userEmail.value    = '';
    userPhone.value    = '';
    userAddress.value  = '';
    userPhotoUrl.value = '';
  }
}