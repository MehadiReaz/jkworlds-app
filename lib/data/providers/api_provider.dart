import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

/// Centralized Dio HTTP client with interceptors.
class ApiProvider {
  late final Dio dio;

  ApiProvider() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptors ──────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final prefs = Get.find<SharedPreferences>();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          logger.i('REQUEST: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i(
            'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          logger.e('ERROR: ${error.response?.statusCode} ${error.message}');

          if (error.response?.statusCode == 401) {
            final prefs = Get.find<SharedPreferences>();
            final oldToken = prefs.getString('auth_token');
            if (oldToken != null && oldToken.isNotEmpty) {
              final isRefreshRequest = error.requestOptions.path.contains(
                'refresh-token',
              );
              if (!isRefreshRequest) {
                logger.i(
                  '[ApiProvider] 401 Unauthorized. Attempting to refresh token...',
                );
                final newToken = await _refreshToken(oldToken);
                if (newToken != null && newToken.isNotEmpty) {
                  logger.i(
                    '[ApiProvider] Token refreshed successfully. Retrying original request...',
                  );
                  await prefs.setString('auth_token', newToken);

                  // Retry the original request with the new token
                  final requestOptions = error.requestOptions;
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';

                  try {
                    final response = await dio.fetch(requestOptions);
                    return handler.resolve(response);
                  } on DioException catch (retryError) {
                    return handler.next(retryError);
                  }
                } else {
                  logger.w(
                    '[ApiProvider] Token refresh failed. Logging out...',
                  );
                  if (Get.isRegistered<AuthService>()) {
                    await Get.find<AuthService>().logout();
                  }
                  Get.offAllNamed(AppRoutes.login);
                }
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Helper to refresh the JWT token using a temporary Dio instance
  Future<String?> _refreshToken(String oldToken) async {
    try {
      final tempDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $oldToken',
          },
        ),
      );
      final response = await tempDio.post('/api/refresh-token');
      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        if (success && response.data['data'] != null) {
          final newToken = response.data['data']['token'] as String?;
          return newToken;
        }
      }
    } catch (e) {
      logger.e('[ApiProvider] Failed to refresh token: $e');
    }
    return null;
  }

  // ── Convenience Methods ─────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
