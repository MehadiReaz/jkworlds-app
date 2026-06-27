import 'package:get/get.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/data/providers/api_provider.dart';

/// Contact/support message service.
class ContactService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  // ── State ───────────────────────────────────────────────────
  final isSubmitting = false.obs;

  /// Submit a contact form message.
  ///
  /// Returns `true` on success.
  Future<bool> submitMessage({
    required String name,
    required String phone,
    required String email,
    required String subject,
    required String message,
  }) async {
    isSubmitting.value = true;

    try {
      final response = await _api.post(
        ApiConstants.contact,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );

      final body = response.data;
      final success = body != null && (body['success'] as bool? ?? body['status'] as bool? ?? false);
      if (!success) {
        throw Exception(body?['message'] ?? 'Failed to submit contact message');
      }

      logger.i('[ContactService] Message submitted successfully:\n'
          '  Name: $name\n'
          '  Phone: $phone\n'
          '  Email: $email\n'
          '  Subject: $subject\n'
          '  Message: $message');

      isSubmitting.value = false;
      return true;
    } catch (e) {
      isSubmitting.value = false;
      logger.e('[ContactService] Submit error: $e');
      return false;
    }
  }
}
