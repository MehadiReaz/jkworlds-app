import 'package:get/get.dart';

import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/modules/home/home_controller.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';
import 'package:jkworlds/modules/profile/profile_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ExploreController());
    Get.lazyPut(() => OrdersController());
    Get.lazyPut(() => ProfileController());
  }
}
