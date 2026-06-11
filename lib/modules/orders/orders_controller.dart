import 'package:get/get.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';

class OrdersController extends GetxController {
  final allBookings = <BookingModel>[].obs;
  final selectedTab = 0.obs; // 0: All, 1: Confirmed, 2: Active, 3: Completed, 4: Cancelled

  @override
  void onInit() {
    super.onInit();
    allBookings.value = mockBookings;
  }

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
