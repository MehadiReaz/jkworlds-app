// lib/data/services/category_service.dart

import 'package:get/get.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/category_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'package:jkworlds/data/providers/api_provider.dart';

class CategoryService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  // ── Reactive State ─────────────────────────────────────────────
  final categories = <CategoryModel>[].obs;
  final isLoadingCategories = false.obs;

  // ── Categories ─────────────────────────────────────────────────

  /// Fetch all categories from GET /api/categories.
  Future<List<CategoryModel>> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await _api.get(ApiConstants.categories);
      final body = response.data;
      if (body == null) return [];

      final list = _extractList(body);
      final result = list
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .where((c) => c.status)
          .toList();

      categories.value = result;
      return result;
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[CategoryService] fetchCategories error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ── Vehicles ────────────────────────────────────────────────────

  /// Fetch vehicles for a specific category from
  /// GET /api/categories/{id}/vehicles
  ///
  /// All filter params are optional and passed as query parameters.
  Future<List<VehicleModel>> fetchVehiclesByCategory(
    int categoryId, {
    String? search,
    String? category,
    String? serviceType,   // self-drive | chauffeur
    String? transmission,  // Automatic | Manual
    String? fuelType,      // Petrol | Diesel | Hybrid | Electric
    String? featured,      // 1 | 0
    String? sort,          // e.g. price_asc, price_desc, rating
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (serviceType != null && serviceType.isNotEmpty) queryParams['service_type'] = serviceType;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;
    
    if (transmission != null && transmission.isNotEmpty) {
      final norm = transmission.toLowerCase();
      if (norm.startsWith('auto')) {
        queryParams['transmission'] = 'auto';
      } else if (norm == 'manual') {
        queryParams['transmission'] = 'manual';
      } else {
        queryParams['transmission'] = norm;
      }
    }
    if (fuelType != null && fuelType.isNotEmpty) {
      queryParams['fuel_type'] = fuelType.toLowerCase();
    }
    if (featured != null && featured.isNotEmpty) {
      queryParams['featured'] = featured;
    }
    if (sort != null && sort.isNotEmpty) {
      String normSort = sort.toLowerCase();
      if (normSort == 'price_asc') normSort = 'price_low';
      if (normSort == 'price_desc') normSort = 'price_high';
      if (normSort == 'rating') normSort = 'top_rated';
      queryParams['sort'] = normSort;
    }

    try {
      final response = await _api.get(
        ApiConstants.categoryVehicles(categoryId),
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final body = response.data;
      if (body == null) return [];

      final list = _extractList(body);
      return list
          .whereType<Map<String, dynamic>>()
          .map(VehicleModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[CategoryService] fetchVehiclesByCategory error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  Future<List<VehicleModel>> fetchAllVehicles({
    String? search,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (serviceType != null && serviceType.isNotEmpty) queryParams['service_type'] = serviceType;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      
      if (transmission != null && transmission.isNotEmpty) {
        final norm = transmission.toLowerCase();
        if (norm.startsWith('auto')) {
          queryParams['transmission'] = 'auto';
        } else if (norm == 'manual') {
          queryParams['transmission'] = 'manual';
        } else {
          queryParams['transmission'] = norm;
        }
      }
      if (fuelType != null && fuelType.isNotEmpty) {
        queryParams['fuel_type'] = fuelType.toLowerCase();
      }
      if (featured != null && featured.isNotEmpty) {
        queryParams['featured'] = featured;
      }
      if (sort != null && sort.isNotEmpty) {
        String normSort = sort.toLowerCase();
        if (normSort == 'price_asc') normSort = 'price_low';
        if (normSort == 'price_desc') normSort = 'price_high';
        if (normSort == 'rating') normSort = 'top_rated';
        queryParams['sort'] = normSort;
      }

      final response = await _api.get(
        ApiConstants.vehicles,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final body = response.data;
      if (body == null) return [];

      final list = _extractList(body);
      return list
          .whereType<Map<String, dynamic>>()
          .map(VehicleModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[CategoryService] fetchAllVehicles error using /api/vehicles', error: e, stackTrace: st);
      return [];
    }
  }

  // ── Vehicle Detail ──────────────────────────────────────────────

  /// Fetch a single vehicle's full details from GET /api/vehicles/{id}.
  /// Returns a [VehicleDetailResult] containing the vehicle, similar vehicles,
  /// and reviews as provided by the VehicleDetailResource on the backend.
  Future<VehicleDetailResult> fetchVehicleDetail(dynamic vehicleId) async {
    try {
      final response = await _api.get(ApiConstants.vehicleDetail(vehicleId));
      final body = response.data;
      if (body == null) {
        throw const ServerException('Empty response from server');
      }

      // The API responds with: { "status": true, "message": "...", "data": { ... } }
      final data = body is Map<String, dynamic> ? body['data'] : body;
      if (data == null || data is! Map<String, dynamic>) {
        throw const ServerException('Invalid vehicle detail response');
      }

      // Parse main vehicle
      final vehicle = VehicleModel.fromJson(data);

      // Parse similar vehicles (may be nested under 'similar_vehicles')
      final similarVehiclesRaw = data['similar_vehicles'];
      final List<VehicleModel> similarVehicles = [];
      if (similarVehiclesRaw is List) {
        for (final item in similarVehiclesRaw) {
          if (item is Map<String, dynamic>) {
            similarVehicles.add(VehicleModel.fromJson(item));
          }
        }
      }

      // Parse reviews (may be nested under 'reviews')
      final reviewsRaw = data['reviews'];
      final List<ReviewModel> reviews = [];
      if (reviewsRaw is List) {
        for (final item in reviewsRaw) {
          if (item is Map<String, dynamic>) {
            reviews.add(ReviewModel.fromJson(item));
          }
        }
      }

      return VehicleDetailResult(
        vehicle: vehicle,
        similarVehicles: similarVehicles,
        reviews: reviews,
      );
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[CategoryService] fetchVehicleDetail error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────

  /// Extracts a List from common API response shapes:
  ///   { "data": [...] }  OR  { "data": { "data": [...] } }  OR  [...]
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        // Paginated responses use "items" as the list key
        final items = data['items'];
        if (items is List) return items;
        // Some endpoints nest list under data.data
        final inner = data['data'];
        if (inner is List) return inner;
      }
    }
    return [];
  }
}

/// Result object for vehicle detail API call.
class VehicleDetailResult {
  final VehicleModel vehicle;
  final List<VehicleModel> similarVehicles;
  final List<ReviewModel> reviews;

  const VehicleDetailResult({
    required this.vehicle,
    required this.similarVehicles,
    required this.reviews,
  });
}

