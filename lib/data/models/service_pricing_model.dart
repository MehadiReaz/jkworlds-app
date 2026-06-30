class ServicePricingModel {
  final String serviceType;
  final String serviceTypeLabel;
  final String currency;
  final SelfDrivePricingModel? selfDrive;
  final ChauffeurPricingModel? chauffeur;
  final AirportTransferPricingModel? airportTransfer;
  final ApplicablePricingModel? applicable;

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
          ? ApplicablePricingModel.fromJson(json['applicable'] as Map<String, dynamic>)
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
  final RateDetails? daily;
  final RateDetails? weekly;
  final RateDetails? monthly;

  SelfDrivePricingModel({
    required this.dailyRate,
    required this.dailyRateFormatted,
    required this.weeklyRate,
    required this.weeklyRateFormatted,
    required this.monthlyRate,
    required this.monthlyRateFormatted,
    this.daily,
    this.weekly,
    this.monthly,
  });

  factory SelfDrivePricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final dailyMap = json['daily_rate'] as Map<String, dynamic>?;
    final weeklyMap = json['weekly_rate'] as Map<String, dynamic>?;
    final monthlyMap = json['monthly_rate'] as Map<String, dynamic>?;

    return SelfDrivePricingModel(
      dailyRate: parseDouble(dailyMap?['amount'] ?? json['daily_rate']),
      dailyRateFormatted: dailyMap?['amount_formatted']?.toString() ?? json['daily_rate_formatted']?.toString() ?? '',
      weeklyRate: parseDouble(weeklyMap?['amount'] ?? json['weekly_rate']),
      weeklyRateFormatted: weeklyMap?['amount_formatted']?.toString() ?? json['weekly_rate_formatted']?.toString() ?? '',
      monthlyRate: parseDouble(monthlyMap?['amount'] ?? json['monthly_rate']),
      monthlyRateFormatted: monthlyMap?['amount_formatted']?.toString() ?? json['monthly_rate_formatted']?.toString() ?? '',
      daily: dailyMap != null ? RateDetails.fromJson(dailyMap) : null,
      weekly: weeklyMap != null ? RateDetails.fromJson(weeklyMap) : null,
      monthly: monthlyMap != null ? RateDetails.fromJson(monthlyMap) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_rate': daily?.toJson() ?? {'amount': dailyRate, 'amount_formatted': dailyRateFormatted},
      'weekly_rate': weekly?.toJson() ?? {'amount': weeklyRate, 'amount_formatted': weeklyRateFormatted},
      'monthly_rate': monthly?.toJson() ?? {'amount': monthlyRate, 'amount_formatted': monthlyRateFormatted},
    };
  }
}

class ChauffeurPricingModel {
  final double chauffeurRatePerDay;
  final String chauffeurRatePerDayFormatted;
  final RateDetails? rate;

  ChauffeurPricingModel({
    required this.chauffeurRatePerDay,
    required this.chauffeurRatePerDayFormatted,
    this.rate,
  });

  factory ChauffeurPricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final rateMap = json['chauffeur_rate_per_day'] as Map<String, dynamic>?;

