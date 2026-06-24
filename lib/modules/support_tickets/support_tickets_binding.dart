import 'package:get/get.dart';
import 'support_tickets_controller.dart';

class SupportTicketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupportTicketsController());
  }
}
