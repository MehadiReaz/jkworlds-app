import 'package:get/get.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';

class OrdersController extends GetxController {
  final allBookings  = <BookingModel>[].obs;
  final isLoading    = false.obs;
  final errorMessage = ''.obs;
  final selectedTab  = 0.obs; // 0: All, 1: Confirmed, 2: Active, 3: Completed, 4: Cancelled

  BookingService get _bookingService => Get.find<BookingService>();

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final auth = Get.find<AuthService>();
    if (!auth.isLoggedIn.value) {
      allBookings.clear();
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final bookings = await _bookingService.fetchBookings();
      allBookings.value = bookings;
    } catch (e) {
      // Non-fatal: fall back to mock bookings
      // allBookings.value = mockBookings;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadBookings();

  /// Returns the list of bookings filtered by the active filter tab index.
  List<BookingModel> get filteredBookings {
    switch (selectedTab.value) {
      case 1: // Confirmed (Upcoming)
        return allBookings.where((b) => b.status == BookingStatus.upcoming).toList();
      case 2: // Active
        return allBookings.where((b) => b.status == BookingStatus.active).toList();
      case 3: // Completed (Past)
        return allBookings.where((b) => b.status == BookingStatus.past).toList();
      case 4: // Cancelled
        return allBookings.where((b) => b.status == BookingStatus.cancelled).toList();
      default:
        return allBookings;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
