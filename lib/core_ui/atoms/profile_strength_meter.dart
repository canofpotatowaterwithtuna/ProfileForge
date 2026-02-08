import 'package:flutter/material.dart';

/// L6: Custom Painter that draws a "Profile Strength" meter (0–1) as a circular gauge.
class ProfileStrengthMeter extends StatelessWidget {
  const ProfileStrengthMeter({
    super.key,
    required this.strength,
    this.size = 80,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double strength;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fg = foregroundColor ?? theme.colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProfileStrengthPainter(
          strength: strength,
          strokeWidth: strokeWidth,
          backgroundColor: bg,
          foregroundColor: fg,
        ),
      ),
    );
  }
}

class _ProfileStrengthPainter extends CustomPainter {
  _ProfileStrengthPainter({
    required this.strength,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double strength;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * strength;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileStrengthPainter oldDelegate) {
    return oldDelegate.strength != strength ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}
