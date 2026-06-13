import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/user_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

/// Global auth service — single source of truth for authentication state.
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
  ApiProvider get _api => Get.find<ApiProvider>();

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
      final userJson = _prefs.getString('auth_user');
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userJson));
          final user = UserModel.fromJson(userMap);
          userName.value = user.name ?? '';
          userEmail.value = user.email ?? '';
          userPhone.value = user.phone ?? '';
          userAddress.value = user.address ?? '';
          userPhotoUrl.value = user.image ?? '';
        } catch (e) {
          logger.e('[AuthService] Error restoring session user: $e');
        }
      } else {
        userName.value = _prefs.getString(_nameKey) ?? '';
        userEmail.value = _prefs.getString(_emailKey) ?? '';
        userPhone.value = _prefs.getString(_phoneKey) ?? '';
        userAddress.value = _prefs.getString(_addressKey) ?? '';
        userPhotoUrl.value = _prefs.getString(_photoKey) ?? '';
      }
    }
  }

  // ── Auth Actions ──────────────────────────────────────────────

  /// Login with email & password using real backend API.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post(
        '/api/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        if (success && response.data['data'] != null) {
          final token = response.data['data']['token'] as String?;
          final userMap =
              response.data['data']['user'] as Map<String, dynamic>?;

          if (token != null && userMap != null) {
            final user = UserModel.fromJson(userMap);

            // Persist locally
            await _prefs.setString(_tokenKey, token);
            await _prefs.setString('auth_user', jsonEncode(user.toJson()));

            // Populate reactive state
            userName.value = user.name ?? '';
            userEmail.value = user.email ?? '';
            userPhone.value = user.phone ?? '';
            userAddress.value = user.address ?? '';
            userPhotoUrl.value = user.image ?? '';
            isLoggedIn.value = true;

            return true;
          }
        }
        final message = response.data['message'] as String? ?? 'Login failed';
        throw message;
      }
      throw 'Server error: ${response.statusCode}';
    } catch (e) {
      logger.e('[AuthService] Login error: $e');
      rethrow;
    }
  }

  /// Signup with name, email, password & confirmation using real backend API.
  Future<bool> signup(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await _api.post(
        '/api/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        if (success && response.data['data'] != null) {
          final token = response.data['data']['token'] as String?;
          final userMap =
              response.data['data']['user'] as Map<String, dynamic>?;

          if (token != null && userMap != null) {
            final user = UserModel.fromJson(userMap);

            // Persist locally
            await _prefs.setString(_tokenKey, token);
            await _prefs.setString('auth_user', jsonEncode(user.toJson()));

            // Populate reactive state
            userName.value = user.name ?? '';
            userEmail.value = user.email ?? '';
            userPhone.value = user.phone ?? '';
            userAddress.value = user.address ?? '';
            userPhotoUrl.value = user.image ?? '';
            isLoggedIn.value = true;

            return true;
          }
        }
        final message =
            response.data['message'] as String? ?? 'Registration failed';
        throw message;
      }
      throw 'Server error: ${response.statusCode}';
    } catch (e) {
      logger.e('[AuthService] Signup error: $e');
      rethrow;
    }
  }

  /// Sign in with Google (Mocked).
  Future<bool> signInWithGoogle() async {
    isSocialLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      const name = 'John Doe';
      const email = 'john.doe@gmail.com';
      const photoUrl = '';

      final mockToken = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_tokenKey, mockToken);

      final mockUser = UserModel(
        name: name,
        email: email,
        image: photoUrl,
        status: 'active',
      );
      await _prefs.setString('auth_user', jsonEncode(mockUser.toJson()));

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

  /// Sign in with Apple (Mocked).
  Future<bool> signInWithApple() async {
    isSocialLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      const name = 'John Doe (Apple)';
      const email = 'john.doe@apple.com';
      const photoUrl = '';

      final mockToken = 'apple_token_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_tokenKey, mockToken);

      final mockUser = UserModel(
        name: name,
        email: email,
        image: photoUrl,
        status: 'active',
      );
      await _prefs.setString('auth_user', jsonEncode(mockUser.toJson()));

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

  /// Request password reset link/OTP.
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _api.post(
        '/api/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        final message =
            response.data['message'] as String? ?? 'OTP sent successfully';
        if (!success) {
          throw message;
        }
        return message;
      }
      throw 'Server error: ${response.statusCode}';
    } catch (e) {
      logger.e('[AuthService] Forgot password error: $e');
      rethrow;
    }
  }

  /// Reset password using OTP code.
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _api.post(
        '/api/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        final message =
            response.data['message'] as String? ?? 'Reset password failed';
        if (!success) {
          throw message;
        }
        return true;
      }
      throw 'Server error: ${response.statusCode}';
    } catch (e) {
      logger.e('[AuthService] Reset password error: $e');
      rethrow;
    }
  }

  /// Clear all auth data locally and attempt API logout.
  Future<void> logout() async {
    try {
      await _api.post('/api/logout');
    } catch (e) {
      logger.e('[AuthService] Logout API request failed: $e');
    } finally {
      await _prefs.remove(_tokenKey);
      await _prefs.remove('auth_user');
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

      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Update personal profile information locally and sync storage.
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String imagePath,
  }) async {
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

    final userJson = _prefs.getString('auth_user');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userMap = Map<String, dynamic>.from(jsonDecode(userJson));
        final user = UserModel.fromJson(userMap);
        final updatedUser = UserModel(
          id: user.id,
          userCode: user.userCode,
          username: user.username,
          name: name,
          email: email,
          emailVerifiedAt: user.emailVerifiedAt,
          role: user.role,
          image: imagePath.isNotEmpty ? imagePath : user.image,
          status: user.status,
          onboardingCompleted: user.onboardingCompleted,
          preferredLanguage: user.preferredLanguage,
          preferredCountry: user.preferredCountry,
          preferredCurrency: user.preferredCurrency,
          preferredTimezone: user.preferredTimezone,
          preferredService: user.preferredService,
          locationLatitude: user.locationLatitude,
          locationLongitude: user.locationLongitude,
          countryCode: user.countryCode,
          phone: phone,
          dateOfBirth: user.dateOfBirth,
          address: address,
          city: user.city,
          country: user.country,
          licenseNumber: user.licenseNumber,
          licenseExpiry: user.licenseExpiry,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          googleId: user.googleId,
          appleId: user.appleId,
        );
        await _prefs.setString('auth_user', jsonEncode(updatedUser.toJson()));
      } catch (e) {
        logger.e('[AuthService] Error updating auth_user JSON: $e');
      }
    }

    return true;
  }

  /// Update password mock method.
  Future<bool> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return newPassword.length >= 6;
  }
}
