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
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

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
              _buildBookingFormSection(ctrl, theme, cs, isLight, context),

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
  // 2. BOOKING FORM SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildBookingFormSection(
    HomeController ctrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
    BuildContext context,
  ) {
    final exploreCtrl = Get.find<ExploreController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Obx(() {
        final activeTab = ctrl.selectedBookingTab.value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1C22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tab Selectors ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Cars',
                      isActive: activeTab == 'Cars',
                      onTap: () {
                        ctrl.selectedBookingTab.value = 'Cars';
                      },
                      cs: cs,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Airport Transfer',
                      isActive: activeTab == 'Airport Transfer',
                      onTap: () {
                        ctrl.selectedBookingTab.value = 'Airport Transfer';
                      },
                      cs: cs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── COMPACT PICK-UP LOCATION BUTTON ────────────────────
              _buildInputLabel(
                activeTab == 'Cars' ? 'PICK-UP LOCATION' : 'PICKUP LOCATION',
                cs,
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _showFullBookingBottomSheet(context, ctrl, exploreCtrl, theme, cs, isLight),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        activeTab == 'Cars' ? Icons.location_on_rounded : Icons.flight_takeoff_rounded,
                        color: cs.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => Text(
                              exploreCtrl.pickupLocation.value.isEmpty
                                  ? (activeTab == 'Cars' ? 'Enter pick-up location' : 'Enter pickup location')
                                  : exploreCtrl.pickupLocation.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: exploreCtrl.pickupLocation.value.isEmpty
                                    ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                    : cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showFullBookingBottomSheet(
    BuildContext context,
    HomeController ctrl,
    ExploreController exploreCtrl,
    ThemeData theme,
    ColorScheme cs,
    bool isLight,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER WITH CLOSE BUTTON ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Book Your Ride',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
                
                // ── SCROLLABLE CONTAINER FOR THE FORM ─────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Obx(() {
                      final activeTab = ctrl.selectedBookingTab.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Cars',
                                  isActive: activeTab == 'Cars',
                                  onTap: () {
                                    ctrl.selectedBookingTab.value = 'Cars';
                                  },
                                  cs: cs,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Airport Transfer',
                                  isActive: activeTab == 'Airport Transfer',
                                  onTap: () {
                                    ctrl.selectedBookingTab.value = 'Airport Transfer';
                                  },
                                  cs: cs,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          if (activeTab == 'Cars') ...[
                            // ── CARS FORM ────────────────────────────────
                            _buildInputLabel('PICK-UP LOCATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: exploreCtrl.pickupLocationCtrl,
                              hint: 'Enter pick-up location',
                              icon: Icons.location_on_rounded,
                              onChanged: (val) {
                                exploreCtrl.updatePickupLocation(val);
                              },
                              isLoading: exploreCtrl.isLoadingPickup.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: exploreCtrl.pickupSuggestions,
                              onSelect: (val) => exploreCtrl.selectPickupSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),



                            _buildDateTimeRow(
                              label: 'PICK-UP DATE & TIME',
                              dateTimeRx: exploreCtrl.pickupDateTime,
                              exploreCtrl: exploreCtrl,
                              theme: theme,
                              cs: cs,
                              isLight: isLight,
                              context: context,
                            ),
                            const SizedBox(height: 14),

                            _buildDateTimeRow(
                              label: 'DROP-OFF DATE & TIME',
                              dateTimeRx: exploreCtrl.dropoffDateTime,
                              exploreCtrl: exploreCtrl,
                              theme: theme,
                              cs: cs,
                              isLight: isLight,
                              context: context,
                            ),
                            const SizedBox(height: 24),

                            _buildSubmitButton(
                              title: 'Show Vehicles',
                              onTap: () {
                                Get.back(); // Dismiss bottom sheet
                                exploreCtrl.selectedServiceType.value = 'All';
                                exploreCtrl.isChauffeurRequired.value = false;
                                exploreCtrl.isDifferentDropoff.value = false;
                                exploreCtrl.dropoffLocation.value = '';
                                exploreCtrl.dropoffLocationCtrl.clear();
                                exploreCtrl.applyFilters();
                                ctrl.navigateToExplore(resetToAll: false);
                              },
                              cs: cs,
                            ),
                          ] else ...[
                            // ── AIRPORT TRANSFER FORM ────────────────────
                            Text(
                              'Ride your way',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildInputLabel('PICKUP LOCATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: exploreCtrl.pickupLocationCtrl,
                              hint: 'Enter pickup location',
                              icon: Icons.flight_takeoff_rounded,
                              onChanged: (val) {
                                exploreCtrl.updatePickupLocation(val);
                              },
                              isLoading: exploreCtrl.isLoadingPickup.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: exploreCtrl.pickupSuggestions,
                              onSelect: (val) => exploreCtrl.selectPickupSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('DESTINATION', cs),
                            const SizedBox(height: 6),
                            _buildLocationField(
                              controller: exploreCtrl.dropoffLocationCtrl,
                              hint: 'Enter destination',
                              icon: Icons.flight_land_rounded,
                              onChanged: (val) {
                                exploreCtrl.updateDropoffLocation(val);
                              },
                              isLoading: exploreCtrl.isLoadingDropoff.value,
                              cs: cs,
                              isLight: isLight,
                            ),
                            _buildSuggestionsList(
                              suggestions: exploreCtrl.dropoffSuggestions,
                              onSelect: (val) => exploreCtrl.selectDropoffSuggestion(val),
                              theme: theme,
                              cs: cs,
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('PICKUP DATE', cs),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectSingleDate(context, exploreCtrl.pickupDateTime, exploreCtrl),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: cs.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Obx(() => Text(
                                          exploreCtrl.pickupDateTime.value == null
                                              ? 'Select date'
                                              : DateFormat('EEEE, MMMM d, yyyy').format(exploreCtrl.pickupDateTime.value!),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: exploreCtrl.pickupDateTime.value == null
                                                ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                                : cs.onSurface,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildInputLabel('PICKUP TIME', cs),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectTime(context, exploreCtrl.pickupDateTime, exploreCtrl),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, color: cs.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Obx(() => Text(
                                          exploreCtrl.pickupDateTime.value == null
                                              ? 'Select time'
                                              : DateFormat('h:mm a').format(exploreCtrl.pickupDateTime.value!),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: exploreCtrl.pickupDateTime.value == null
                                                ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                                : cs.onSurface,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildSubmitButton(
                              title: 'Show Cars',
                              onTap: () {
                                Get.back(); // Dismiss bottom sheet
                                exploreCtrl.selectedServiceType.value = 'Chauffeur';
                                exploreCtrl.isChauffeurRequired.value = true;
                                exploreCtrl.isDifferentDropoff.value = true;
                                exploreCtrl.dropoffLocation.value = exploreCtrl.dropoffLocationCtrl.text;
                                exploreCtrl.applyFilters();
                                ctrl.navigateToExplore(resetToAll: false);
                              },
                              cs: cs,
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? cs.primary : (Get.isDarkMode ? const Color(0xFF161A22) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : (Get.isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required bool isLoading,
    required ColorScheme cs,
    required bool isLight,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.primary, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
        filled: true,
        fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const SizedBox.shrink(),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSuggestionsList({
    required List<dynamic> suggestions,
    required ValueChanged<dynamic> onSelect,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      if (suggestions.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: Icon(Icons.location_on_rounded, color: cs.primary, size: 18),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (suggestion.typeLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (suggestion.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              dense: true,
              onTap: () => onSelect(suggestion),
            );
          },
        ),
      );
    });
  }

  Widget _buildDateTimeRow({
    required String label,
    required Rxn<DateTime> dateTimeRx,
    required ExploreController exploreCtrl,
    required ThemeData theme,
    required ColorScheme cs,
    required bool isLight,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label, cs),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDateRange(context, exploreCtrl),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Obx(() => Text(
                        dateTimeRx.value == null
                            ? 'Select Date'
                            : DateFormat('MMM d, yyyy').format(dateTimeRx.value!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: dateTimeRx.value == null
                              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, dateTimeRx, exploreCtrl),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Obx(() => Text(
                        dateTimeRx.value == null
                            ? 'Select Time'
                            : DateFormat('h:mm a').format(dateTimeRx.value!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: dateTimeRx.value == null
                              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String title,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _selectSingleDate(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) async {
    final isPickup = rxDateTime == ctrl.pickupDateTime;
    
    // Determine bounds
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));
    
    if (isPickup) {
      // Pick-up date
      if (ctrl.dropoffDateTime.value != null) {
        // Must be lower than dropoff date
        final maxSelectable = ctrl.dropoffDateTime.value!.subtract(const Duration(days: 1));
        if (maxSelectable.isAfter(firstDate)) {
          lastDate = maxSelectable;
        } else {
          lastDate = firstDate;
        }
      }
    } else {
      // Drop-off date
      if (ctrl.pickupDateTime.value == null) {
        SnackbarHelper.showWarning('Please select a pick-up date first.');
        return;
      }
      firstDate = ctrl.pickupDateTime.value!.add(const Duration(days: 1));
      if (lastDate.isBefore(firstDate)) {
        lastDate = firstDate.add(const Duration(days: 365));
      }
    }

    final current = rxDateTime.value ?? (isPickup ? DateTime.now() : ctrl.pickupDateTime.value!.add(const Duration(days: 1)));
    
    // Ensure initialDate is within firstDate and lastDate bounds
    DateTime initialDate = current;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return;

    rxDateTime.value = DateTime(
      date.year,
      date.month,
      date.day,
      current.hour,
      current.minute,
    );

    // If pickup date was selected, check if drop-off date needs to be reset
    if (isPickup) {
      if (ctrl.dropoffDateTime.value != null && !ctrl.dropoffDateTime.value!.isAfter(rxDateTime.value!)) {
        ctrl.dropoffDateTime.value = null;
      }
    }

    ctrl.applyFilters();
  }

  Future<void> _selectDateRange(BuildContext context, ExploreController ctrl) async {
    final initialRange = ctrl.pickupDateTime.value != null && ctrl.dropoffDateTime.value != null
        ? DateTimeRange(start: ctrl.pickupDateTime.value!, end: ctrl.dropoffDateTime.value!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              secondaryContainer: theme.colorScheme.primary.withValues(alpha: 0.15),
              onSecondaryContainer: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      final pickupCurrent = ctrl.pickupDateTime.value;
      final dropoffCurrent = ctrl.dropoffDateTime.value;

      ctrl.pickupDateTime.value = DateTime(
        pickedRange.start.year,
        pickedRange.start.month,
        pickedRange.start.day,
        pickupCurrent?.hour ?? 9,
        pickupCurrent?.minute ?? 0,
      );

      ctrl.dropoffDateTime.value = DateTime(
        pickedRange.end.year,
        pickedRange.end.month,
        pickedRange.end.day,
        dropoffCurrent?.hour ?? 17,
        dropoffCurrent?.minute ?? 0,
      );

      ctrl.applyFilters();
    }
  }

  Future<void> _selectTime(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) async {
    _showTimeListBottomSheet(context, rxDateTime, ctrl);
  }

  void _showTimeListBottomSheet(BuildContext context, Rxn<DateTime> rxDateTime, ExploreController ctrl) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    
    final categories = {
      'Early Morning': [
        const TimeOfDay(hour: 6, minute: 0),
        const TimeOfDay(hour: 6, minute: 30),
        const TimeOfDay(hour: 7, minute: 0),
        const TimeOfDay(hour: 7, minute: 30),
      ],
      'Morning - afternoon': [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 8, minute: 30),
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 9, minute: 30),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 10, minute: 30),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 11, minute: 30),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 12, minute: 30),
        const TimeOfDay(hour: 13, minute: 0),
        const TimeOfDay(hour: 13, minute: 30),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 14, minute: 30),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 15, minute: 30),
        const TimeOfDay(hour: 16, minute: 0),
        const TimeOfDay(hour: 16, minute: 30),
      ],
      'Evening - Night': [
        const TimeOfDay(hour: 17, minute: 0),
        const TimeOfDay(hour: 17, minute: 30),
        const TimeOfDay(hour: 18, minute: 0),
        const TimeOfDay(hour: 18, minute: 30),
        const TimeOfDay(hour: 19, minute: 0),
        const TimeOfDay(hour: 19, minute: 30),
        const TimeOfDay(hour: 20, minute: 0),
        const TimeOfDay(hour: 20, minute: 30),
        const TimeOfDay(hour: 21, minute: 0),
        const TimeOfDay(hour: 21, minute: 30),
        const TimeOfDay(hour: 22, minute: 0),
        const TimeOfDay(hour: 22, minute: 30),
        const TimeOfDay(hour: 23, minute: 0),
        const TimeOfDay(hour: 23, minute: 30),
        const TimeOfDay(hour: 0, minute: 0),
      ],
    };

    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$displayHour:$minuteStr $period';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 20, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Opening Times: 6:00 AM - 12:00 AM',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              
              // Scrollable list of categories
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.entries.map((entry) {
                      final categoryTitle = entry.key;
                      final times = entry.value;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.8,
                            children: times.map((t) {
                              return Obx(() {
                                final isSelected = rxDateTime.value != null &&
                                    rxDateTime.value!.hour == t.hour &&
                                    rxDateTime.value!.minute == t.minute;
                                
                                return InkWell(
                                  onTap: () {
                                    final current = rxDateTime.value ?? DateTime.now();
                                    rxDateTime.value = DateTime(
                                      current.year,
                                      current.month,
                                      current.day,
                                      t.hour,
                                      t.minute,
                                    );
                                    ctrl.applyFilters();
                                    Get.back(); // Close bottom sheet
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isLight ? const Color(0xFF161A22) : cs.primary)
                                          : (isLight ? Colors.grey.shade100 : const Color(0xFF161A22)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      formatTimeOfDay(t),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      final auth = Get.find<AuthService>();
      final isLoggedIn = auth.isLoggedIn.value;

      if (!isLoggedIn) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('your_active_ride'.tr, null, theme, cs),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_open_rounded, color: cs.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Prompt text and button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'view_bookings_prompt'.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'view_bookings_prompt_desc'.tr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: FilledButton(
                              onPressed: () => Get.toNamed(AppRoutes.login),
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'login'.tr.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        );
      }

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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSectionHeader(
              'categories'.tr,
              () => ctrl.navigateToExplore(),
              theme,
              cs,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: Obx(() {
              if (ctrl.isLoadingCategories.value) {
                return _buildCategoryShimmer(theme, cs);
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ctrl.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = ctrl.categories[index];
                  final icon = getCategoryIcon(category);
                  final catModel = ctrl.apiCategories.firstWhereOrNull((c) => c.name == category);
                  final imageUrl = catModel?.image;

                  return Obx(() {
                    final isSelected = ctrl.selectedCategory.value == category;
                    return GestureDetector(
                      onTap: () => ctrl.selectCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : (theme.brightness == Brightness.light
                                  ? Colors.white
                                  : const Color(0xFF1A1C22)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.primary,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  icon,
                                  size: 20,
                                  color: isSelected
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant,
                                ),
                              )
                            else
                              Icon(
                                icon,
                                size: 20,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.onSurface,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 12,
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
                        Text(vehicle.brand,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),),
                        const SizedBox(height: 3),
                        Text(
                          vehicle.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        ],
                    ),
                    Row(
                      children: [
                        // Specs
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildMiniSpec(Icons.people_outline_rounded,
                                    '${vehicle.seats}', cs),
                                const SizedBox(width: 8),
                                _buildMiniSpec(
                                    Icons.settings_input_component_rounded,
                                    vehicle.transmission == 'Automatic'
                                        ? 'Auto'
                                        : 'Manual',
                                    cs),
                                const SizedBox(width: 8),
                                _buildMiniSpec(
                                    Icons.ev_station,
                                    vehicle.fuelType,
                                    cs),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
