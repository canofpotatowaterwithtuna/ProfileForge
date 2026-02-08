import 'dart:math' as math;

import 'package:flutter/material.dart';

/// TextField with a pastel rainbow gradient border/fill that animates (spins).
/// Conveys AI/dynamic input styling.
class PastelRainbowInput extends StatefulWidget {
  const PastelRainbowInput({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;

  static const _pastelColors = [
    Color(0xFFFFB3BA), // pink
    Color(0xFFFFDFBA), // peach
    Color(0xFFFFFBA3), // pastel yellow
    Color(0xFFBAFFC9), // mint
    Color(0xFFBAE1FF), // pastel blue
    Color(0xFFE0BBE4), // lavender
    Color(0xFFFFB3BA), // back to pink
  ];

  @override
  State<PastelRainbowInput> createState() => _PastelRainbowInputState();
}

class _PastelRainbowInputState extends State<PastelRainbowInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, _) {
        return SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PastelRainbowBorderPainter(
                    progress: _rotation.value,
                    colors: PastelRainbowInput._pastelColors,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: widget.controller,
                  onSubmitted: widget.onSubmitted,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: widget.prefixIcon,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PastelRainbowBorderPainter extends CustomPainter {
  _PastelRainbowBorderPainter({
    required this.progress,
    required this.colors,
  });

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const borderWidth = 3.0;
    const outerRadius = 9.0;
    const innerRadius = 6.0;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(outerRadius),
    );
    final innerRect = rect.deflate(borderWidth);
    final innerRrect = RRect.fromRectAndRadius(
      innerRect,
      const Radius.circular(innerRadius),
    );

    // 6π = 3 full rotations per cycle — fast speed, loops seamlessly (multiple of 2π)
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: colors,
      transform: GradientRotation(progress * 6 * math.pi),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final borderPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(rrect),
      Path()..addRRect(innerRrect),
    );
    canvas.drawPath(borderPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PastelRainbowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
