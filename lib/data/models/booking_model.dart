import 'vehicle_model.dart';

/// Booking status enum.
enum BookingStatus { upcoming, active, past, cancelled }

/// Rental type enum.
enum RentalType { selfDrive, chauffeur }

/// Booking data model.
class BookingModel {
  final String id;
  final VehicleModel? vehicle; // nullable — list response may omit vehicle details
  final int? vehicleId;        // raw id from API
  final String? bookingNumber;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String dropoffLocation;
  final BookingStatus status;
  final RentalType rentalType;
  final double subtotal;
  final double serviceFee;
  final double securityDeposit;
  final double totalPrice;
  final DateTime createdAt;
  final String? paymentStatus;
  final String statusLabel;
  final String statusValue;
  final String statusBadgeClass;

  // New fields for formatting and pricing detail from real API
  final String? baseAmountFormatted;
  final String? addonsTotalFormatted;
  final String? protectionPlanAmountFormatted;
  final String? discountAmountFormatted;
  final String? depositAmountFormatted;
  final String? totalAmountFormatted;
  final String? payableAmountFormatted;
  final String? currency;

  // New fields for customer and driver info
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;

  final String? driverName;
  final String? driverEmail;
  final String? driverPhone;
  final String? driverImage;

  // New field for payment details
  final String? paymentMethod;

  const BookingModel({
    required this.id,
    this.vehicle,
    this.vehicleId,
    this.bookingNumber,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    this.dropoffLocation = '',
    required this.status,
    required this.rentalType,
    required this.subtotal,
    required this.serviceFee,
    required this.securityDeposit,
    required this.totalPrice,
    required this.createdAt,
    this.paymentStatus,
    this.statusLabel = '',
    this.statusValue = '',
    this.statusBadgeClass = '',
    this.baseAmountFormatted,
    this.addonsTotalFormatted,
    this.protectionPlanAmountFormatted,
    this.discountAmountFormatted,
    this.depositAmountFormatted,
    this.totalAmountFormatted,
    this.payableAmountFormatted,
    this.currency,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.driverName,
    this.driverEmail,
    this.driverPhone,
    this.driverImage,
    this.paymentMethod,
  });

  int get totalDays => returnDate.difference(pickupDate).inDays;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    BookingStatus _parseStatus(dynamic v) {
      String s = '';
      if (v is Map<String, dynamic>) {
        s = v['value']?.toString().toLowerCase() ?? '';
      } else {
        s = v?.toString().toLowerCase() ?? '';
      }
      if (s == 'active' || s == 'ongoing') return BookingStatus.active;
      if (s == 'upcoming' || s == 'confirmed' || s == 'pending') return BookingStatus.upcoming;
      if (s == 'completed' || s == 'past') return BookingStatus.past;
      if (s == 'cancelled' || s == 'canceled') return BookingStatus.cancelled;
      return BookingStatus.upcoming;
    }

