import 'package:get/get.dart';
import 'booking_detail_controller.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingDetailsController());
  }
}
