import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/category_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/location_prediction.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';

class MockCategoryService extends CategoryService {
  MockCategoryService() {
    categories.value = [
      const CategoryModel(id: 1, name: 'Sedan', slug: 'sedan', type: 'sedan', status: true),
      const CategoryModel(id: 2, name: 'SUV', slug: 'suv', type: 'suv', status: true),
      const CategoryModel(id: 3, name: 'Luxury', slug: 'luxury', type: 'luxury', status: true),
      const CategoryModel(id: 4, name: 'Van', slug: 'van', type: 'van', status: true),
    ];
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    return categories;
  }

  @override
  Future<List<VehicleModel>> fetchAllVehicles({
    String? search,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
  }) async {
    return mockVehicles;
  }

  @override
  Future<List<VehicleModel>> fetchVehiclesByCategory(
    int categoryId, {
    String? search,
    String? category,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
  }) async {
    final catName = categoryId == 1
        ? 'Sedan'
        : categoryId == 2
            ? 'SUV'
            : categoryId == 3
                ? 'Luxury'
                : 'Van';
    return mockVehicles.where((v) => v.type.toLowerCase() == catName.toLowerCase()).toList();
  }

  @override
  Future<VehicleDetailResult> fetchVehicleDetail(dynamic vehicleId) async {
    final vehicle = mockVehicles.firstWhere(
      (v) => v.id.toString() == vehicleId.toString(),
      orElse: () => mockVehicles.first,
    );
    return VehicleDetailResult(
      vehicle: vehicle,
      similarVehicles: mockVehicles.where((v) => v.type == vehicle.type && v.id != vehicle.id).toList(),
      reviews: [],
    );
  }
}

class MockBookingService extends BookingService {
  @override
  Future<List<BookingModel>> fetchBookings() async {
    return mockBookings;
  }
}

class MockLocationService extends LocationService {
  @override
  Future<List<LocationPrediction>> searchLocations(String query, {int? limit}) async {
    final suggestions = <LocationPrediction>[
      LocationPrediction(description: 'Lekki Phase 1, Lagos', id: 'lekki_1'),
      LocationPrediction(description: 'Lekki Toll Gate, Lagos', id: 'lekki_2'),
      LocationPrediction(description: 'Victoria Island, Lagos', id: 'vi_1'),
      LocationPrediction(description: 'Maitama, Abuja', id: 'maitama_1'),
    ];
    return suggestions
        .where((p) => p.description.toLowerCase().contains(query.toLowerCase()))
        .take(limit ?? 5)
        .toList();
  }
}