    RentalType _parseRentalType(dynamic v) {
      String s = '';
      if (v is Map<String, dynamic>) {
        s = v['value']?.toString().toLowerCase() ?? '';
      } else {
        s = v?.toString().toLowerCase() ?? '';
      }
      return s == 'chauffeur' ? RentalType.chauffeur : RentalType.selfDrive;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final vehicleData = json['vehicle'];
    final vehicle = vehicleData is Map<String, dynamic>
        ? VehicleModel.fromJson(vehicleData)
        : null;

    final pickupMap = json['pickup'] is Map<String, dynamic> ? json['pickup'] as Map<String, dynamic> : null;
    final dropoffMap = json['dropoff'] is Map<String, dynamic> ? json['dropoff'] as Map<String, dynamic> : null;
    final pricingMap = json['pricing'] is Map<String, dynamic> ? json['pricing'] as Map<String, dynamic> : null;
    final paymentMap = json['payment'] is Map<String, dynamic> ? json['payment'] as Map<String, dynamic> : null;
    final customerMap = json['customer'] is Map<String, dynamic> ? json['customer'] as Map<String, dynamic> : null;
    final driverMap = json['driver'] is Map<String, dynamic> ? json['driver'] as Map<String, dynamic> : null;

    final subtotal = _parseDouble(pricingMap?['base_amount'] ?? json['subtotal'] ?? json['sub_total']);

    final statusMap = json['status'] is Map<String, dynamic> ? json['status'] as Map<String, dynamic> : null;
    final statusLabel = statusMap?['label']?.toString() ?? json['status_label']?.toString() ?? '';
    final statusValue = statusMap?['value']?.toString() ?? json['status_value']?.toString() ?? '';
    final statusBadgeClass = statusMap?['badge_class']?.toString() ?? json['status_badge_class']?.toString() ?? '';

    final customerName = customerMap?['name']?.toString() ?? json['customer_name']?.toString();
    final customerEmail = customerMap?['email']?.toString() ?? json['customer_email']?.toString();
    final customerPhone = customerMap?['phone']?.toString() ?? json['customer_phone']?.toString();

    final driverName = driverMap?['name']?.toString() ?? json['driver_name']?.toString();
    final driverEmail = driverMap?['email']?.toString() ?? json['driver_email']?.toString();
    final driverPhone = driverMap?['phone']?.toString() ?? json['driver_phone']?.toString();
    final driverImage = driverMap?['image']?.toString() ?? json['driver_image']?.toString();

    final baseAmountFormatted = pricingMap?['base_amount_formatted']?.toString();
    final addonsTotalFormatted = pricingMap?['addons_total_formatted']?.toString();
    final protectionPlanAmountFormatted = pricingMap?['protection_plan_amount_formatted']?.toString();
    final discountAmountFormatted = pricingMap?['discount_amount_formatted']?.toString();
    final depositAmountFormatted = pricingMap?['deposit_amount_formatted']?.toString();
    final totalAmountFormatted = pricingMap?['total_amount_formatted']?.toString();
    final payableAmountFormatted = pricingMap?['payable_amount_formatted']?.toString();
    final currency = pricingMap?['currency']?.toString() ?? json['currency']?.toString();

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      vehicle: vehicle,
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id'] as int
          : (int.tryParse(json['vehicle_id']?.toString() ?? '') ?? int.tryParse(vehicle?.id ?? '')),
      bookingNumber: (json['booking_code'] ?? json['booking_number']) as String?,
      pickupDate: _parseDate(pickupMap?['datetime'] ?? json['pickup_date'] ?? json['start_date']),
      returnDate: _parseDate(dropoffMap?['datetime'] ?? json['return_date'] ?? json['end_date']),
      pickupLocation: (pickupMap?['address'] ?? json['pickup_location'] ?? '').toString(),
      dropoffLocation: (dropoffMap?['address'] ?? json['dropoff_location'] ?? (pickupMap?['address'] ?? json['pickup_location'] ?? '')).toString(),
      status: _parseStatus(json['status']),
      rentalType: _parseRentalType(json['rental_type'] ?? json['service_type']),
      subtotal: subtotal,
      serviceFee: _parseDouble(json['service_fee'] ?? (subtotal * 0.05)),
      securityDeposit: _parseDouble(pricingMap?['deposit_amount'] ?? json['security_deposit']),
      totalPrice: _parseDouble(pricingMap?['total_amount'] ?? pricingMap?['payable_amount'] ?? json['total'] ?? json['total_price'] ?? json['amount']),
      createdAt: _parseDate(json['created_at']),
      paymentStatus: (paymentMap?['status'] ?? json['payment_status'])?.toString(),
      statusLabel: statusLabel,
      statusValue: statusValue,
      statusBadgeClass: statusBadgeClass,
      baseAmountFormatted: baseAmountFormatted,
      addonsTotalFormatted: addonsTotalFormatted,
      protectionPlanAmountFormatted: protectionPlanAmountFormatted,
      discountAmountFormatted: discountAmountFormatted,
      depositAmountFormatted: depositAmountFormatted,
      totalAmountFormatted: totalAmountFormatted,
      payableAmountFormatted: payableAmountFormatted,
      currency: currency,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      driverName: driverName,
      driverEmail: driverEmail,
      driverPhone: driverPhone,
      driverImage: driverImage,
      paymentMethod: (paymentMap?['method'] ?? json['payment_method'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_id': vehicleId,
        'booking_number': bookingNumber,
        'pickup_date': pickupDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
        'pickup_location': pickupLocation,
        'dropoff_location': dropoffLocation,
        'status': status.name,
        'rental_type': rentalType == RentalType.chauffeur ? 'chauffeur' : 'self-drive',
        'subtotal': subtotal,
        'service_fee': serviceFee,
        'security_deposit': securityDeposit,
        'total': totalPrice,
        'created_at': createdAt.toIso8601String(),
        'payment_status': paymentStatus,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'driver_name': driverName,
        'driver_email': driverEmail,
        'driver_phone': driverPhone,
        'driver_image': driverImage,
        'payment_method': paymentMethod,
      };
}
