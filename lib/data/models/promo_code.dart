/// Data model representing a promotional/discount coupon.
class PromoCode {
  final String code;
  final String description;
  final double discountValue;
  final bool isPercentage;
  final DateTime expiryDate;
  final double minOrderValue;
  final bool isActive;
  final bool isUsed;

  const PromoCode({
    required this.code,
    required this.description,
    required this.discountValue,
    required this.isPercentage,
    required this.expiryDate,
    required this.minOrderValue,
    this.isActive = true,
    this.isUsed = false,
  });

  /// Helper getter to format the discount text (e.g. "20%" or "₦2,000")
  String get discountText {
    if (isPercentage) {
      return '${discountValue.toInt()}%';
    }
    // For fixed currency, we can return the value. (Currency symbols are handled at view level).
    return discountValue.toStringAsFixed(0);
  }
}
