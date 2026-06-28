import 'package:jkworlds/data/models/checkout_pricing_model.dart';

/// Represents the response object returned by the initiate booking API.
class InitiateBookingResponseModel {
  final String reference;
  final String status;
  final double amount;
  final String currency;
  final String paymentMethod;
  final Map<String, dynamic> gateway;
  final CheckoutPricingModel? pricing;

  const InitiateBookingResponseModel({
    required this.reference,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.gateway,
    this.pricing,
  });

  factory InitiateBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return InitiateBookingResponseModel(
      reference: json['reference']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      paymentMethod: json['payment_method']?.toString() ?? '',
      gateway: json['gateway'] is Map
          ? Map<String, dynamic>.from(json['gateway'] as Map)
          : {},
      pricing: json['pricing'] is Map
          ? CheckoutPricingModel.fromJson(Map<String, dynamic>.from(json['pricing'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'status': status,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'gateway': gateway,
      // CheckoutPricingModel has no toJson, so we serialize it as null or omit if not present
    };
  }
}
