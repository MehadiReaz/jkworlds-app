// lib/data/services/booking_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/checkout_pricing_model.dart';
import 'package:jkworlds/data/models/initiate_booking_response_model.dart';
import 'package:jkworlds/data/models/cancel_payment_response_model.dart';
import 'package:jkworlds/data/models/airport_transfer_distance_model.dart';
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

  // ── v2 Booking & Checkout Endpoints ──────────────────────────────

  /// Calculate checkout pricing details.
  /// POST /api/v2/checkout
  Future<CheckoutPricingModel> calculateCheckoutPricing(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        ApiConstants.checkout,
        data: data,
      );
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid checkout response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to calculate checkout pricing';
        throw ServerException(msg);
      }

      final resData = body['data'];
      if (resData == null || resData is! Map<String, dynamic>) {
        throw const ServerException('Checkout response missing "data" node');
      }

      return CheckoutPricingModel.fromJson(resData);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] calculateCheckoutPricing error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Initiate a new booking.
  /// POST /api/v2/bookings
  Future<InitiateBookingResponseModel> initiateBooking(
    Map<String, dynamic> data, {
    String? driverLicensePath,
  }) async {
    try {
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey('addon_ids')) {
        map['addon_ids[]'] = map.remove('addon_ids');
      }

      if (driverLicensePath != null && driverLicensePath.isNotEmpty) {
        debugPrint('[BookingService] calling MultipartFile.fromFile with path: $driverLicensePath');
        final file = await MultipartFile.fromFile(
          driverLicensePath,
          filename: driverLicensePath.split('/').last,
        );
        debugPrint('[BookingService] MultipartFile.fromFile succeeded');
        map['driver_license'] = file;
      }

      final formData = FormData.fromMap(map);

      debugPrint('[BookingService] calling postFormData...');
      final response = await _api.postFormData(
        ApiConstants.bookingsV2,
        formData,
      );
      debugPrint('[BookingService] postFormData response status: ${response.statusCode}');
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid bookings response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to initiate booking';
        throw ServerException(msg);
      }

      final resData = body['data'];
      if (resData == null || resData is! Map<String, dynamic>) {
        throw const ServerException('Bookings response missing "data" node');
      }

      return InitiateBookingResponseModel.fromJson(resData);
    } on AppException {
      debugPrint('[BookingService] initiateBooking caught AppException');
      rethrow;
    } catch (e, st) {
      debugPrint('[BookingService] initiateBooking caught other exception: $e\n$st');
      logger.e('[BookingService] initiateBooking error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Confirm/Verify booking payment success.
  /// POST /api/v2/payments/{gateway}/success
  Future<BookingModel> confirmPayment(
    String gateway, {
    required String reference,
    String? transactionId,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.paymentSuccess(gateway),
        data: {
          'reference': reference,
          if (transactionId != null) 'transaction_id': transactionId,
        },
      );
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid payment success response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to confirm payment';
        throw ServerException(msg);
      }

      final resData = body['data'];
      if (resData == null || resData is! Map<String, dynamic>) {
        throw const ServerException('Payment success response missing "data" node');
      }

      return BookingModel.fromJson(resData);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] confirmPayment error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Cancel booking payment.
  /// POST /api/v2/payments/{gateway}/cancel
  Future<CancelPaymentResponseModel> cancelPayment(
    String gateway, {
    required String reference,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.paymentCancel(gateway),
        data: {
          'reference': reference,
        },
      );
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid payment cancel response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to cancel payment';
        throw ServerException(msg);
      }

      final resData = body['data'];
      if (resData == null || resData is! Map<String, dynamic>) {
        throw const ServerException('Payment cancel response missing "data" node');
      }

      return CancelPaymentResponseModel.fromJson(resData);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] cancelPayment error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Preview airport transfer distance and fare.
  /// POST /api/airport-transfer/distance
  Future<AirportTransferDistanceModel> fetchAirportTransferDistance({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    int? vehicleId,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.airportTransferDistance,
        data: {
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'dropoff_latitude': dropoffLatitude,
          'dropoff_longitude': dropoffLongitude,
          if (vehicleId != null) 'vehicle_id': vehicleId,
        },
      );
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid airport transfer distance response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to calculate airport transfer distance';
        throw ServerException(msg);
      }

      final resData = body['data'];
      if (resData == null || resData is! Map<String, dynamic>) {
        throw const ServerException('Airport transfer distance response missing "data" node');
      }

      return AirportTransferDistanceModel.fromJson(resData);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[BookingService] fetchAirportTransferDistance error', error: e, stackTrace: st);
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
