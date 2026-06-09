import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/models/promo_code.dart';
import 'package:jkworlds/data/services/promo_service.dart';
import 'package:intl/intl.dart';

class PromoCodesView extends StatefulWidget {
  const PromoCodesView({super.key});

  @override
  State<PromoCodesView> createState() => _PromoCodesViewState();
}

class _PromoCodesViewState extends State<PromoCodesView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _promoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _claimPromo(PromoService promoService, ColorScheme cs) async {
    if (!_formKey.currentState!.validate()) return;

    final input = _promoCtrl.text.trim();
    try {
      final success = await promoService.claimPromoCode(input);
      if (success) {
        _promoCtrl.clear();
        Get.snackbar(
          'success'.tr,
          'promo_apply_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cs.primaryContainer,
          colorText: cs.onPrimaryContainer,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cs.errorContainer,
        colorText: cs.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _copyToClipboard(String code, ColorScheme cs) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'promo_copied'.tr,
      'code_copied_msg'.trParams({'code': code}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: cs.secondaryContainer,
      colorText: cs.onSecondaryContainer,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final promoService = Get.find<PromoService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('promo_codes'.tr),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: 'promo_active_tab'.tr),
            Tab(text: 'promo_expired_tab'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Input Field Section ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _promoCtrl,
                      decoration: InputDecoration(
                        labelText: 'promo_input_label'.tr,
                        hintText: 'promo_input_hint'.tr,
                        prefixIcon: const Icon(Icons.local_offer_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'field_required'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => FilledButton(
                      onPressed: promoService.isSubmitting.value
                          ? null
                          : () => _claimPromo(promoService, cs),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: promoService.isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('promo_apply'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tab Bar Views ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Promo Codes List
                Obx(() => _buildPromoList(promoService.activePromos, true, theme, cs)),
                // Expired / Used Promo Codes List
                Obx(() => _buildPromoList(promoService.expiredPromos, false, theme, cs)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoList(List<PromoCode> promos, bool isActive, ThemeData theme, ColorScheme cs) {
    if (promos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.local_offer_outlined : Icons.money_off_rounded,
                  size: 64,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isActive ? 'promo_empty_active'.tr : 'promo_empty_expired'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'promo_empty_desc'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promos.length,
      itemBuilder: (context, index) {
        final promo = promos[index];
        return _buildPromoCard(promo, isActive, theme, cs);
      },
    );
  }

  Widget _buildPromoCard(PromoCode promo, bool isActiveTab, ThemeData theme, ColorScheme cs) {
    final expiryFormatted = DateFormat.yMMMd().format(promo.expiryDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side: Discount Amount & Type
              Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActiveTab
                        ? [cs.primary, cs.primary.withValues(alpha: 0.85)]
                        : [cs.onSurfaceVariant.withValues(alpha: 0.4), cs.onSurfaceVariant.withValues(alpha: 0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      promo.discountText,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promo.isPercentage ? 'OFF' : 'USD',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Dashed line divider
              CustomPaint(
                size: const Size(1, 120),
                painter: DashedLinePainter(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),

              // Right side: Details and Actions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isActiveTab
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                promo.code,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isActiveTab ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              promo.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  promo.isUsed
                                      ? 'promo_used'.tr
                                      : 'promo_expires_on'.trParams({'date': expiryFormatted}),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Copy Icon Button
                      if (isActiveTab)
                        IconButton.filledTonal(
                          onPressed: () => _copyToClipboard(promo.code, cs),
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: 'promo_copy'.tr,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ticket Cutout Clipper ───────────────────────────────────────────
class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double cutPosition; // position from left ratio

  TicketClipper({this.punchRadius = 8.0, this.cutPosition = 100.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final x = cutPosition;

    path.lineTo(x - punchRadius, 0);
    path.arcToPoint(
      Offset(x + punchRadius, 0),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(x + punchRadius, size.height);
    path.arcToPoint(
      Offset(x - punchRadius, size.height),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) =>
      oldClipper.punchRadius != punchRadius || oldClipper.cutPosition != cutPosition;
}

// ── Dashed Vertical Line Painter ────────────────────────────────────
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  DashedLinePainter({
    this.color = Colors.grey,
    this.dashHeight = 5.0,
    this.dashSpace = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
