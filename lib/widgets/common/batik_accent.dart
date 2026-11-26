import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class BatikAccent extends StatelessWidget {
  const BatikAccent({super.key, this.opacity = 0.12});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _KawungPainter(AppTheme.accent.withValues(alpha: opacity)),
        size: Size.infinite,
      ),
    );
  }
}

class _KawungPainter extends CustomPainter {
  const _KawungPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const spacing = 44.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 28, height: 13),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 13, height: 28),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KawungPainter oldDelegate) =>
      oldDelegate.color != color;
}
