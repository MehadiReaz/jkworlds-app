import 'package:get/get.dart';

import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';

class OrdersController extends GetxController {
  final allBookings = <BookingModel>[].obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    allBookings.value = mockBookings;
  }

  List<BookingModel> get upcomingBookings =>
      allBookings.where((b) => b.status == BookingStatus.upcoming).toList();

  List<BookingModel> get activeBookings =>
      allBookings.where((b) => b.status == BookingStatus.active).toList();

  List<BookingModel> get pastBookings =>
      allBookings.where((b) => b.status == BookingStatus.past).toList();

  List<BookingModel> get cancelledBookings =>
      allBookings.where((b) => b.status == BookingStatus.cancelled).toList();

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
