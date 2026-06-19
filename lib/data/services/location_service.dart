// lib/data/services/location_service.dart

import 'package:get/get.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/location_prediction.dart';

class LocationService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  /// Search locations by query.
  /// GET /api/location/search?q={query}&limit={limit}
  Future<List<LocationPrediction>> searchLocations(String query, {int? limit}) async {
    if (query.trim().isEmpty) return [];

    try {
      final queryParams = {
        'q': query,
        if (limit != null) 'limit': limit,
      };

      final response = await _api.get(
        ApiConstants.locationSearch,
        queryParameters: queryParams,
      );

      final body = response.data;
      if (body == null) return [];

      // API returns "success": true/false (not "status")
      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to search locations';
        throw ServerException(msg);
      }

      final data = body['data'];
      if (data != null && data['results'] is List) {
        final list = data['results'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map(LocationPrediction.fromJson)
            .toList();
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[LocationService] searchLocations error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Fetch details of a specific location.
  /// GET /api/location/details?id={id}
  Future<Map<String, dynamic>?> fetchLocationDetails(String locationId) async {
    if (locationId.trim().isEmpty) return null;

    try {
      final response = await _api.get(
        ApiConstants.locationDetails,
        queryParameters: {'id': locationId},
      );

      final body = response.data;
      if (body == null) return null;

      // API returns "success": true/false (not "status")
      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to fetch location details';
        throw ServerException(msg);
      }

      final data = body['data'];
      if (data != null && data['location'] is Map) {
        return Map<String, dynamic>.from(data['location'] as Map);
      }
      return null;
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[LocationService] fetchLocationDetails error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}
