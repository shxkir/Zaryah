import 'package:flutter/material.dart';
import '../theme/neon_palette.dart';

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child, this.addPadding = false});

  final Widget child;
  final bool addPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050910), NeonColors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120,
            right: -40,
            child: _glowCircle(220, NeonColors.cyan.withOpacity(0.18)),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _glowCircle(280, NeonColors.purple.withOpacity(0.18)),
          ),
          if (addPadding)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            )
          else
            child,
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeonColors.cyan.withOpacity(0.05)
      ..strokeWidth = 1;

    const double spacing = 32;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final dotPaint = Paint()
      ..color = NeonColors.blue.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
