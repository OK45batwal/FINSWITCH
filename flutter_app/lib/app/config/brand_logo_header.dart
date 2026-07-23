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
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/logo-icon.png', height: height, width: height),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FinSwitch',
              style: TextStyle(
                fontSize: height * 0.52,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            if (showSlogan) ...[
              const SizedBox(height: 2),
              const Text(
                'SWITCH. SAVE. SMARTER.',
                style: TextStyle(
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
