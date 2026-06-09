import 'package:get/get.dart';

/// Controls the active bottom navigation tab index.
class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
