import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// [CustomPainter] that draws an animated arc representing a logic score.
///
/// [progress] ranges from 0.0 to 1.0.
/// [color]    is the filled arc's end color (interpolated from [AppColors.primary]).
class ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const ScoreArcPainter({required this.progress, required this.color});

  static const double _startAngle = -math.pi * 0.75;
  static const double _sweepFull = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepFull,
      false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Gradient progress arc
    final gradient = SweepGradient(
      startAngle: _startAngle,
      endAngle: _startAngle + _sweepFull,
      colors: [AppColors.primary, color],
      stops: const [0.0, 1.0],
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepFull * progress,
      false,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ScoreArcPainter old) =>
      old.progress != progress || old.color != color;
}
