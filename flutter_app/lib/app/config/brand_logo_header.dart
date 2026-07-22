import 'package:flutter/material.dart';

class BrandLogoHeader extends StatelessWidget {
  final double height;
  final bool showSlogan;

  const BrandLogoHeader({
    super.key,
    this.height = 32,
    this.showSlogan = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navyColor = isDark ? Colors.white : const Color(0xFF0A192F);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Custom Painter for exact ₹ + F Brand Monogram
        CustomPaint(
          size: Size(height, height),
          painter: _RupeeFLogoPainter(isDark: isDark),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FinSwitch',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: height * 0.52,
                fontWeight: FontWeight.w800,
                color: navyColor,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            if (showSlogan) ...[
              const SizedBox(height: 2),
              const Text(
                'SWITCH. SAVE. SMARTER.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                  letterSpacing: 1.2,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RupeeFLogoPainter extends CustomPainter {
  final bool isDark;
  _RupeeFLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final navyPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF0A192F)
      ..style = PaintingStyle.fill;

    final greenPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 512.0;
    final scaleY = size.height / 512.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Top F-shape (Navy / White)
    final fPath = Path();
    fPath.moveTo(130, 110);
    fPath.cubicTo(130, 95, 142, 84, 158, 84);
    fPath.lineTo(360, 84);
    fPath.cubicTo(378, 84, 388, 106, 374, 118);
    fPath.lineTo(340, 148);
    fPath.cubicTo(330, 156, 315, 160, 298, 160);
    fPath.lineTo(210, 160);
    fPath.lineTo(210, 210);
    fPath.lineTo(320, 210);
    fPath.cubicTo(338, 210, 348, 232, 334, 244);
    fPath.lineTo(304, 270);
    fPath.cubicTo(294, 278, 279, 282, 262, 282);
    fPath.lineTo(210, 282);
    fPath.lineTo(210, 380);
    fPath.cubicTo(210, 396, 196, 408, 180, 408);
    fPath.cubicTo(164, 408, 150, 396, 150, 380);
    fPath.lineTo(150, 160);
    fPath.lineTo(130, 160);
    fPath.close();

    canvas.drawPath(fPath, navyPaint);

    // Rupee Growth Leg (Mint Green #10B981)
    final rPath = Path();
    rPath.moveTo(170, 282);
    rPath.cubicTo(170, 252, 200, 240, 240, 240);
    rPath.lineTo(265, 240);
    rPath.cubicTo(240, 290, 210, 350, 180, 405);
    rPath.cubicTo(160, 440, 138, 468, 118, 478);
    rPath.cubicTo(108, 483, 98, 468, 108, 456);
    rPath.cubicTo(128, 432, 152, 388, 175, 340);
    rPath.cubicTo(170, 325, 170, 300, 170, 282);
    rPath.close();

    canvas.drawPath(rPath, greenPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
