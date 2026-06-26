class CheckoutPricingItem {
  final double amount;
  final String amountFormatted;
  final String? title;
  final String? code;

  const CheckoutPricingItem({
    required this.amount,
    required this.amountFormatted,
    this.title,
    this.code,
  });

  factory CheckoutPricingItem.fromJson(Map<String, dynamic> json) {
    return CheckoutPricingItem(
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      amountFormatted: json['amount_formatted']?.toString() ?? '',
      title: json['title']?.toString(),
      code: json['code']?.toString(),
    );
  }
}

class CheckoutPricingModel {
  final String currency;
  final String serviceType;
  final int rentalDays;
  final CheckoutPricingItem base;
  final CheckoutPricingItem addonsTotal;
  final CheckoutPricingItem protection;
  final CheckoutPricingItem feesTotal;
  final CheckoutPricingItem discount;
  final CheckoutPricingItem total;
  final CheckoutPricingItem payableTotal;
  final CheckoutPricingItem deposit;
  final List<Map<String, dynamic>> addons;
  final List<Map<String, dynamic>> fees;
  final List<Map<String, dynamic>> paymentMethods;

  const CheckoutPricingModel({
    required this.currency,
    required this.serviceType,
    required this.rentalDays,
    required this.base,
    required this.addonsTotal,
    required this.protection,
    required this.feesTotal,
    required this.discount,
    required this.total,
    required this.payableTotal,
    required this.deposit,
    required this.addons,
    required this.fees,
    required this.paymentMethods,
  });

  factory CheckoutPricingModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPricingModel(
      currency: json['currency']?.toString() ?? 'USD',
      serviceType: json['service_type']?.toString() ?? 'self_drive',
      rentalDays: int.tryParse(json['rental_days']?.toString() ?? '') ?? 0,
      base: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['base'] ?? {})),
      addonsTotal: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['addons_total'] ?? {})),
      protection: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['protection'] ?? {})),
      feesTotal: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['fees_total'] ?? {})),
      discount: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['discount'] ?? {})),
      total: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['total'] ?? {})),
      payableTotal: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['payable_total'] ?? {})),
      deposit: CheckoutPricingItem.fromJson(Map<String, dynamic>.from(json['deposit'] ?? {})),
      addons: (json['addons'] as List?)?.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() ?? [],
      fees: (json['fees'] as List?)?.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() ?? [],
      paymentMethods: (json['payment_methods'] as List?)?.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() ?? [],
    );
  }
}
