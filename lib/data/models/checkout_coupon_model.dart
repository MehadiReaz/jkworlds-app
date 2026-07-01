class CheckoutCouponItem {
  final double amount;
  final String amountFormatted;

  const CheckoutCouponItem({
    required this.amount,
    required this.amountFormatted,
  });

  factory CheckoutCouponItem.fromJson(Map<String, dynamic> json) {
    return CheckoutCouponItem(
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      amountFormatted: json['amount_formatted']?.toString() ?? '',
    );
  }
}

class CheckoutCouponModel {
  final String code;
  final String name;
  final String discountType;
  final double discountValue;
  final CheckoutCouponItem discount;
  final CheckoutCouponItem total;
  final CheckoutCouponItem payableTotal;
  final String currency;

  const CheckoutCouponModel({
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.discount,
    required this.total,
    required this.payableTotal,
    required this.currency,
  });

  factory CheckoutCouponModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCouponModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? '',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '') ?? 0.0,
      discount: CheckoutCouponItem.fromJson(Map<String, dynamic>.from(json['discount'] ?? {})),
      total: CheckoutCouponItem.fromJson(Map<String, dynamic>.from(json['total'] ?? {})),
      payableTotal: CheckoutCouponItem.fromJson(Map<String, dynamic>.from(json['payable_total'] ?? {})),
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
