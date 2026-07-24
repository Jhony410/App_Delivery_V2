import 'package:flutter/material.dart';

/// Motivo andino en zigzag usado como textura sutil sobre las cabeceras verdes.
/// Replica el patrón `M0 26 L10 6 L20 26...` del diseño.
class AndeanPattern extends StatelessWidget {
  const AndeanPattern({super.key, this.opacity = 0.13, this.color = Colors.white});

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(painter: _ZigZagPainter(color)),
        ),
      ),
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  _ZigZagPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const tile = 60.0;
    const tileH = 30.0;
    for (double y = 0; y < size.height + tileH; y += tileH) {
      final path = Path();
      for (double x = 0; x < size.width + tile; x += tile) {
        path.moveTo(x, y + 26);
        path.lineTo(x + 10, y + 6);
        path.lineTo(x + 20, y + 26);
        path.lineTo(x + 30, y + 6);
        path.lineTo(x + 40, y + 26);
        path.lineTo(x + 50, y + 6);
        path.lineTo(x + 60, y + 26);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZigZagPainter oldDelegate) => false;
}
