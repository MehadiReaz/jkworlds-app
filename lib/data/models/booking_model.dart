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
  final BookingStatus status;
  final RentalType rentalType;
  final double subtotal;
  final double serviceFee;
  final double securityDeposit;
  final double totalPrice;
  final DateTime createdAt;
  final String? paymentStatus;

  const BookingModel({
    required this.id,
    this.vehicle,
    this.vehicleId,
    this.bookingNumber,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.status,
    required this.rentalType,
    required this.subtotal,
    required this.serviceFee,
    required this.securityDeposit,
    required this.totalPrice,
    required this.createdAt,
    this.paymentStatus,
  });

  int get totalDays => returnDate.difference(pickupDate).inDays;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    BookingStatus _parseStatus(dynamic v) {
      final s = v?.toString().toLowerCase() ?? '';
      if (s == 'active') return BookingStatus.active;
      if (s == 'upcoming' || s == 'confirmed' || s == 'pending') return BookingStatus.upcoming;
      if (s == 'completed' || s == 'past') return BookingStatus.past;
      if (s == 'cancelled' || s == 'canceled') return BookingStatus.cancelled;
      return BookingStatus.upcoming;
    }

    RentalType _parseRentalType(dynamic v) {
      final s = v?.toString().toLowerCase() ?? '';
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

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      vehicle: vehicle,
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id'] as int
          : int.tryParse(json['vehicle_id']?.toString() ?? ''),
      bookingNumber: json['booking_number'] as String?,
      pickupDate: _parseDate(json['pickup_date'] ?? json['start_date']),
      returnDate: _parseDate(json['return_date'] ?? json['end_date']),
      pickupLocation: json['pickup_location'] as String? ?? '',
      status: _parseStatus(json['status']),
      rentalType: _parseRentalType(json['rental_type'] ?? json['service_type']),
      subtotal: _parseDouble(json['subtotal'] ?? json['sub_total']),
      serviceFee: _parseDouble(json['service_fee']),
      securityDeposit: _parseDouble(json['security_deposit']),
      totalPrice: _parseDouble(json['total'] ?? json['total_price'] ?? json['amount']),
      createdAt: _parseDate(json['created_at']),
      paymentStatus: json['payment_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_id': vehicleId,
        'booking_number': bookingNumber,
        'pickup_date': pickupDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
        'pickup_location': pickupLocation,
        'status': status.name,
        'rental_type': rentalType == RentalType.chauffeur ? 'chauffeur' : 'self-drive',
        'subtotal': subtotal,
        'service_fee': serviceFee,
        'security_deposit': securityDeposit,
        'total': totalPrice,
        'created_at': createdAt.toIso8601String(),
        'payment_status': paymentStatus,
      };
}
