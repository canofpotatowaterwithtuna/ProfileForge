import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rainbow-gradient spinning loader for AI search. Conveys dynamic AI processing.
class AiSearchLoader extends StatefulWidget {
  const AiSearchLoader({super.key, this.size = 64});

  final double size;

  @override
  State<AiSearchLoader> createState() => _AiSearchLoaderState();
}

class _AiSearchLoaderState extends State<AiSearchLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  static const _rainbowColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFA94D),
    Color(0xFFFFE066),
    Color(0x69DB7C),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFF9B59B6),
    Color(0xFFFF6B6B),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RainbowSpinnerPainter(
              progress: _rotation.value,
              colors: _rainbowColors,
              strokeWidth: 4,
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                size: widget.size * 0.45,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RainbowSpinnerPainter extends CustomPainter {
  _RainbowSpinnerPainter({
    required this.progress,
    required this.colors,
    this.strokeWidth = 4,
  });

  final double progress;
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      startAngle: progress * 2 * math.pi,
      endAngle: progress * 2 * math.pi + 2 * math.pi,
      colors: colors,
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RainbowSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
