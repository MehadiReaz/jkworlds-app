// lib/data/services/auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/user_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import 'package:jkworlds/firebase_options.dart';
import 'package:jkworlds/data/services/notification_service.dart';

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
  final currentUser   = Rxn<UserModel>();
  final userName      = ''.obs;
  final userEmail     = ''.obs;
  final userPhone     = ''.obs;
  final userAddress   = ''.obs;
  final userPhotoUrl  = ''.obs;
  final isSocialLoading = false.obs;
  bool _isGoogleSignInInitialized = false;

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
        currentUser.value = user;
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
      ApiConstants.login,
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
    Get.find<NotificationService>().uploadDeviceToken();
  }

  /// Register a new account.
  Future<void> signup(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await _api.post(
      ApiConstants.register,
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
    Get.find<NotificationService>().uploadDeviceToken();
  }

  /// Forgot password — returns the server's success message (e.g. "OTP sent").
  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      ApiConstants.forgotPassword,
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
  }) async {
    final response = await _api.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
      },
    );

    _requireSuccess(response, fallbackMessage: 'Password reset failed');
  }

  /// Update profile on the server, then sync local state and prefs.
  /// Uses POST /api/profile with _method=PUT (Laravel method-spoofing).
  /// When [imagePath] is a local file path, sends it as a real MultipartFile
  /// so the server can validate and store it as an image.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? imagePath,
    String? city,
    String? country,
    String? countryCode,
    String? dateOfBirth,
    String? licenseNumber,
    String? licenseExpiry,
  }) async {
    if (name.isEmpty || email.isEmpty) {
      throw const ServerException('Name and email are required.');
    }

    // Build FormData so text fields AND the file all travel as multipart/form-data.
    // The API uses POST + _method=PUT (Laravel method-spoofing).
    final fields = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      '_method': 'PUT',
      if (city != null && city.isNotEmpty) 'city': city,
      if (country != null && country.isNotEmpty) 'country': country,
      if (countryCode != null && countryCode.isNotEmpty) 'country_code': countryCode,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
      if (licenseNumber != null && licenseNumber.isNotEmpty) 'license_number': licenseNumber,
      if (licenseExpiry != null && licenseExpiry.isNotEmpty) 'license_expiry': licenseExpiry,
    };

    // Attach the image as a real file when a local path is given
    final bool hasLocalImage = imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('http') &&
        File(imagePath).existsSync();

    dio.FormData formData;
    if (hasLocalImage) {
      formData = dio.FormData.fromMap({
        ...fields,
        'image': await dio.MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
    } else {
      formData = dio.FormData.fromMap(fields);
    }

    final response = await _api.postFormData(ApiConstants.profile, formData);

    final data = _requireSuccess(response, fallbackMessage: 'Profile update failed');

    // Prefer the server's returned UserResource so server-side
    // normalizations (e.g. uppercase country, stored image URL) are
    // reflected locally instead of using stale form values.
    final userMap = data.isNotEmpty ? data : null;
    if (userMap != null) {
      final user = UserModel.fromJson(userMap);
      await _persistSession(_prefs.getString(_tokenKey) ?? '', user);
      _hydrateState(user);
    } else {
      // Fallback: merge form values into the stored model
      await _mergeAndPersistProfileUpdate(
        name: name,
        email: email,
        phone: phone,
        address: address,
        imagePath: imagePath,
        city: city,
        country: country,
        countryCode: countryCode,
        dateOfBirth: dateOfBirth,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
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
  }

  /// Change password on the server.
  /// Uses POST /api/password with _method=put (Laravel method-spoofing).
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _api.post(
      ApiConstants.password,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
        '_method': 'put',
      },
    );

    _requireSuccess(response, fallbackMessage: 'Password change failed');
  }

  /// Verify OTP — used for email verification or forgot-password flow.
  /// Returns the server success message.
  Future<String> verifyOtp({
    required String otp,
    required String email
  }) async {
    final response = await _api.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp': otp},
    );

    final data = _requireSuccess(response, fallbackMessage: 'OTP verification failed');
    final isVerified = data['verified'] as bool? ?? false;
    if (!isVerified) {
      final msg = response.data?['message'] as String? ?? 'Invalid or expired OTP.';
      throw ServerException(msg);
    }
    return response.data['message'] as String? ?? 'OTP verified successfully';
  }

  /// Delete the authenticated user's account.
  /// POST /api/account with _method=DELETE (Laravel method-spoofing).
  Future<void> deleteAccount() async {
    try {
      final response = await _api.post(
        ApiConstants.account,
        data: {'_method': 'DELETE'},
      );
      _requireSuccess(response, fallbackMessage: 'Failed to delete account');
    } finally {
      await logout();
    }
  }

  /// Manually trigger token refresh.
  Future<void> refreshToken() async {
    final oldToken = _prefs.getString(_tokenKey);
    if (oldToken == null || oldToken.isEmpty) return;

    try {
      final response = await _api.post(ApiConstants.refreshToken);
      final body = response.data;
      if (body != null) {
        final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
        if (success && body['data'] != null) {
          final newToken = body['data']['token'] as String?;
          if (newToken != null && newToken.isNotEmpty) {
            await _prefs.setString(_tokenKey, newToken);
          }
        }
      }
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[AuthService] refreshToken error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Fetch the authenticated user's profile from the server
  /// and refresh local state and persisted cache.
  Future<void> fetchProfile() async {
    if (!isLoggedIn.value) return;
    try {
      final response = await _api.get(ApiConstants.user);

      final body = response.data;
      if (body == null) return;

      // The /user endpoint may return the user directly or inside a data wrapper
      final userMap = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body is Map<String, dynamic>
              ? body
              : null;

      if (userMap == null) return;

      // If data contains a 'user' key, unwrap it
      final rawUser = userMap['user'] is Map<String, dynamic>
          ? userMap['user'] as Map<String, dynamic>
          : userMap;

      final user = UserModel.fromJson(rawUser);
      await _persistSession(_prefs.getString(_tokenKey) ?? '', user);
      _hydrateState(user);
    } catch (e) {
      logger.w('[AuthService] fetchProfile failed (non-fatal): $e');
    }
  }

  // ── Social Auth ──────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    isSocialLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      if (!_isGoogleSignInInitialized) {
        await googleSignIn.initialize(
          clientId: kIsWeb || Platform.isIOS ? DefaultFirebaseOptions.ios.iosClientId : null,
        );
        _isGoogleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const ServerException('Failed to get Firebase User details.');
      }

      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw const ServerException('Failed to retrieve Firebase ID token.');
      }

      // POST to /api/auth/firebase-login
      final response = await _api.post(
        '/api/auth/firebase-login',
        data: {
          'firebase_token': idToken,
          'name': firebaseUser.displayName,
        },
      );

      final data = _requireSuccess(response, fallbackMessage: 'Google login failed');
      final token = data['token'] as String?;
      final userMap = data['user'] as Map<String, dynamic>?;

      if (token == null || userMap == null) {
        throw const ServerException('Malformed response from server.');
      }

      final user = UserModel.fromJson(userMap);
      await _persistSession(token, user);
      _hydrateState(user);
      isLoggedIn.value = true;
      Get.find<NotificationService>().uploadDeviceToken();
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        logger.i('[AuthService] Google Sign-In cancelled by user.');
        return false;
      }
      logger.e('[AuthService] Google Sign-In exception: $e');
      throw UnknownException(e.description ?? 'Google Sign-In failed.');
    } on FirebaseAuthException catch (e) {
      logger.e('[AuthService] Firebase Auth error: ${e.message}', error: e);
      throw UnknownException(e.message ?? 'Firebase authentication failed.');
    } catch (e) {
      logger.e('[AuthService] Google Sign-In error: $e');
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(e.toString());
    } finally {
      isSocialLoading.value = false;
    }
  }

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
      await _api.post(ApiConstants.logout);
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

    // API returns "success": true/false (not "status")
    final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
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
    currentUser.value  = user;
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
    String? city,
    String? country,
    String? countryCode,
    String? dateOfBirth,
    String? licenseNumber,
    String? licenseExpiry,
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
        countryCode: countryCode ?? existing.countryCode,
        phone: phone,
        dateOfBirth: dateOfBirth ?? existing.dateOfBirth,
        address: address,
        city: city ?? existing.city,
        country: country ?? existing.country,
        licenseNumber: licenseNumber ?? existing.licenseNumber,
        licenseExpiry: licenseExpiry ?? existing.licenseExpiry,
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

  /// Updates onboarding preferences via PUT /api/profile JSON call.
  Future<UserModel> updateOnboardingPreferences({
    required String preferredCurrency,
    required String preferredService,
    required String city,
    required String country,
    required String phone,
    required String countryCode,
    required String dateOfBirth,
  }) async {
    final response = await _api.put(
      ApiConstants.profile,
      data: {
        'preferred_currency': preferredCurrency,
        'preferred_service': preferredService,
        'city': city,
        'country': country,
        'phone': phone,
        'country_code': countryCode,
        'date_of_birth': dateOfBirth,
        'onboarding_completed': true,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Empty response from profile update');
    }

    final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
    if (!success) {
      final msg = body['message'] as String? ?? 'Failed to update preferences';
      throw ServerException(msg);
    }

    final data = body['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw const ServerException('Invalid user detail response');
    }

    final user = UserModel.fromJson(data);
    await _persistSession(_prefs.getString(_tokenKey) ?? '', user);
    _hydrateState(user);
    return user;
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
    currentUser.value  = null;
    isLoggedIn.value   = false;
    userName.value     = '';
    userEmail.value    = '';
    userPhone.value    = '';
    userAddress.value  = '';
    userPhotoUrl.value = '';
  }
}