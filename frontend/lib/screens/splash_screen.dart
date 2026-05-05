import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:net_fence_ai/screens/main_shell.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.accentNavy, AppTheme.accentBlue],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final translateY = Tween<double>(begin: 0.0, end: -6.0)
                          .chain(CurveTween(curve: Curves.easeInOut))
                          .evaluate(_floatController);
                      return Transform.translate(
                        offset: Offset(0, translateY),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 38,
                        color: AppTheme.accentNavy,
                      ),
                    ).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), duration: 700.ms, curve: Curves.easeOut),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Net-Fence',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).move(begin: const Offset(0, 20), end: Offset.zero, duration: 600.ms, curve: Curves.easeOut),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'AI',
                          style: GoogleFonts.inter(
                            color: AppTheme.accentBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).move(begin: const Offset(0, 20), end: Offset.zero, duration: 600.ms, curve: Curves.easeOut),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Intelligent Network Intrusion Detection System',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      letterSpacing: 0.8,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Advanced Wi-Fi Threat Detection with Isolation Forest ML',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 0.5,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
