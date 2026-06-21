import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'home_controller.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/core/constants/api_constants.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final currencyService = Get.find<CurrencyService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Greeting Header ─────────────────────────────────
              _buildGreetingHeader(ctrl, theme, cs, isLight),

              // ── 2. Quick Search Bar ────────────────────────────────
              _buildSearchBar(ctrl, theme, cs, isLight),

              // ── 3. Promotional Banner Carousel ─────────────────────
              _buildPromoCarousel(ctrl, theme, cs, isLight),

              // ── 4. Active Booking Card ─────────────────────────────
              _buildActiveBookingCard(ctrl, theme, cs, isLight, currencyService),

              // ── 5. Category Quick-Access Row ───────────────────────
              _buildCategorySection(ctrl, theme, cs),

              // ── 6. Featured Vehicles Carousel ──────────────────────
              _buildFeaturedSection(ctrl, theme, cs, isLight, currencyService),

              // ── 7. Top Rated ──────────────────────────────────────
              _buildTopRatedSection(ctrl, theme, cs, isLight, currencyService),

              // ── 8. Trust Badges ────────────────────────────────────
              _buildTrustBadges(theme, cs, isLight),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 1. GREETING HEADER
  // ══════════════════════════════════════════════════════════════════
  Widget _buildGreetingHeader(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final auth = Get.find<AuthService>();
                  final name = auth.userName.value.isNotEmpty
                      ? auth.userName.value
                      : 'guest'.tr;
                  return Text(
                    '${ctrl.greeting}, $name',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: cs.onSurface,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Text(
                  'find_perfect_ride'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          IconButton(
            onPressed: ctrl.navigateToNotifications,
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 26,
                  color: cs.onSurfaceVariant,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // User avatar
          Obx(() {
            final auth = Get.find<AuthService>();
            final photoUrl = auth.userPhotoUrl.value;
            return GestureDetector(
              onTap: ctrl.navigateToProfile,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.primary, width: 2),
                  color: cs.primaryContainer,
                ),
                child: ClipOval(
                  child: _buildAvatarImage(photoUrl, cs),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String path, ColorScheme cs) {
    if (path.isEmpty) {
      return Icon(Icons.person_rounded, color: cs.primary, size: 22);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: cs.primary, size: 22),
      );
    }

    final isNetworkPath = path.contains('backend/image') ||
        (!path.startsWith('/') && !path.contains(':/') && !path.startsWith('content:'));

    if (isNetworkPath) {
      final fullUrl = path.startsWith('/')
          ? '${ApiConstants.baseUrl}$path'
          : '${ApiConstants.baseUrl}/$path';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: cs.primary, size: 22),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: cs.primary, size: 22),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. QUICK SEARCH BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: ctrl.navigateToExplore,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1C22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'search_brand_model'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: cs.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 3. PROMO BANNER CAROUSEL
  // ══════════════════════════════════════════════════════════════════
  Widget _buildPromoCarousel(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
  ) {
    final promos = [
      _PromoData(
        title: 'promo_title'.tr,
        subtitle: 'promo_subtitle'.tr,
        gradient: [const Color(0xFF1B6B3E), const Color(0xFF2E8B57)],
        icon: Icons.local_offer_rounded,
      ),
      _PromoData(
        title: 'luxury_weekend'.tr,
        subtitle: 'luxury_weekend_subtitle'.tr,
        gradient: [const Color(0xFFD4A843), const Color(0xFFB8860B)],
        icon: Icons.diamond_rounded,
      ),
      _PromoData(
        title: 'chauffeur_service_promo'.tr,
        subtitle: 'sit_back_relax'.tr,
        gradient: [const Color(0xFF1A3A2A), const Color(0xFF0D2818)],
        icon: Icons.airline_seat_recline_extra_rounded,
      ),
    ];

    final pageController = PageController(viewportFraction: 0.92);

    // Sync page controller with reactive index
    ever(ctrl.currentPromoIndex, (index) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: pageController,
            itemCount: promos.length,
            onPageChanged: (index) => ctrl.setPromoIndex(index),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return GestureDetector(
                onTap: ctrl.navigateToExplore,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: promo.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: promo.gradient[0].withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    promo.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    promo.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'book_now_short'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                promo.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dot Indicators
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                promos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: ctrl.currentPromoIndex.value == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ctrl.currentPromoIndex.value == index
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 4. ACTIVE BOOKING CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildActiveBookingCard(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    CurrencyService currencyService,
  ) {
    return Obx(() {
      final booking = ctrl.activeBooking.value;
      if (booking == null) return const SizedBox.shrink();

      final daysRemaining = booking.returnDate.difference(DateTime.now()).inDays;
      final totalDays = booking.totalDays;
      final progress = totalDays > 0
          ? ((totalDays - daysRemaining.clamp(0, totalDays)) / totalDays).clamp(0.0, 1.0)
          : 0.0;

      final isActive = booking.status.name == 'active';
      final statusColor = isActive ? Colors.green : Colors.blue;
      final statusText = isActive ? 'active'.tr.toUpperCase() : 'upcoming'.tr.toUpperCase();

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('your_active_ride'.tr, null, theme, cs),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: ctrl.navigateToBookings,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF1A1C22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Vehicle thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 72,
                            height: 52,
                            child: (booking.vehicle?.images.isNotEmpty ?? false)
                                ? Image.network(
                                    booking.vehicle!.images[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: cs.surfaceContainerHighest,
                                      child: Icon(Icons.directions_car_rounded,
                                          color: cs.primary, size: 24),
                                    ),
                                  )
                                : Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(Icons.directions_car_rounded,
                                        color: cs.primary, size: 24),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Vehicle info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${booking.vehicle?.brand ?? ''} ${booking.vehicle?.name ?? 'Active Booking'}'
                                    .trim()
                                    .replaceAll(RegExp(r'\s*\(.*\)'), ''),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${DateFormat('MMM d').format(booking.pickupDate)} — ${DateFormat('MMM d').format(booking.returnDate)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${daysRemaining > 0 ? daysRemaining : 0} ${'days_remaining'.tr}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // 5. CATEGORY SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCategorySection(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
  ) {
    IconData getCategoryIcon(String name) {
      final normalized = name.trim().toLowerCase();
      if (normalized == 'all') return Icons.grid_view_rounded;
      if (normalized.contains('sedan') || normalized.contains('car')) return Icons.directions_car_rounded;
      if (normalized.contains('suv') || normalized.contains('jeep')) return Icons.directions_car_filled_rounded;
      if (normalized.contains('luxury') || normalized.contains('sports') || normalized.contains('exotic')) return Icons.diamond_rounded;
      if (normalized.contains('van') || normalized.contains('bus') || normalized.contains('shuttle')) return Icons.airport_shuttle_rounded;
      if (normalized.contains('truck') || normalized.contains('pickup')) return Icons.local_shipping_rounded;
      return Icons.category_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          _buildSectionHeader(
            'categories'.tr,
            () => ctrl.navigateToExplore(),
            theme,
            cs,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Obx(() {
              if (ctrl.isLoadingCategories.value) {
                return _buildCategoryShimmer(theme, cs);
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctrl.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = ctrl.categories[index];
                  final icon = getCategoryIcon(category);
                  return Obx(() {
                    final isSelected = ctrl.selectedCategory.value == category;
                    return GestureDetector(
                      onTap: () => ctrl.selectCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : (theme.brightness == Brightness.light
                                  ? Colors.white
                                  : const Color(0xFF1A1C22)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 26,
                              color: isSelected
                                  ? cs.onPrimary
                                  : cs.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShimmer(ThemeData theme, ColorScheme cs) {
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade800;
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade700;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 6. FEATURED VEHICLES CAROUSEL
  // ══════════════════════════════════════════════════════════════════
  Widget _buildFeaturedSection(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    CurrencyService currencyService,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader(
            'featured_vehicles'.tr,
            () => ctrl.navigateToExplore(),
            theme,
            cs,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ctrl.featuredVehicles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final vehicle = ctrl.featuredVehicles[index];
                  return _buildFeaturedCard(
                    vehicle,
                    ctrl,
                    theme,
                    cs,
                    isLight,
                    currencyService,
                  );
                },
              )),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedCard(
    VehicleModel vehicle,
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    CurrencyService currencyService,
  ) {
    final cleanName = '${vehicle.brand} ${vehicle.name}'
        .replaceAll(RegExp(r'\s*\(.*\)'), '');

    return GestureDetector(
      onTap: () => ctrl.navigateToVehicleDetail(vehicle),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1C22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.15),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image portion
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    vehicle.images.isNotEmpty
                        ? Image.network(
                            vehicle.images[0],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: cs.surfaceContainerHighest,
                              child: Icon(Icons.directions_car_rounded,
                                  size: 48, color: cs.primary),
                            ),
                          )
                        : Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.directions_car_rounded,
                                size: 48, color: cs.primary),
                          ),
                    // Rating badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              vehicle.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (vehicle.discountPercentage > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935), // Sleek discount red
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${vehicle.discountPercentage}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (vehicle.hasChauffeur)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_rounded,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 3),
                                  Text(
                                    'CHAUFFEUR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content portion
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 12,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                vehicle.location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Specs
                        _buildMiniSpec(Icons.people_outline_rounded,
                            '${vehicle.seats}', cs),
                        const SizedBox(width: 10),
                        _buildMiniSpec(
                            Icons.settings_input_component_rounded,
                            vehicle.transmission == 'Automatic'
                                ? 'Auto'
                                : 'Manual',
                            cs),
                        const Spacer(),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              vehicle.totalPriceFormatted.isNotEmpty
                                  ? vehicle.totalPriceFormatted
                                  : currencyService.formatPrice(vehicle.totalPrice > 0 ? vehicle.totalPrice : vehicle.pricePerDay),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vehicle.dailyRateFormatted.isNotEmpty
                                  ? vehicle.dailyRateFormatted
                                  : currencyService.formatPrice(vehicle.pricePerDay),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                              ),
                            ),
                            Text(
                              '/DAY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 7. TOP RATED VEHICLES
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTopRatedSection(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    CurrencyService currencyService,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(
            'top_rated_vehicles'.tr,
            () => ctrl.navigateToExplore(),
            theme,
            cs,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final vehicles = ctrl.topRatedVehicles.take(5).toList();
            return Column(
              children: vehicles
                  .map((v) => _buildTopRatedCard(
                      v, ctrl, theme, cs, isLight, currencyService))
                  .toList(),
            );
          }),
          // View All button
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              onPressed: ctrl.navigateToExplore,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: cs.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'view_all'.tr,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: cs.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopRatedCard(
    VehicleModel vehicle,
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    CurrencyService currencyService,
  ) {
    final cleanName = '${vehicle.brand} ${vehicle.name}'
        .replaceAll(RegExp(r'\s*\(.*\)'), '');

    return GestureDetector(
      onTap: () => ctrl.navigateToVehicleDetail(vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1C22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 68,
                child: vehicle.images.isNotEmpty
                    ? Image.network(
                        vehicle.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.directions_car_rounded,
                              color: cs.primary, size: 24),
                        ),
                      )
                    : Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.directions_car_rounded,
                            color: cs.primary, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 12,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          vehicle.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Rating
                      Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        vehicle.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' (${vehicle.reviewCount})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (vehicle.hasDiscount) ...[
                  Text(
                    vehicle.totalPriceFormatted.isNotEmpty
                        ? vehicle.totalPriceFormatted
                        : currencyService.formatPrice(vehicle.totalPrice),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle.dailyRateFormatted.isNotEmpty
                        ? vehicle.dailyRateFormatted
                        : currencyService.formatPrice(vehicle.pricePerDay),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ] else ...[
                  Text(
                    vehicle.dailyRateFormatted.isNotEmpty
                        ? vehicle.dailyRateFormatted
                        : currencyService.formatPrice(vehicle.pricePerDay),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ],
                Text(
                  '/DAY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 8. TRUST BADGES
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTrustBadges(ThemeData theme, ColorScheme cs, bool isLight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          _buildSectionHeader('why_choose_us'.tr, null, theme, cs),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrustBadge(
                  Icons.shield_rounded,
                  'fully_insured'.tr,
                  'all_vehicles_covered'.tr,
                  cs,
                  isLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTrustBadge(
                  Icons.star_rounded,
                  'top_rated_service'.tr,
                  'avg_rating'.tr,
                  cs,
                  isLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTrustBadge(
                  Icons.directions_car_rounded,
                  'premium_fleet'.tr,
                  'luxury_vehicles_count'.tr,
                  cs,
                  isLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(
    IconData icon,
    String title,
    String subtitle,
    ColorScheme cs,
    bool isLight,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isLight ? 0.05 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
    String title,
    VoidCallback? onSeeAll,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'see_all'.tr,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: cs.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMiniSpec(IconData icon, String text, ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ── Promo Data Model (private) ──────────────────────────────────
class _PromoData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  const _PromoData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}
