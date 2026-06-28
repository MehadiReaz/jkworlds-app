/// Represents the response object returned by the cancel payment API.
class CancelPaymentResponseModel {
  final String reference;
  final String status;

  const CancelPaymentResponseModel({
    required this.reference,
    required this.status,
  });

  factory CancelPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelPaymentResponseModel(
      reference: json['reference']?.toString() ?? '',
      status: json['status']?.toString() ?? 'cancelled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'status': status,
    };
  }
}
