/// Represents calculated distance details from the airport transfer distance API.
class DistanceDetails {
  final String method;
  final double rawKm;
  final double billableKm;
  final int minBillableKm;

  const DistanceDetails({
    required this.method,
    required this.rawKm,
    required this.billableKm,
    required this.minBillableKm,
  });

  factory DistanceDetails.fromJson(Map<String, dynamic> json) {
    return DistanceDetails(
      method: json['method']?.toString() ?? '',
      rawKm: double.tryParse(json['raw_km']?.toString() ?? '') ?? 0.0,
      billableKm: double.tryParse(json['billable_km']?.toString() ?? '') ?? 0.0,
      minBillableKm: int.tryParse(json['min_billable_km']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'raw_km': rawKm,
      'billable_km': billableKm,
      'min_billable_km': minBillableKm,
    };
  }
}

/// Represents individual items/breakdowns in the fare (e.g. per km rate, base fare, tax).
class FareItem {
  final double amount;
  final String amountFormatted;
  final String? label;
  final String? title;

  const FareItem({
    required this.amount,
    required this.amountFormatted,
    this.label,
    this.title,
  });

  factory FareItem.fromJson(Map<String, dynamic> json) {
    return FareItem(
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      amountFormatted: json['amount_formatted']?.toString() ?? '',
      label: json['label']?.toString(),
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_formatted': amountFormatted,
      if (label != null) 'label': label,
      if (title != null) 'title': title,
    };
  }
}

/// Represents detailed airport transfer fare details.
class FareDetails {
  final int vehicleId;
  final FareItem perKmRate;
  final FareItem baseFare;
  final List<FareItem> taxesFees;
  final FareItem taxesFeesTotal;
  final FareItem estimatedTotal;

  const FareDetails({
    required this.vehicleId,
    required this.perKmRate,
    required this.baseFare,
    required this.taxesFees,
    required this.taxesFeesTotal,
    required this.estimatedTotal,
  });

  factory FareDetails.fromJson(Map<String, dynamic> json) {
    return FareDetails(
      vehicleId: int.tryParse(json['vehicle_id']?.toString() ?? '') ?? 0,
      perKmRate: FareItem.fromJson(Map<String, dynamic>.from(json['per_km_rate'] ?? {})),
      baseFare: FareItem.fromJson(Map<String, dynamic>.from(json['base_fare'] ?? {})),
      taxesFees: (json['taxes_fees'] as List?)
              ?.whereType<Map>()
              .map((m) => FareItem.fromJson(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
      taxesFeesTotal: FareItem.fromJson(Map<String, dynamic>.from(json['taxes_fees_total'] ?? {})),
      estimatedTotal: FareItem.fromJson(Map<String, dynamic>.from(json['estimated_total'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'per_km_rate': perKmRate.toJson(),
      'base_fare': baseFare.toJson(),
      'taxes_fees': taxesFees.map((t) => t.toJson()).toList(),
      'taxes_fees_total': taxesFeesTotal.toJson(),
      'estimated_total': estimatedTotal.toJson(),
    };
  }
}

/// Represents the response object returned by the airport transfer distance calculation API.
class AirportTransferDistanceModel {
  final String currency;
  final DistanceDetails distance;
  final FareDetails? fare;

  const AirportTransferDistanceModel({
    required this.currency,
    required this.distance,
    this.fare,
  });

  factory AirportTransferDistanceModel.fromJson(Map<String, dynamic> json) {
    return AirportTransferDistanceModel(
      currency: json['currency']?.toString() ?? 'USD',
      distance: DistanceDetails.fromJson(Map<String, dynamic>.from(json['distance'] ?? {})),
      fare: json['fare'] is Map
          ? FareDetails.fromJson(Map<String, dynamic>.from(json['fare'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'distance': distance.toJson(),
      if (fare != null) 'fare': fare!.toJson(),
    };
  }
}
