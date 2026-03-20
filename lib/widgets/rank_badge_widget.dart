import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/rank_model.dart';

class RankBadgeWidget extends StatelessWidget {
  final DebateRank rank;
  final double size;

  const RankBadgeWidget({super.key, required this.rank, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: RankBadgePainter(rank: rank),
    );
  }
}

class RankBadgePainter extends CustomPainter {
  final DebateRank rank;

  RankBadgePainter({required this.rank});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 120.0;
    canvas.save();
    // Center the coordinate system
    canvas.translate(size.width / 2, size.height / 2);

    switch (rank) {
      case DebateRank.newcomer:
        _paintNewcomer(canvas, s);
        break;
      case DebateRank.challenger:
        _paintChallenger(canvas, s);
        break;
      case DebateRank.debater:
        _paintDebater(canvas, s);
        break;
      case DebateRank.orator:
        _paintOrator(canvas, s);
        break;
      case DebateRank.grandmaster:
        _paintGrandmaster(canvas, s);
        break;
    }

    canvas.restore();
  }

  Path _getHexagonPath(double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      // Pointy top hexagon
      double angle = (math.pi / 3) * i - (math.pi / 2);
      double x = radius * math.cos(angle);
      double y = radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _paintNewcomer(Canvas canvas, double s) {
    // Hexagon Base
    final hexPath = _getHexagonPath(55 * s);
    final fillPaint = Paint()
      ..color = const Color(0xFFD3D1C7)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF888780)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(hexPath, fillPaint);
    canvas.drawPath(hexPath, strokePaint);

    // Sprout
    final sproutPaint = Paint()
      ..color =
          const Color(0xFF5D5C55) // Dark grey-green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;

    // Stem
    canvas.drawLine(Offset(0, 20 * s), Offset(0, -5 * s), sproutPaint);

    final leafFill = Paint()
      ..color = const Color(0xFF5D5C55)
      ..style = PaintingStyle.fill;

    // Left leaf
    final leftLeaf = Path()
      ..moveTo(0, 5 * s)
      ..quadraticBezierTo(-15 * s, 0, -18 * s, -12 * s)
      ..quadraticBezierTo(-5 * s, -10 * s, 0, -2 * s)
      ..close();
    canvas.drawPath(leftLeaf, leafFill);

    // Right leaf
    final rightLeaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(15 * s, -5 * s, 18 * s, -17 * s)
      ..quadraticBezierTo(5 * s, -15 * s, 0, -7 * s)
      ..close();
    canvas.drawPath(rightLeaf, leafFill);

    // Top tip
    final topTip = Path()
      ..moveTo(0, -5 * s)
      ..quadraticBezierTo(-8 * s, -15 * s, 0, -28 * s)
      ..quadraticBezierTo(8 * s, -15 * s, 0, -5 * s)
      ..close();
    canvas.drawPath(topTip, leafFill);
  }

  void _paintChallenger(Canvas canvas, double s) {
    // Hexagon Base
    final hexPath = _getHexagonPath(55 * s);
    final fillPaint = Paint()
      ..color = const Color(0xFFF5C4B3)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF993C1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(hexPath, fillPaint);
    canvas.drawPath(hexPath, strokePaint);

    // Swords
    final swordPaint = Paint()
      ..color = const Color(0xFF993C1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;

    void drawSword() {
      // Blade
      canvas.drawLine(Offset(0, -20 * s), Offset(0, 25 * s), swordPaint);
      // Crossguard
      canvas.drawLine(
        Offset(-8 * s, 15 * s),
        Offset(8 * s, 15 * s),
        swordPaint,
      );
      // Pommel
      canvas.drawCircle(
        Offset(0, 28 * s),
        2.5 * s,
        Paint()..color = const Color(0xFF993C1D),
      );
    }

    canvas.save();
    canvas.rotate(math.pi / 4); // 45 degrees
    drawSword();
    canvas.restore();

    canvas.save();
    canvas.rotate(-math.pi / 4); // -45 degrees
    drawSword();
    canvas.restore();

    // Small battle mark at bottom
    canvas.drawLine(Offset(-8 * s, 30 * s), Offset(8 * s, 30 * s), swordPaint);
  }

  void _paintDebater(Canvas canvas, double s) {
    // 8-point star
    final starPath = Path();
    final int points = 16;
    final double outerR = 0.48 * 120.0 * s;
    final double innerR = 0.22 * 120.0 * s;

    for (int i = 0; i < points; i++) {
      double angle = (math.pi * 2 * i / points) - (math.pi / 2);
      double r = (i % 2 == 0) ? outerR : innerR;
      double x = r * math.cos(angle);
      double y = r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF1D9E75)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF0F6E56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(starPath, fillPaint);
    canvas.drawPath(starPath, strokePaint);

    // Lightning bolt
    final boltPath = Path()
      ..moveTo(5 * s, -22 * s)
      ..lineTo(-12 * s, 2 * s)
      ..lineTo(0 * s, 2 * s)
      ..lineTo(-5 * s, 24 * s)
      ..lineTo(12 * s, -2 * s)
      ..lineTo(0 * s, -2 * s)
      ..close();

    final boltFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    canvas.drawPath(boltPath, boltFill);
  }

  void _paintOrator(Canvas canvas, double s) {
    // Shield
    final shieldPath = Path()
      ..moveTo(-40 * s, -40 * s)
      ..lineTo(40 * s, -40 * s)
      ..lineTo(40 * s, 10 * s)
      ..cubicTo(40 * s, 35 * s, 20 * s, 50 * s, 0, 55 * s)
      ..cubicTo(-20 * s, 50 * s, -40 * s, 35 * s, -40 * s, 10 * s)
      ..close();

    final fillPaint = Paint()
      ..color = const Color(0xFF7F77DD)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF3C3489)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shieldPath, fillPaint);
    canvas.drawPath(shieldPath, strokePaint);

    // Outer flame
    final flamePath = Path()
      ..moveTo(0, -25 * s)
      ..cubicTo(15 * s, -5 * s, 20 * s, 15 * s, 0, 25 * s)
      ..cubicTo(-20 * s, 15 * s, -15 * s, -5 * s, 0, -25 * s)
      ..close();

    final flameFill = Paint()
      ..color =
          const Color(0xFFFFD54F) // Gold/yellow flame
      ..style = PaintingStyle.fill;
    canvas.drawPath(flamePath, flameFill);

    // Inner flame (white at 70% opacity)
    final innerFlamePath = Path()
      ..moveTo(0, -5 * s)
      ..cubicTo(8 * s, 5 * s, 10 * s, 15 * s, 0, 20 * s)
      ..cubicTo(-10 * s, 15 * s, -8 * s, 5 * s, 0, -5 * s)
      ..close();

    final innerFlameFill = Paint()
      ..color =
          const Color(0xB3FFFFFF) // 70% opacity white
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerFlamePath, innerFlameFill);
  }

  void _paintGrandmaster(Canvas canvas, double s) {
    // Outer Circle
    final bgPaint = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFBA7517)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * s;

    canvas.drawCircle(Offset.zero, 50 * s, bgPaint);
    canvas.drawCircle(Offset.zero, 50 * s, strokePaint);

    // Inner Disc
    final innerDiscPaint = Paint()
      ..color = const Color(0xFFFAC775)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 42 * s, innerDiscPaint);

    // 24 Tick Marks
    final tickPaint = Paint()
      ..color = const Color(0xFFBA7517)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 24; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 12); // 15 degrees
      bool isLong = i % 4 == 0;
      double startY = isLong ? 36 * s : 42 * s;
      canvas.drawLine(Offset(0, -startY), Offset(0, -50 * s), tickPaint);
      canvas.restore();
    }

    // Crown
    final crownPath = Path()
      ..moveTo(-30 * s, 15 * s) // Bottom left
      ..lineTo(30 * s, 15 * s) // Bottom right
      ..lineTo(32 * s, -12 * s) // Right peak
      ..lineTo(12 * s, 0) // Inner right valley
      ..lineTo(0, -22 * s) // Center peak
      ..lineTo(-12 * s, 0) // Inner left valley
      ..lineTo(-32 * s, -12 * s) // Left peak
      ..close();

    final crownFill = Paint()
      ..color = const Color(0xFFC77A14)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crownPath, crownFill);

    // Crown Gems
    final redGem = Paint()..color = const Color(0xFFE53935);
    final blueGem = Paint()..color = const Color(0xFF42A5F5);
    final tealGem = Paint()..color = const Color(0xFF26A69A);

    canvas.drawCircle(Offset(-32 * s, -12 * s), 4 * s, redGem); // Left tip
    canvas.drawCircle(Offset(32 * s, -12 * s), 4 * s, tealGem); // Right tip

    // Center blue diamond
    final diamondPath = Path()
      ..moveTo(0, -30 * s)
      ..lineTo(5 * s, -22 * s)
      ..lineTo(0, -14 * s)
      ..lineTo(-5 * s, -22 * s)
      ..close();
    canvas.drawPath(diamondPath, blueGem);

    // 3 gold dots along the crown base
    final dotPaint = Paint()..color = const Color(0xFFFFF59D);
    canvas.drawCircle(Offset(-15 * s, 10 * s), 2.5 * s, dotPaint);
    canvas.drawCircle(Offset(0, 10 * s), 2.5 * s, dotPaint);
    canvas.drawCircle(Offset(15 * s, 10 * s), 2.5 * s, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is RankBadgePainter) {
      return rank != oldDelegate.rank;
    }
    return false;
  }
}
