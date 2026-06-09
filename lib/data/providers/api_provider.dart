import 'package:dio/dio.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/utils/logger.dart';

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
          // TODO: Attach auth token from storage if available
          // options.headers['Authorization'] = 'Bearer $token';
          _log('REQUEST', '${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log('RESPONSE', '${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          _log('ERROR', '${error.response?.statusCode} ${error.message}');
          handler.next(error);
        },
      ),
    );
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

  // ── Logger ──────────────────────────────────────────────────────

  void _log(String tag, String message) {
    if (tag == 'ERROR') {
      logger.e('[$tag] $message');
    } else {
      logger.i('[$tag] $message');
    }
  }
}
