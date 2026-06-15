import 'dart:async';
import 'package:get/get.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final progress = 0.0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startLoading();
  }

  void _startLoading() {
    const totalDuration = Duration(milliseconds: 2200);
    const interval = Duration(milliseconds: 30);
    final totalSteps = totalDuration.inMilliseconds / interval.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      currentStep++;
      progress.value = (currentStep / totalSteps).clamp(0.0, 1.0);

      if (currentStep >= totalSteps) {
        timer.cancel();
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    // Clear navigation stack and transition to the main page
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
