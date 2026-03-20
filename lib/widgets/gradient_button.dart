import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  // Continuous shimmer sweep
  late AnimationController _shimmerCtrl;
  // Press-scale
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          height: 56,
          child: AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (context, child) {
              // Sweep the shimmer band from left to right, then loop.
              // t goes 0 → 1 over 1800 ms.
              final t = _shimmerCtrl.value;
              // Map shimmer band position: -0.5 → 1.5 (off-screen left to off-screen right)
              final shimmerX = -0.5 + t * 2.0;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 44,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: _ShimmerButtonPainter(
                      shimmerX: shimmerX,
                      baseColors: const [AppColors.primary, AppColors.gold],
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a flowing color-band shimmer over the base gradient.
class _ShimmerButtonPainter extends CustomPainter {
  final double shimmerX;
  final List<Color> baseColors;

  const _ShimmerButtonPainter({
    required this.shimmerX,
    required this.baseColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base gradient (purple → gold)
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: baseColors,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Flowing shimmer band (a bright skewed stripe)
    final bandWidth = size.width * 0.55;
    final centerX = shimmerX * size.width;
    final shimmerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [
          math.max(0.0, (centerX - bandWidth * 0.5) / size.width),
          (centerX / size.width).clamp(0.0, 1.0),
          math.min(1.0, (centerX + bandWidth * 0.5) / size.width),
        ],
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.26),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(shimmerRect);

    canvas.drawRect(rect, shimmerPaint);

    // Glossy top sheen (static)
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerButtonPainter old) => old.shimmerX != shimmerX;
}
