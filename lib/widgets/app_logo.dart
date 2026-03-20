import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogoWidget({
    super.key,
    this.size = 72.0,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: AppLogoPainter(showBackground: showBackground),
    );
  }
}

class AppLogoPainter extends CustomPainter {
  final bool showBackground;

  AppLogoPainter({this.showBackground = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate system matches viewBox="0 0 160 160"
    final double scale = size.width / 160.0;
    canvas.scale(scale, scale);

    if (showBackground) {
      final RRect bgRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 160, 160),
        const Radius.circular(36),
      );
      canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF0e0e18));
    }

    // ── LEFT SIDE ──
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 80, 160));

    // Base circle
    canvas.drawCircle(
      const Offset(80, 80),
      50,
      Paint()..color = const Color(0xFF3C3489),
    );

    // Eye elements
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(58, 70), width: 18, height: 22),
      Paint()..color = const Color(0xFFCECBF6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(58, 69), width: 10, height: 12),
      Paint()..color = const Color(0xFF26215C),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(59, 68), width: 4, height: 5),
      Paint()..color = const Color(0xFFEEEDFE),
    );

    // Smile
    final pathL = Path()
      ..moveTo(46, 94)
      ..quadraticBezierTo(58, 102, 70, 94);
    canvas.drawPath(
      pathL,
      Paint()
        ..color = const Color(0xFFCECBF6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Top line (relaxed eyebrow)
    canvas.drawLine(
      const Offset(46, 56),
      const Offset(70, 60),
      Paint()
        ..color = const Color(0xFFAFA9EC)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();

    // ── RIGHT SIDE ──
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(80, 0, 80, 160));

    // Base circle
    canvas.drawCircle(
      const Offset(80, 80),
      50,
      Paint()..color = const Color(0xFF0F6E56),
    );

    // Eye elements
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(102, 70), width: 18, height: 22),
      Paint()..color = const Color(0xFF9FE1CB),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(102, 69), width: 10, height: 12),
      Paint()..color = const Color(0xFF04342C),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(103, 68), width: 4, height: 5),
      Paint()..color = const Color(0xFFE1F5EE),
    );

    // Frown
    final pathR = Path()
      ..moveTo(90, 98)
      ..quadraticBezierTo(102, 90, 114, 98);
    canvas.drawPath(
      pathR,
      Paint()
        ..color = const Color(0xFF9FE1CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Top line (angry eyebrow)
    canvas.drawLine(
      const Offset(90, 62),
      const Offset(114, 56),
      Paint()
        ..color = const Color(0xFF5DCAA5)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();

    // ── CENTER DIVIDER ──
    canvas.drawRect(
      const Rect.fromLTWH(77, 22, 6, 116),
      Paint()..color = const Color(0xFF0a0a0f),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
