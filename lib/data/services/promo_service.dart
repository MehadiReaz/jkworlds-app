import 'package:get/get.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/promo_code.dart';

/// Service managing available coupons/promo codes.
/// Registers permanently in [InitialBinding].
class PromoService extends GetxService {
  // ── Reactive State ────────────────────────────────────────────
  final activePromos = <PromoCode>[].obs;
  final expiredPromos = <PromoCode>[].obs;
  final isSubmitting = false.obs;

  // Predefined hidden codes that users can "discover" and claim in the input field
  final Map<String, PromoCode> _claimableCodes = {
    'JKWORLD': PromoCode(
      code: 'JKWORLD',
      description: 'Exclusive 30% discount on luxury car rentals',
      discountValue: 30.0,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      minOrderValue: 150.0,
    ),
    'JKNEW': PromoCode(
      code: 'JKNEW',
      description: 'Flat \$15 off for new users',
      discountValue: 15.0,
      isPercentage: false,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      minOrderValue: 50.0,
    ),
  };

  @override
  void onInit() {
    super.onInit();
    _loadInitialPromos();
  }

  /// Seed mock promo codes into state lists.
  void _loadInitialPromos() {
    final now = DateTime.now();
    activePromos.assignAll([
      PromoCode(
        code: 'JKFIRST',
        description: '20% off your first premium vehicle rental',
        discountValue: 20.0,
        isPercentage: true,
        expiryDate: now.add(const Duration(days: 30)),
        minOrderValue: 0.0,
      ),
      PromoCode(
        code: 'SUMMER2026',
        description: 'Save \$50 on any booking above \$250',
        discountValue: 50.0,
        isPercentage: false,
        expiryDate: now.add(const Duration(days: 60)),
        minOrderValue: 250.0,
      ),
      PromoCode(
        code: 'JKLOYAL',
        description: '10% loyalty discount for frequent riders',
        discountValue: 10.0,
        isPercentage: true,
        expiryDate: now.add(const Duration(days: 15)),
        minOrderValue: 100.0,
      ),
    ]);

    expiredPromos.assignAll([
      PromoCode(
        code: 'WELCOME10',
        description: '10% welcome discount',
        discountValue: 10.0,
        isPercentage: true,
        expiryDate: now.subtract(const Duration(days: 5)),
        minOrderValue: 0.0,
        isActive: false,
      ),
      PromoCode(
        code: 'USED50',
        description: 'Save \$50 on booking',
        discountValue: 50.0,
        isPercentage: false,
        expiryDate: now.subtract(const Duration(days: 2)),
        minOrderValue: 100.0,
        isUsed: true,
        isActive: false,
      ),
    ]);
  }

  /// Claim/add a promo code by entering it manually.
  ///
  /// Returns `true` if claimed successfully, throws exception with localized error on failure.
  Future<bool> claimPromoCode(String inputCode) async {
    final code = inputCode.trim().toUpperCase();
    if (code.isEmpty) throw 'field_required'.tr;

    isSubmitting.value = true;
    logger.i('[PromoService] Attempting to claim promo code: $code');

    try {
      // Simulate network request delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // 1. Check if already active or expired
      if (activePromos.any((p) => p.code == code)) {
        throw 'promo_already_added'.tr;
      }
      if (expiredPromos.any((p) => p.code == code)) {
        throw 'promo_already_used'.tr;
      }

      // 2. Check claimable list
      if (_claimableCodes.containsKey(code)) {
        final newPromo = _claimableCodes[code]!;
        activePromos.insert(0, newPromo);
        logger.i('[PromoService] Promo code claimed successfully: $code');
        isSubmitting.value = false;
        return true;
      }

      // 3. Fallback: Invalid code
      throw 'promo_invalid'.tr;
    } catch (e) {
      logger.e('[PromoService] Error claiming promo code ($code): $e');
      isSubmitting.value = false;
      rethrow;
    }
  }
}
