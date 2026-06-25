// lib/data/providers/api_provider.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/network_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

import 'package:jkworlds/app/currency/currency_service.dart';

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

          if (Get.isRegistered<CurrencyService>()) {
            final currencyCode = Get.find<CurrencyService>().selectedCurrency.value.code;
            options.headers['Currency'] = currencyCode;
          }

          logger.i('💡 REQUEST: ${options.method} ${options.uri}');
          if (options.queryParameters.isNotEmpty) {
            logger.i('🔍 QUERY PARAMETERS: ${options.queryParameters}');
          }
          if (options.data != null) {
            String bodyStr;
            if (options.data is FormData) {
              bodyStr = '[FormData fields: ${(options.data as FormData).fields.map((e) => '${e.key}=${e.value}').join(', ')}]';
            } else {
              try {
                if (options.data is Map || options.data is List) {
                  const encoder = JsonEncoder.withIndent('  ');
                  bodyStr = encoder.convert(options.data);
                } else {
                  bodyStr = options.data.toString();
                }
              } catch (_) {
                bodyStr = options.data.toString();
              }
            }
            logger.i('📤 REQUEST BODY:\n$bodyStr');
          }
          handler.next(options);
        },

        onResponse: (response, handler) {
          logger.i('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          String prettyJsonStr;
          try {
            if (response.data is Map || response.data is List) {
              const encoder = JsonEncoder.withIndent('  ');
              prettyJsonStr = encoder.convert(response.data);
            } else {
              prettyJsonStr = response.data?.toString() ?? '';
            }
          } catch (_) {
            prettyJsonStr = response.data?.toString() ?? '';
          }
          logger.i('📥 RESPONSE BODY:\n$prettyJsonStr');
          handler.next(response);
        },

        onError: (error, handler) async {
          logger.e('⛔ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
          if (error.response?.data != null) {
            String prettyErrorStr;
            try {
              final errData = error.response?.data;
              if (errData is Map || errData is List) {
                const encoder = JsonEncoder.withIndent('  ');
                prettyErrorStr = encoder.convert(errData);
              } else {
                prettyErrorStr = errData.toString();
              }
            } catch (_) {
              prettyErrorStr = error.response?.data.toString() ?? '';
            }
            logger.e('⛔ ERROR BODY:\n$prettyErrorStr');
          }

          if (error.response?.statusCode == 401) {
            final prefs = Get.find<SharedPreferences>();
            final oldToken = prefs.getString('auth_token');
            final isRefreshRequest =
                error.requestOptions.path.contains('refresh-token');
            final isLogoutRequest =
                error.requestOptions.path.contains('logout');

            if (oldToken != null && oldToken.isNotEmpty && !isRefreshRequest && !isLogoutRequest) {
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
      final response = await tempDio.post(ApiConstants.refreshToken);

      if (response.statusCode == 200 && response.data != null) {
        // API returns "success": true/false (not "status")
        final success = response.data['success'] as bool? ?? response.data['status'] as bool? ?? false;
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
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          'Connection timed out. Please check your internet and try again.',
        );

      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Request timed out while sending. Please try again.',
        );

      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'The server took too long to respond. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network and try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final serverMessage = _extractServerMessage(e.response);

        if (statusCode == 401) {
          // If the server returned a meaningful message (e.g. "The provided
          // credentials are incorrect" from /api/login), surface it as a
          // ServerException so the UI shows the real reason.
          // Only fall back to AuthException (session expired) when there is
          // no server message — meaning an authenticated endpoint rejected
          // the token.
          if (serverMessage != null && serverMessage.isNotEmpty) {
            return ServerException(serverMessage, statusCode: 401);
          }
          return const AuthException();
        }

        if (statusCode == 422) {
          // Validation error — try to extract field-level messages
          final validationMsg = _extractValidationMessage(e.response);
          return ServerException(
            validationMsg ?? serverMessage ?? 'Validation failed. Please check your input.',
            statusCode: 422,
          );
        }

        return ServerException(
          serverMessage ?? _defaultServerMessage(statusCode),
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Secure connection failed (SSL certificate error).',
        );

      case DioExceptionType.unknown:
        // Catch common socket / host-not-found errors that Dio reports as
        // "unknown" even though they are really connectivity issues.
        final msg = e.message ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Failed host lookup') ||
            msg.contains('Network is unreachable') ||
            msg.contains('Connection refused')) {
          return const NetworkException(
            'No internet connection. Please check your network and try again.',
          );
        }
        return const UnknownException(
          'An unexpected error occurred. Please try again.',
        );
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

  /// Attempts to extract a field-level validation error from a 422 response.
  /// Laravel returns them in the shape: { "errors": { "email": ["message"] } }
  String? _extractValidationMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstField = errors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            return firstField.first.toString();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  String _defaultServerMessage(int? statusCode) => switch (statusCode) {
        400 => 'Bad request. Please check your input.',
        403 => 'You do not have permission to do that.',
        404 => 'The requested resource was not found.',
        408 => 'The server request timed out.',
        429 => 'Too many requests. Please slow down and try again.',
        500 => 'Internal server error. Please try again later.',
        502 => 'Server is temporarily unavailable (bad gateway).',
        503 => 'Service is temporarily unavailable. Please try again later.',
        _ => 'Something went wrong. Please try again.',
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

  /// Sends [formData] as a POST multipart/form-data request.
  /// Dio sets the Content-Type header automatically when FormData is passed.
  /// Use this for file uploads (e.g. profile photo).
  Future<Response> postFormData(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      logger.e('[ApiProvider] Unexpected multipart POST error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}