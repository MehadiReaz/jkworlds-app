class ServicePricingModel {
  final String serviceType;
  final String serviceTypeLabel;
  final String currency;
  final SelfDrivePricingModel? selfDrive;
  final ChauffeurPricingModel? chauffeur;
  final AirportTransferPricingModel? airportTransfer;
  final AirportTransferPricingModel? applicable;

  ServicePricingModel({
    required this.serviceType,
    required this.serviceTypeLabel,
    required this.currency,
    this.selfDrive,
    this.chauffeur,
    this.airportTransfer,
    this.applicable,
  });

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) {
    return ServicePricingModel(
      serviceType: json['service_type'] as String? ?? '',
      serviceTypeLabel: json['service_type_label'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      selfDrive: json['self_drive'] is Map<String, dynamic>
          ? SelfDrivePricingModel.fromJson(json['self_drive'] as Map<String, dynamic>)
          : null,
      chauffeur: json['chauffeur'] is Map<String, dynamic>
          ? ChauffeurPricingModel.fromJson(json['chauffeur'] as Map<String, dynamic>)
          : null,
      airportTransfer: json['airport_transfer'] is Map<String, dynamic>
          ? AirportTransferPricingModel.fromJson(json['airport_transfer'] as Map<String, dynamic>)
          : null,
      applicable: json['applicable'] is Map<String, dynamic>
          ? AirportTransferPricingModel.fromJson(json['applicable'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_type': serviceType,
      'service_type_label': serviceTypeLabel,
      'currency': currency,
      'self_drive': selfDrive?.toJson(),
      'chauffeur': chauffeur?.toJson(),
      'airport_transfer': airportTransfer?.toJson(),
      'applicable': applicable?.toJson(),
    };
  }
}

class SelfDrivePricingModel {
  final double dailyRate;
  final String dailyRateFormatted;
  final double weeklyRate;
  final String weeklyRateFormatted;
  final double monthlyRate;
  final String monthlyRateFormatted;

  SelfDrivePricingModel({
    required this.dailyRate,
    required this.dailyRateFormatted,
    required this.weeklyRate,
    required this.weeklyRateFormatted,
    required this.monthlyRate,
    required this.monthlyRateFormatted,
  });

  factory SelfDrivePricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final daily = json['daily_rate'] as Map<String, dynamic>?;
    final weekly = json['weekly_rate'] as Map<String, dynamic>?;
    final monthly = json['monthly_rate'] as Map<String, dynamic>?;

    return SelfDrivePricingModel(
      dailyRate: parseDouble(daily?['amount']),
      dailyRateFormatted: daily?['amount_formatted']?.toString() ?? '',
      weeklyRate: parseDouble(weekly?['amount']),
      weeklyRateFormatted: weekly?['amount_formatted']?.toString() ?? '',
      monthlyRate: parseDouble(monthly?['amount']),
      monthlyRateFormatted: monthly?['amount_formatted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_rate': {'amount': dailyRate, 'amount_formatted': dailyRateFormatted},
      'weekly_rate': {'amount': weeklyRate, 'amount_formatted': weeklyRateFormatted},
      'monthly_rate': {'amount': monthlyRate, 'amount_formatted': monthlyRateFormatted},
    };
  }
}

class ChauffeurPricingModel {
  final double chauffeurRatePerDay;
  final String chauffeurRatePerDayFormatted;

  ChauffeurPricingModel({
    required this.chauffeurRatePerDay,
    required this.chauffeurRatePerDayFormatted,
  });

  factory ChauffeurPricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final rate = json['chauffeur_rate_per_day'] as Map<String, dynamic>?;

    return ChauffeurPricingModel(
      chauffeurRatePerDay: parseDouble(rate?['amount']),
      chauffeurRatePerDayFormatted: rate?['amount_formatted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chauffeur_rate_per_day': {'amount': chauffeurRatePerDay, 'amount_formatted': chauffeurRatePerDayFormatted},
    };
  }
}

class AirportTransferPricingModel {
  final bool available;
  final double perKmRate;
  final String perKmRateFormatted;
  final int minBillableKm;
  final EstimatedPricingModel? estimated;

  AirportTransferPricingModel({
    required this.available,
    required this.perKmRate,
    required this.perKmRateFormatted,
    required this.minBillableKm,
    this.estimated,
  });

  factory AirportTransferPricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final rate = json['per_km_rate'] as Map<String, dynamic>?;

    return AirportTransferPricingModel(
      available: json['available'] as bool? ?? false,
      perKmRate: parseDouble(rate?['amount']),
      perKmRateFormatted: rate?['amount_formatted']?.toString() ?? '',
      minBillableKm: json['min_billable_km'] as int? ?? 1,
      estimated: json['estimated'] is Map<String, dynamic>
          ? EstimatedPricingModel.fromJson(json['estimated'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'per_km_rate': {'amount': perKmRate, 'amount_formatted': perKmRateFormatted},
      'min_billable_km': minBillableKm,
      'estimated': estimated?.toJson(),
    };
  }
}

class EstimatedPricingModel {
  final double distanceKm;
  final double amount;
  final String amountFormatted;

  EstimatedPricingModel({
    required this.distanceKm,
    required this.amount,
    required this.amountFormatted,
  });

  factory EstimatedPricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return EstimatedPricingModel(
      distanceKm: parseDouble(json['distance_km']),
      amount: parseDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_km': distanceKm,
      'amount': amount,
      'amount_formatted': amountFormatted,
    };
  }
}
