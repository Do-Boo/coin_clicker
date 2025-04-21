import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunburstPainter extends CustomPainter {
  final double rotation;
  final Color color;

  SunburstPainter({
    required this.rotation,
    this.color = Colors.amber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    const rayCount = 8;
    final path = Path();
    
    for (var i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i;
      path.moveTo(0, 0);
      path.lineTo(radius * 0.3 * math.cos(angle - 0.1), radius * 0.3 * math.sin(angle - 0.1));
      path.lineTo(radius * 0.8 * math.cos(angle), radius * 0.8 * math.sin(angle));
      path.lineTo(radius * 0.3 * math.cos(angle + 0.1), radius * 0.3 * math.sin(angle + 0.1));
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SunburstPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.color != color;
  }
}

class RotatingSunburst extends StatefulWidget {
  final Widget child;
  final double size;

  const RotatingSunburst({
    super.key,
    required this.child,
    this.size = 200,
  });

  @override
  State<RotatingSunburst> createState() => _RotatingSunburstState();
}

class _RotatingSunburstState extends State<RotatingSunburst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // First sunburst layer (slower)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: SunburstPainter(
                  rotation: _controller.value * 2 * math.pi,
                  color: Colors.amber.withOpacity(0.15),
                ),
              );
            },
          ),
          // Second sunburst layer (faster, different color)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 0.85, widget.size * 0.85),
                painter: SunburstPainter(
                  rotation: -_controller.value * 2 * math.pi,
                  color: Colors.orange.withOpacity(0.1),
                ),
              );
            },
          ),
          // Glow effect
          Container(
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Child widget (coin image)
          widget.child,
        ],
      ),
    );
  }
}
