import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import 'main_nav_controller.dart';
import 'package:jkworlds/modules/home/home_view.dart';
import 'package:jkworlds/modules/explore/explore_view.dart';
import 'package:jkworlds/modules/orders/orders_view.dart';
import 'package:jkworlds/modules/profile/profile_view.dart';
import 'package:jkworlds/core/utils/dialog_helper.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is available
    final ctrl = Get.find<MainNavController>();

    final pages = const [
      HomeView(),
      ExploreView(),
      OrdersView(),
      ProfileView(),
    ];

    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (ctrl.currentIndex.value != 0) {
            ctrl.changePage(0);
          } else {
            DialogHelper.showConfirmation(
              title: 'exit_confirm_title'.tr,
              message: 'exit_confirm_message'.tr,
              isDestructive: true,
              onConfirm: () => SystemNavigator.pop(),
            );
          }
        },
        child: Scaffold(
          body: IndexedStack(index: ctrl.currentIndex.value, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: ctrl.currentIndex.value,
            onTap: ctrl.changePage,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore_outlined),
                activeIcon: const Icon(Icons.explore),
                label: 'explore'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long),
                label: 'orders'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: 'profile'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
