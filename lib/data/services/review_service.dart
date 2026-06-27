import 'package:get/get.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/review_model.dart';

/// Service for managing vehicle ratings and reviews.
class ReviewService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  /// Fetch all ratings.
  /// GET /api/ratings
  Future<List<ReviewModel>> fetchRatings() async {
    try {
      final response = await _api.get(ApiConstants.ratings);
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
          .map(ReviewModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[ReviewService] fetchRatings error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Create a new rating/review for a booking.
  /// POST /api/ratings
  Future<ReviewModel> createRating({
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.ratings,
        data: {
          'booking_id': bookingId,
          'rating': rating.toInt(),
          'comment': comment,
        },
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid rating response');
      }

      // Unwrap data node if present
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return ReviewModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[ReviewService] createRating error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}
