import 'dart:async';
import 'package:get/get.dart';
import 'package:jkworlds/app/routes/app_routes.dart';
import 'package:jkworlds/data/services/app_data_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';

class SplashController extends GetxController {
  final progress = 0.0.obs;
  Timer? _timer;
  final _appDataFetched = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchConfig();
    _startLoading();
  }

  Future<void> _fetchConfig() async {
    try {
      await Get.find<AppDataService>().fetchAppData().timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silently catch error to use cached data and avoid blocking startup
    } finally {
      _appDataFetched.value = true;
    }
  }

  void _startLoading() {
    const totalDuration = Duration(milliseconds: 2200);
    const interval = Duration(milliseconds: 30);
    final totalSteps = totalDuration.inMilliseconds / interval.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      currentStep++;
      final targetProgress = currentStep / totalSteps;

      // Pause progress at 90% if API data is not fetched yet,
      // but cap the wait time (3x the normal duration) to prevent freezing.
      if (targetProgress >= 0.9 && !_appDataFetched.value && currentStep < totalSteps * 3) {
        progress.value = 0.9;
      } else {
        progress.value = (currentStep / totalSteps).clamp(0.0, 1.0);
        if (progress.value >= 1.0) {
          timer.cancel();
          _navigateToNext();
        }
      }
    });
  }

  void _navigateToNext() {
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn.value && authService.currentUser.value?.onboardingCompleted == false) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
