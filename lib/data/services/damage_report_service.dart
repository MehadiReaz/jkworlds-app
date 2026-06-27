import 'dart:io';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/damage_report_model.dart';

/// Service for managing damage reports associated with vehicle bookings.
class DamageReportService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  /// Fetch all damage reports for the authenticated user.
  /// GET /api/damage-reports
  Future<List<DamageReportModel>> fetchDamageReports() async {
    try {
      final response = await _api.get(ApiConstants.damageReports);
      final body = response.data;
      if (body == null) return [];

      final List<dynamic> list;
      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic>) {
        list = body['data'] is List ? body['data'] as List : [];
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(DamageReportModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[DamageReportService] fetchDamageReports error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Fetch details of a single damage report.
  /// GET /api/damage-reports/{id}
  Future<DamageReportModel> fetchDamageReportDetail(dynamic id) async {
    try {
      final response = await _api.get(ApiConstants.damageReportDetail(id));
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid response');
      }

      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return DamageReportModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[DamageReportService] fetchDamageReportDetail error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Create a new damage report with description and optional photos.
  /// POST /api/damage-reports
  Future<DamageReportModel> createDamageReport({
    required String bookingId,
    required String description,
    List<String>? imagePaths,
  }) async {
    try {
      final fields = <String, dynamic>{
        'booking_id': bookingId,
        'description': description,
      };

      if (imagePaths != null && imagePaths.isNotEmpty) {
        final List<MultipartFile> files = [];
        for (final path in imagePaths) {
          if (path.isNotEmpty && File(path).existsSync()) {
            final file = await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            );
            files.add(file);
          }
        }
        if (files.isNotEmpty) {
          fields['images[]'] = files;
        }
      }

      final formData = FormData.fromMap(fields);
      final response = await _api.postFormData(
        ApiConstants.damageReports,
        formData,
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid response');
      }

      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return DamageReportModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[DamageReportService] createDamageReport error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}
