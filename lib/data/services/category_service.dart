// lib/data/services/category_service.dart

import 'package:get/get.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/category_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
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
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (serviceType != null && serviceType.isNotEmpty) queryParams['service_type'] = serviceType;
    if (transmission != null && transmission.isNotEmpty) queryParams['transmission'] = transmission;
    if (fuelType != null && fuelType.isNotEmpty) queryParams['fuel_type'] = fuelType;
    if (featured != null && featured.isNotEmpty) queryParams['featured'] = featured;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

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

  /// Fetch vehicles across ALL categories.
  /// Aggregates vehicles concurrently across all categories and deduplicates by ID.
  Future<List<VehicleModel>> fetchAllVehicles({
    String? search,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
  }) async {
    // If no categories are loaded yet, load them first
    if (categories.isEmpty) {
      try {
        await fetchCategories();
      } catch (_) {}
    }

    if (categories.isEmpty) return [];

    try {
      final List<Future<List<VehicleModel>>> futures = categories.map((cat) {
        return fetchVehiclesByCategory(
          cat.id,
          search: search,
          serviceType: serviceType,
          transmission: transmission,
          fuelType: fuelType,
          featured: featured,
          sort: sort,
        );
      }).toList();

      final List<List<VehicleModel>> resultsList = await Future.wait(futures);

      final Set<String> seenIds = {};
      final List<VehicleModel> allVehicles = [];
      for (final list in resultsList) {
        for (final vehicle in list) {
          if (seenIds.add(vehicle.id)) {
            allVehicles.add(vehicle);
          }
        }
      }
      return allVehicles;
    } catch (e, st) {
      logger.e('[CategoryService] fetchAllVehicles error', error: e, stackTrace: st);
      return [];
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
