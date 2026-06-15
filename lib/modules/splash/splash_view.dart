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

    // Deep colors for a premium automotive startup feel
    final bgColors = [
      const Color(0xFF071B10), // Deep emerald
      const Color(0xFF030705), // Near pitch black green
    ];

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
                      // Glowing Brand Circle with Monogram
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4A843).withValues(alpha: 0.25 * _glowPulse.value),
                                  blurRadius: 35 * _glowPulse.value,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF1B6B3E).withValues(alpha: 0.3 * _glowPulse.value),
                                  blurRadius: 60 * _glowPulse.value,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B6B3E),
                                    Color(0xFF092E16),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFD4A843).withValues(alpha: 0.8),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Subtle spinning inner ring
                                  Transform.rotate(
                                    angle: _animCtrl.value * 2 * 3.14159265,
                                    child: Container(
                                      width: 115,
                                      height: 115,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFD4A843).withValues(alpha: 0.15),
                                          width: 1.5,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Monogram JKW
                                  const Text(
                                    'JKW',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFD4A843), // Gold monogram
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFD4A843).withValues(alpha: 0.3),
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
                          'PREMIUM MOBILITY',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: _textSpacing.value * 0.5,
                            color: Colors.white54,
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
                        color: Colors.white.withValues(alpha: 0.08),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: controller.progress.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1B6B3E),
                                    Color(0xFFD4A843),
                                    Color(0xFFFFF3D6),
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
                  const Text(
                    'INITIALIZING SYSTEM',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: Colors.white38,
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
