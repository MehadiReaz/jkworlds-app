import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/modules/profile/profile_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';

class PreferencesView extends StatelessWidget {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final expansibleCurrencyCtrl = ExpansibleController();
    final expansibleLanguageCtrl = ExpansibleController();
    final profileCtrl = Get.find<ProfileController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('preferences'.tr)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── Language Section ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Expansible(
              controller: expansibleLanguageCtrl,
              headerBuilder: (context, animation) {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    expansibleLanguageCtrl.isExpanded
                        ? expansibleLanguageCtrl.collapse()
                        : expansibleLanguageCtrl.expand();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.language,
                            size: 20,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'language'.tr,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentLanguageName(profileCtrl),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          expansibleLanguageCtrl.isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
              bodyBuilder: (context, animation) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    children: profileCtrl.locales.map((item) {
                      final locale = item['locale'] as Locale;
                      final name = item['name'] as String;
                      final isSelected =
                          Get.locale?.languageCode == locale.languageCode;
                      return ListTile(
                        dense: true,
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? cs.primary
                                    : cs.onSurface,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle_rounded,
                                  color: cs.primary,
                                  size: 20,
                                )
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => profileCtrl.changeLocale(locale),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Currency Section ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Expansible(
              controller: expansibleCurrencyCtrl,
              headerBuilder: (context, animation) {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    expansibleCurrencyCtrl.isExpanded
                        ? expansibleCurrencyCtrl.collapse()
                        : expansibleCurrencyCtrl.expand();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.attach_money_rounded,
                            size: 20,
                            color: cs.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'currency'.tr,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${currencyService.selectedCurrency.value.symbol} ${currencyService.selectedCurrency.value.code}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          expansibleCurrencyCtrl.isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
              bodyBuilder: (context, animation) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Obx(
                    () => Column(
                      children: currencyService.currencies.map((cur) {
                        final isSelected =
                            currencyService.selectedCurrency.value.code ==
                            cur.code;
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${cur.symbol}  ${cur.name}',
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  isSelected
                                      ? cs.primary
                                      : cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            cur.code,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                    Icons.check_circle_rounded,
                                    color: cs.primary,
                                    size: 20,
                                  )
                                  : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () =>
                              currencyService.changeCurrency(cur.code),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _currentLanguageName(ProfileController ctrl) {
    final currentCode = Get.locale?.languageCode ?? 'en';
    for (final item in ctrl.locales) {
      final locale = item['locale'] as Locale;
      if (locale.languageCode == currentCode) {
        return item['name'] as String;
      }
    }
    return 'English';
  }
}
