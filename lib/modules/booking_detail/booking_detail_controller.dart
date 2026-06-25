import 'package:get/get.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/core/utils/logger.dart';

class BookingDetailsController extends GetxController {
  late final int bookingId;
  final booking = Rxn<BookingModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      bookingId = args;
    } else if (args is String) {
      bookingId = int.tryParse(args) ?? 0;
    } else {
      bookingId = 0;
    }
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      logger.i('[BookingDetailsController] Fetching booking detail for ID: $bookingId');
      final result = await Get.find<BookingService>().fetchBookingDetail(bookingId);
      booking.value = result;
    } catch (e, st) {
      logger.e('[BookingDetailsController] Error fetching booking detail', error: e, stackTrace: st);
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