    return ChauffeurPricingModel(
      chauffeurRatePerDay: parseDouble(rateMap?['amount'] ?? json['chauffeur_rate_per_day']),
      chauffeurRatePerDayFormatted: rateMap?['amount_formatted']?.toString() ?? json['chauffeur_rate_per_day_formatted']?.toString() ?? '',
      rate: rateMap != null ? RateDetails.fromJson(rateMap) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chauffeur_rate_per_day': rate?.toJson() ?? {'amount': chauffeurRatePerDay, 'amount_formatted': chauffeurRatePerDayFormatted},
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

class ApplicablePricingModel {
  final String serviceType;

  // Self Drive fields
  final RateDetails? dailyRate;
  final RateDetails? weeklyRate;
  final RateDetails? monthlyRate;

  // Chauffeur fields
  final RateDetails? chauffeurRatePerDay;

  // Airport Transfer fields
  final bool available;
  final double perKmRate;
  final String perKmRateFormatted;
  final int minBillableKm;
  final EstimatedPricingModel? estimated;

  ApplicablePricingModel({
    required this.serviceType,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.chauffeurRatePerDay,
    this.available = true,
    this.perKmRate = 0.0,
    this.perKmRateFormatted = '',
    this.minBillableKm = 1,
    this.estimated,
  });

  factory ApplicablePricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final serviceType = json['service_type'] as String? ?? '';

    final dailyRate = json['daily_rate'] is Map<String, dynamic>
        ? RateDetails.fromJson(json['daily_rate'] as Map<String, dynamic>)
        : null;
    final weeklyRate = json['weekly_rate'] is Map<String, dynamic>
        ? RateDetails.fromJson(json['weekly_rate'] as Map<String, dynamic>)
        : null;
    final monthlyRate = json['monthly_rate'] is Map<String, dynamic>
        ? RateDetails.fromJson(json['monthly_rate'] as Map<String, dynamic>)
        : null;
    final chauffeurRatePerDay = json['chauffeur_rate_per_day'] is Map<String, dynamic>
        ? RateDetails.fromJson(json['chauffeur_rate_per_day'] as Map<String, dynamic>)
        : null;

    final bool available = json['available'] as bool? ?? true;
    final rate = json['per_km_rate'] as Map<String, dynamic>?;
    final perKmRate = parseDouble(rate?['amount']);
    final perKmRateFormatted = rate?['amount_formatted']?.toString() ?? '';
    final minBillableKm = json['min_billable_km'] as int? ?? 1;
    final estimated = json['estimated'] is Map<String, dynamic>
        ? EstimatedPricingModel.fromJson(json['estimated'] as Map<String, dynamic>)
        : null;

    return ApplicablePricingModel(
      serviceType: serviceType,
      dailyRate: dailyRate,
      weeklyRate: weeklyRate,
      monthlyRate: monthlyRate,
      chauffeurRatePerDay: chauffeurRatePerDay,
      available: available,
      perKmRate: perKmRate,
      perKmRateFormatted: perKmRateFormatted,
      minBillableKm: minBillableKm,
      estimated: estimated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_type': serviceType,
      if (dailyRate != null) 'daily_rate': dailyRate!.toJson(),
      if (weeklyRate != null) 'weekly_rate': weeklyRate!.toJson(),
      if (monthlyRate != null) 'monthly_rate': monthlyRate!.toJson(),
      if (chauffeurRatePerDay != null) 'chauffeur_rate_per_day': chauffeurRatePerDay!.toJson(),
      'available': available,
      'per_km_rate': {'amount': perKmRate, 'amount_formatted': perKmRateFormatted},
      'min_billable_km': minBillableKm,
      if (estimated != null) 'estimated': estimated!.toJson(),
    };
  }
}

class RateDetails {
  final double amount;
  final String amountFormatted;
  final TaxFeeDetails? taxesFees;
  final TotalDetails? total;

  RateDetails({
    required this.amount,
    required this.amountFormatted,
    this.taxesFees,
    this.total,
  });

  factory RateDetails.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return RateDetails(
      amount: parseDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString() ?? '',
      taxesFees: json['taxes_fees'] is Map<String, dynamic>
          ? TaxFeeDetails.fromJson(json['taxes_fees'] as Map<String, dynamic>)
          : null,
      total: json['total'] is Map<String, dynamic>
          ? TotalDetails.fromJson(json['total'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_formatted': amountFormatted,
      if (taxesFees != null) 'taxes_fees': taxesFees!.toJson(),
      if (total != null) 'total': total!.toJson(),
    };
  }
}

class TaxFeeDetails {
  final double amount;
  final String amountFormatted;

  TaxFeeDetails({
    required this.amount,
    required this.amountFormatted,
  });

  factory TaxFeeDetails.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return TaxFeeDetails(
      amount: parseDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_formatted': amountFormatted,
    };
  }
}

class TotalDetails {
  final double amount;
  final String amountFormatted;

  TotalDetails({
    required this.amount,
    required this.amountFormatted,
  });

  factory TotalDetails.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return TotalDetails(
      amount: parseDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_formatted': amountFormatted,
    };
  }
}
