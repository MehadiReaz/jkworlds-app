import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSpacing;
  late Animation<double> _textOpacity;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textSpacing = Tween<double>(begin: 2.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _glowPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Dynamic background colors matching the theme
    final bgColors = isDark
        ? [
            const Color(0xFF1E1E24), // Rich dark warm grey-black
            const Color(0xFF0C0C0E), // Near pitch black
          ]
        : [
            const Color(0xFFFFF6F0), // Very light soft warm orange-white
            const Color(0xFFEBEBEF), // Clean light grey
          ];

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtitleColor = isDark ? Colors.white54 : const Color(0xFF636366);
    final badgeBgStart = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final badgeBgEnd = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: bgColors,
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Center Brand Content
            Center(
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing Brand Circle with Monogram and Car Icon
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Rotating Speedometer Dial Ring
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: SpeedometerDialPainter(
                                      color: primaryColor,
                                      progress: _animCtrl.value,
                                    ),
                                  ),
                                ),
                                // Glowing background shadow
                                Container(
                                  width: 106,
                                  height: 106,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3 * _glowPulse.value),
                                        blurRadius: 25 * _glowPulse.value,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                // Inner Badge Container
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        badgeBgStart,
                                        badgeBgEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.8),
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.asset(
                                      'assets/pictures/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Brand Logotype
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Text(
                          'J K W O R L D S',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: _textSpacing.value,
                            color: textColor,
                            shadows: [
                              Shadow(
                                color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                                offset: const Offset(0, 0),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Brand Subtitle
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Text(
                          'PREMIUM CAR RENTALS',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: _textSpacing.value * 0.5,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Progress & Info
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  // Sleek Custom Linear Progress Indicator
                  Obx(() {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 2.5,
                        width: double.infinity,
                        color: textColor.withValues(alpha: 0.08),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: controller.progress.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withValues(alpha: 0.7),
                                    primaryColor,
                                    primaryColor.withValues(alpha: 0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Initializing indicator text
                  Text(
                    'PREPARING YOUR RIDE...',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeedometerDialPainter extends CustomPainter {
  final Color color;
  final double progress;

  SpeedometerDialPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const tickCount = 24;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i * 2 * math.pi / tickCount) + (progress * 2 * math.pi);
      final isAccent = i % 4 == 0;
      final tickLength = isAccent ? 8.0 : 4.0;

      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      paint.color = isAccent ? color : color.withOpacity(0.3);
      paint.strokeWidth = isAccent ? 2.5 : 1.5;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpeedometerDialPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
