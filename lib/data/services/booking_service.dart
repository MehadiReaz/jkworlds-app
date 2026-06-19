// lib/data/services/booking_service.dart

import 'package:get/get.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/providers/api_provider.dart';

class BookingService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  // ── Reactive State ─────────────────────────────────────────────
  final bookings = <BookingModel>[].obs;
  final isLoading = false.obs;

  // ── Fetch All Bookings ─────────────────────────────────────────

  /// Fetch the current user's bookings from GET /api/bookings.
  Future<List<BookingModel>> fetchBookings() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiConstants.bookings);
      final body = response.data;
      if (body == null) return [];

      final list = _extractList(body);
      final result = list
          .whereType<Map<String, dynamic>>()
          .map(BookingModel.fromJson)
          .toList();

      bookings.value = result;
      return result;
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] fetchBookings error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fetch Single Booking ───────────────────────────────────────

  /// Fetch the details of a single booking from GET /api/bookings/{id}.
  Future<BookingModel> fetchBookingDetail(int id) async {
    try {
      final response = await _api.get(ApiConstants.bookingDetail(id));
      final body = response.data;
      if (body == null) throw const ServerException('Empty response from server.');

      // Extract the booking map from the response body
      final Map<String, dynamic>? bookingMap = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body is Map<String, dynamic>
              ? body
              : null;

      if (bookingMap == null) {
        throw const ServerException('Malformed booking response from server.');
      }

      // Some APIs nest the booking under a 'booking' key
      final raw = bookingMap['booking'] is Map<String, dynamic>
          ? bookingMap['booking'] as Map<String, dynamic>
          : bookingMap;

      return BookingModel.fromJson(raw);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] fetchBookingDetail error', error: e, stackTrace: st);
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
