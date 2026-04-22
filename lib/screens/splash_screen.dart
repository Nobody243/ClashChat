import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottiCtrl;
  late final AnimationController _mainCtrl;

  @override
  void initState() {
    super.initState();
    _lottiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();

    _mainCtrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;

        final isLoggedIn = AuthService.isLoggedIn;
        final currentUser = AuthService.currentUser;
        bool shouldNavigateToHome = false;

        if (isLoggedIn && currentUser != null) {
          final isSessionValid = await SessionService.isSessionValid();
          if (!isSessionValid) {
            await AuthService.logout();
            await SessionService.clearSession();
          } else {
            final accountExists = await AuthService.userAccountExists(
              currentUser.uid,
            );
            if (!accountExists) {
              await AuthService.logout();
              await SessionService.clearSession();
            } else {
              shouldNavigateToHome = true;
            }
          }
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                shouldNavigateToHome ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _lottiCtrl.dispose();
    _mainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final botCenterY =
        screenHeight * 0.18 + 80; // approximate center of bot (height 160)

    // Act 1: Bot entrance
    final botOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    final botScale = Tween(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
      ),
    );

    // Act 2: Shockwave
    final shockwaveAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.45, 0.60, curve: Curves.easeOut),
      ),
    );

    // Act 3: Logo slide & spark
    final clashSlide = Tween(begin: -60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    final chatSlide = Tween(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    final logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.55, 0.72, curve: Curves.easeOut),
      ),
    );
    final sparkAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.78, 0.85, curve: Curves.easeOut),
      ),
    );

    // Act 4: Tagline & underline
    final taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.80, 0.92, curve: Curves.easeOut),
      ),
    );
    final taglineSlide = Tween(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.80, 0.92, curve: Curves.easeOut),
      ),
    );
    final underlineAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.88, 0.97, curve: Curves.easeOut),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF2D1B54), // Vibrant purple glow at top
              Color(0xFF0F1A3A), // Deep blue mid
              Color(0xFF0A0A0F), // Dark base
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 1. Shockwave painter
            Positioned.fill(
              child: AnimatedBuilder(
                animation: shockwaveAnim,
                builder: (_, __) => CustomPaint(
                  painter: ShockwavePainter(
                    progress: shockwaveAnim.value,
                    center: Offset(screenWidth / 2, botCenterY),
                  ),
                ),
              ),
            ),

            // 2. Lottie bot
            Positioned(
              top: screenHeight * 0.18,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: botOpacity,
                  child: ScaleTransition(
                    scale: botScale,
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/ChatAi.json',
                        controller: _lottiCtrl,
                        width: 200,
                        height: 160,
                        fit: BoxFit.contain,
                        onLoaded: (comp) {
                          _lottiCtrl.duration = comp.duration;
                          _lottiCtrl.forward();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Logo text row + Spark
            Positioned(
              top: screenHeight * 0.52,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, __) => Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: logoOpacity.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(clashSlide.value, 0),
                            child: Text(
                              'Clash',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(chatSlide.value, 0),
                            child: Text(
                              'Chat',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7F77DD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spark painter
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SparkPainter(
                          progress: sparkAnim.value,
                          center: Offset(
                            screenWidth / 2,
                            27,
                          ), // Offset vertically to align with center of text
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Tagline
            Positioned(
              top: screenHeight * 0.60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, taglineSlide.value),
                  child: Opacity(
                    opacity: taglineOpacity.value,
                    child: Center(
                      child: Text(
                        'Debate. Score. Dominate.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF444466),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Underline painter
            Positioned(
              top: screenHeight * 0.635,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, __) => CustomPaint(
                  painter: UnderlinePainter(
                    progress: underlineAnim.value,
                    center: Offset(screenWidth / 2, 0),
                  ),
                  size: Size(screenWidth, 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShockwavePainter extends CustomPainter {
  final double progress;
  final Offset center;
  ShockwavePainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final maxRadius = size.width * 0.85;
    final radius = maxRadius * Curves.easeOut.transform(progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF7F77DD).withOpacity(opacity * 0.6),
    );
    // Inner ring
    if (progress > 0.15) {
      final innerRadius = maxRadius * Curves.easeOut.transform(progress - 0.15);
      canvas.drawCircle(
        center,
        innerRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(
            0xFF7F77DD,
          ).withOpacity((1.0 - (progress - 0.15)).clamp(0.0, 1.0) * 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(ShockwavePainter old) => old.progress != progress;
}

class SparkPainter extends CustomPainter {
  final double progress;
  final Offset center;
  SparkPainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(
        0xFFCECBF6,
      ).withOpacity((1 - progress).clamp(0.0, 1.0));
    final length = 12.0 * progress;
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];
    for (final deg in angles) {
      final rad = deg * 3.14159 / 180;
      final start = Offset(
        center.dx + 4 * math.cos(rad),
        center.dy + 4 * math.sin(rad),
      );
      final end = Offset(
        center.dx + (4 + length) * math.cos(rad),
        center.dy + (4 + length) * math.sin(rad),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(SparkPainter old) => old.progress != progress;
}

class UnderlinePainter extends CustomPainter {
  final double progress;
  final Offset center;
  UnderlinePainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7F77DD);

    final currentWidth = 80.0 * progress; // 80px each side at full width

    // Draw outward from center
    canvas.drawLine(center, Offset(center.dx - currentWidth, center.dy), paint);
    canvas.drawLine(center, Offset(center.dx + currentWidth, center.dy), paint);
  }

  @override
  bool shouldRepaint(UnderlinePainter old) => old.progress != progress;
}
