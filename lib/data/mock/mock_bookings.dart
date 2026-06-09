import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';

/// Mock bookings in various states.
final List<BookingModel> mockBookings = [
  BookingModel(
    id: 'BK-1001',
    vehicle: mockVehicles[0], // Land Cruiser
    pickupDate: DateTime.now().add(const Duration(days: 3)),
    returnDate: DateTime.now().add(const Duration(days: 6)),
    pickupLocation: 'Victoria Island, Lagos',
    status: BookingStatus.upcoming,
    rentalType: RentalType.chauffeur,
    subtotal: 450000,
    serviceFee: 22500,
    securityDeposit: 100000,
    totalPrice: 572500,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  BookingModel(
    id: 'BK-1002',
    vehicle: mockVehicles[3], // Camry
    pickupDate: DateTime.now().subtract(const Duration(days: 1)),
    returnDate: DateTime.now().add(const Duration(days: 2)),
    pickupLocation: 'Lekki, Lagos',
    status: BookingStatus.active,
    rentalType: RentalType.selfDrive,
    subtotal: 135000,
    serviceFee: 6750,
    securityDeposit: 50000,
    totalPrice: 191750,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  BookingModel(
    id: 'BK-0998',
    vehicle: mockVehicles[1], // E-Class
    pickupDate: DateTime.now().subtract(const Duration(days: 14)),
    returnDate: DateTime.now().subtract(const Duration(days: 10)),
    pickupLocation: 'Ikoyi, Lagos',
    status: BookingStatus.past,
    rentalType: RentalType.chauffeur,
    subtotal: 480000,
    serviceFee: 24000,
    securityDeposit: 100000,
    totalPrice: 604000,
    createdAt: DateTime.now().subtract(const Duration(days: 16)),
  ),
  BookingModel(
    id: 'BK-0995',
    vehicle: mockVehicles[8], // Tucson
    pickupDate: DateTime.now().subtract(const Duration(days: 30)),
    returnDate: DateTime.now().subtract(const Duration(days: 25)),
    pickupLocation: 'Garki, Abuja',
    status: BookingStatus.past,
    rentalType: RentalType.selfDrive,
    subtotal: 250000,
    serviceFee: 12500,
    securityDeposit: 50000,
    totalPrice: 312500,
    createdAt: DateTime.now().subtract(const Duration(days: 32)),
  ),
  BookingModel(
    id: 'BK-0990',
    vehicle: mockVehicles[2], // Range Rover Sport
    pickupDate: DateTime.now().subtract(const Duration(days: 5)),
    returnDate: DateTime.now().subtract(const Duration(days: 2)),
    pickupLocation: 'Maitama, Abuja',
    status: BookingStatus.cancelled,
    rentalType: RentalType.chauffeur,
    subtotal: 540000,
    serviceFee: 27000,
    securityDeposit: 150000,
    totalPrice: 717000,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
];
