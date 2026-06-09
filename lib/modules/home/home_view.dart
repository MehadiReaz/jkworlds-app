import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/app/currency/currency_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyService = Get.find<CurrencyService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'welcome'.tr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'home_subtitle'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Demo: currency-formatted price
              Obx(() => Text(
                    '${'sample_price_label'.tr} ${currencyService.formatPrice(29.99)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
