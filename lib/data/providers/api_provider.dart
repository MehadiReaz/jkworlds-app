// lib/data/providers/api_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/network_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

/// Centralized Dio HTTP client with interceptors and typed exception mapping.
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (Get.isRegistered<NetworkService>() &&
              !Get.find<NetworkService>().isOnline.value) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'No internet connection',
              ),
            );
            return;
          }

          final prefs = Get.find<SharedPreferences>();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          logger.i('REQUEST: ${options.method} ${options.uri}');
          handler.next(options);
        },

        onResponse: (response, handler) {
          logger.i('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('API RESPONSE BODY: ${response.data}');
          handler.next(response);
        },

        onError: (error, handler) async {
          logger.e('ERROR: ${error.response?.statusCode} ${error.message}');
          if (error.response?.data != null) {
            debugPrint('API ERROR RESPONSE BODY: ${error.response?.data}');
          }

          if (error.response?.statusCode == 401) {
            final prefs = Get.find<SharedPreferences>();
            final oldToken = prefs.getString('auth_token');
            final isRefreshRequest =
                error.requestOptions.path.contains('refresh-token');

            if (oldToken != null && oldToken.isNotEmpty && !isRefreshRequest) {
              logger.i('[ApiProvider] 401 detected — attempting token refresh');

              try {
                final newToken = await _refreshToken(oldToken);

                if (newToken != null && newToken.isNotEmpty) {
                  logger.i('[ApiProvider] Token refreshed — retrying request');
                  await prefs.setString('auth_token', newToken);

                  final retryOptions = error.requestOptions
                    ..headers['Authorization'] = 'Bearer $newToken';

                  try {
                    final response = await dio.fetch(retryOptions);
                    return handler.resolve(response);
                  } on DioException catch (retryError) {
                    // Retry itself failed — fall through to propagate
                    return handler.next(retryError);
                  }
                }
              } catch (e) {
                logger.e('[ApiProvider] Unexpected error during token refresh: $e');
              }

              // Refresh failed or returned null — force logout
              logger.w('[ApiProvider] Token refresh failed — logging out');
              if (Get.isRegistered<AuthService>()) {
                await Get.find<AuthService>().logout();
              }
              Get.offAllNamed(AppRoutes.login);

              // Reject with a typed auth error instead of silently swallowing
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  type: DioExceptionType.badResponse,
                  response: error.response,
                  message: 'Session expired. Please log in again.',
                  error: const AuthException(),
                ),
              );
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  // ── Token Refresh ───────────────────────────────────────────────

  Future<String?> _refreshToken(String oldToken) async {
    final tempDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $oldToken',
        },
      ),
    );

    try {
      final response = await tempDio.post('/api/refresh-token');

      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['status'] as bool? ?? false;
        if (success && response.data['data'] != null) {
          return response.data['data']['token'] as String?;
        }
        logger.w('[ApiProvider] Refresh response OK but status=false or missing data');
      } else {
        logger.w('[ApiProvider] Refresh returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('[ApiProvider] DioException during token refresh: ${e.message}');
    } catch (e) {
      logger.e('[ApiProvider] Unexpected error during token refresh: $e');
    }

    return null;
  }

  // ── Exception Mapping ────────────────────────────────────────────

  /// Converts a raw [DioException] into a typed [AppException].
  /// Call this in the catch blocks of all convenience methods.
  AppException _mapDioError(DioException e) {
    // Preserve any AppException already attached (e.g. AuthException from interceptor)
    if (e.error is AppException) return e.error as AppException;

    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          e.message ?? 'Connection failed. Check your internet and try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final serverMessage = _extractServerMessage(e.response);

        if (statusCode == 401) return const AuthException();

        return ServerException(
          serverMessage ?? _defaultServerMessage(statusCode),
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('SSL certificate error.');

      case DioExceptionType.unknown:
      return UnknownException(e.message ?? 'An unexpected error occurred.');
    }
  }

  /// Pulls a human-readable message from the server response body, if present.
  String? _extractServerMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String?;
      }
    } catch (_) {}
    return null;
  }

  String _defaultServerMessage(int? statusCode) => switch (statusCode) {
        400 => 'Bad request.',
        403 => 'You do not have permission to do that.',
        404 => 'Resource not found.',
        408 => 'Request timed out.',
        422 => 'Validation failed.',
        429 => 'Too many requests. Please slow down.',
        500 => 'Internal server error.',
        502 => 'Bad gateway.',
        503 => 'Service temporarily unavailable.',
        _ => 'Something went wrong (HTTP $statusCode).',
      };

  // ── Convenience Methods ──────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      logger.e('[ApiProvider] Unexpected GET error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      logger.e('[ApiProvider] Unexpected POST error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      logger.e('[ApiProvider] Unexpected PUT error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.delete(
          path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      logger.e('[ApiProvider] Unexpected DELETE error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}