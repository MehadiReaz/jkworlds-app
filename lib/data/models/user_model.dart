class UserModel {
  final int? id;
  final String? userCode;
  final String? username;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? role;
  final String? image;
  final String? status;
  final bool onboardingCompleted;
  final String? preferredLanguage;
  final String? preferredCountry;
  final String? preferredCurrency;
  final String? preferredTimezone;
  final String? preferredService;
  final String? locationLatitude;
  final String? locationLongitude;
  final String? countryCode;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? createdAt;
  final String? updatedAt;
  final String? googleId;
  final String? appleId;

  UserModel({
    this.id,
    this.userCode,
    this.username,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.role,
    this.image,
    this.status,
    this.onboardingCompleted = false,
    this.preferredLanguage,
    this.preferredCountry,
    this.preferredCurrency,
    this.preferredTimezone,
    this.preferredService,
    this.locationLatitude,
    this.locationLongitude,
    this.countryCode,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.country,
    this.licenseNumber,
    this.licenseExpiry,
    this.createdAt,
    this.updatedAt,
    this.googleId,
    this.appleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val != 0;
      if (val is String) {
        final lower = val.toLowerCase();
        return lower == 'true' || lower == '1';
      }
      return false;
    }

    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      userCode: json['user_code']?.toString(),
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'] as String?,
      image: json['image'] as String?,
      status: json['status'] as String?,
      onboardingCompleted: parseBool(json['onboarding_completed']),
      preferredLanguage: json['preferred_language'] as String?,
      preferredCountry: json['preferred_country'] as String?,
      preferredCurrency: json['preferred_currency'] as String?,
      preferredTimezone: json['preferred_timezone'] as String?,
      preferredService: json['preferred_service'] as String?,
      locationLatitude: json['location_latitude']?.toString(),
      locationLongitude: json['location_longitude']?.toString(),
      countryCode: json['country_code']?.toString(),
      phone: json['phone']?.toString(),
      dateOfBirth: json['date_of_birth'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseExpiry: json['license_expiry'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      googleId: json['google_id']?.toString(),
      appleId: json['apple_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_code': userCode,
      'username': username,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'image': image,
      'status': status,
      'onboarding_completed': onboardingCompleted,
      'preferred_language': preferredLanguage,
      'preferred_country': preferredCountry,
      'preferred_currency': preferredCurrency,
      'preferred_timezone': preferredTimezone,
      'preferred_service': preferredService,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'country_code': countryCode,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'address': address,
      'city': city,
      'country': country,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'google_id': googleId,
      'apple_id': appleId,
    };
  }
}
