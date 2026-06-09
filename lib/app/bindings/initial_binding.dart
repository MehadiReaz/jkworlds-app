import 'package:get/get.dart';

import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/notification_service.dart';
import 'package:jkworlds/data/services/contact_service.dart';
import 'package:jkworlds/data/services/promo_service.dart';
import 'package:jkworlds/app/currency/currency_service.dart';

/// Registers global-lifetime dependencies on app start.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Services ──────────────────────────────────────────────────
    Get.put(ApiProvider(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(CurrencyService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(ContactService(), permanent: true);
    Get.put(PromoService(), permanent: true);
  }
}
