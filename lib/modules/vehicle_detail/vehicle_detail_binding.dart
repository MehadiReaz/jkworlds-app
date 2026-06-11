import 'package:get/get.dart';
import 'vehicle_detail_controller.dart';

class VehicleDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VehicleDetailController());
  }
}
