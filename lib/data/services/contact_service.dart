import 'package:get/get.dart';
import 'package:jkworlds/core/utils/logger.dart';

/// Contact/support message service.
///
/// Currently mocks the submission flow. When your backend contact API
/// is ready, replace the TODO-marked section with a real HTTP call.
class ContactService extends GetxService {
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
      // TODO: Replace with real API call, e.g.:
      //
      //   final response = await _api.post('/contact', body: {
      //     'name': name,
      //     'phone': phone,
      //     'email': email,
      //     'subject': subject,
      //     'message': message,
      //   });
      //   if (response.statusCode != 200) throw Exception('Failed');

      // ── Mock implementation ──────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 1000));

      logger.i('[ContactService] Message submitted:\n'
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
