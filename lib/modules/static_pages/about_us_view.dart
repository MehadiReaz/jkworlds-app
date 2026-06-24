import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/app_data_service.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Get.find<AppDataService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text('about'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        final page = appData.pages.firstWhereOrNull((p) => p.key == 'about');
        if (page == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      cs.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.airport_shuttle_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'JKWORLDS SERVICES LIMITED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A trusted provider of premium airport transfers, executive chauffeur services, and private transportation solutions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  _buildStatCard(context, '24/7', 'Customer Support', Icons.support_agent_rounded, cs, isLight),
                  const SizedBox(width: 12),
                  _buildStatCard(context, '100%', 'Professional Chauffeurs', Icons.people_alt_rounded, cs, isLight),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'On-Time', 'Airport Transfers', Icons.schedule_rounded, cs, isLight),
                ],
              ),

              const SizedBox(height: 28),

              // Mission & Story Section
              _buildInfoCard(
                context: context,
                title: 'Our Mission',
                icon: Icons.track_changes_rounded,
                iconColor: cs.primary,
                content: 'Our mission is to provide dependable, high-quality transportation services that make every journey smooth and stress-free. Whether you are travelling for business, leisure, or a special occasion, we aim to deliver a premium experience from pickup to destination.',
                cs: cs,
                theme: theme,
                isLight: isLight,
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                context: context,
                title: 'Our Story',
                icon: Icons.history_edu_rounded,
                iconColor: cs.tertiary,
                content: 'JKWORLDS SERVICES LIMITED was founded with a clear vision: to redefine transportation services through professionalism, punctuality, and exceptional customer care. Over the years, we have earned the trust of our customers by consistently delivering reliable airport transfers and chauffeur-driven services tailored to their needs.',
                cs: cs,
                theme: theme,
                isLight: isLight,
              ),

              const SizedBox(height: 28),

              // Core Values Section
              Text(
                'Our Core Values',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildCoreValuesGrid(cs, theme, isLight),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    ColorScheme cs,
    bool isLight,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    required ColorScheme cs,
    required ThemeData theme,
    required bool isLight,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValuesGrid(ColorScheme cs, ThemeData theme, bool isLight) {
    final values = [
      {'title': 'Safety First', 'desc': 'The safety and well-being of passengers is our highest priority.', 'icon': Icons.security_rounded, 'color': Colors.green},
      {'title': 'Reliability', 'desc': 'We pride ourselves on punctuality and dependable service, every time.', 'icon': Icons.verified_rounded, 'color': Colors.blue},
      {'title': 'Professionalism', 'desc': 'Our chauffeurs and support team maintain the highest standards of service.', 'icon': Icons.business_center_rounded, 'color': Colors.orange},
      {'title': 'Customer Focus', 'desc': 'Every decision is focused on creating an exceptional experience.', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': Colors.pink},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final val = values[index];
        final iconColor = val['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(val['icon'] as IconData, color: iconColor, size: 24),
              const SizedBox(height: 12),
              Text(
                val['title'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  val['desc'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    height: 1.4,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
