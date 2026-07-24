import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Mapa estilizado (placeholder) fiel al diseño: fondo gris verdoso con calles
/// y manzanas. Sustituye a Google Maps hasta integrar el SDK real.
class MapBackdrop extends StatelessWidget {
  const MapBackdrop({
    super.key,
    this.showRoute = false,
    this.showCenterPin = false,
  });

  final bool showRoute;
  final bool showCenterPin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _MapPainter(showRoute: showRoute)),
        ),
        const Positioned(
          top: 8,
          left: 10,
          child: _GoogleTag(),
        ),
        if (showCenterPin)
          const Align(
            alignment: Alignment(0, -0.05),
            child: _CenterPin(),
          ),
      ],
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Icon(
        Icons.location_on,
        size: 44,
        color: AppColors.primary,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _GoogleTag extends StatelessWidget {
  const _GoogleTag();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppText.label.copyWith(fontSize: 13),
        children: const [
          TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
          TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
          TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
          TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.showRoute});
  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEBEEE9);
    canvas.drawRect(Offset.zero & size, bg);

    final street = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    final w = size.width, h = size.height;
    // Calles horizontales.
    for (final f in [0.26, 0.5, 0.72]) {
      canvas.drawLine(Offset(-20, h * f), Offset(w + 20, h * f - 40), street);
    }
    // Calles verticales.
    for (final f in [0.24, 0.64]) {
      canvas.drawLine(Offset(w * f, -20), Offset(w * f + 50, h + 20), street);
    }

    // Manzanas.
    final block = Paint()..color = const Color(0xFFDEE4DC);
    final park = Paint()..color = const Color(0xFFE4F0DE);
    void rect(double x, double y, double bw, double bh, Paint p) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, bw, bh), const Radius.circular(4)),
        p,
      );
    }

    rect(w * 0.05, h * 0.3, w * 0.14, h * 0.09, block);
    rect(w * 0.42, h * 0.24, w * 0.18, h * 0.08, block);
    rect(w * 0.44, h * 0.55, w * 0.16, h * 0.1, block);
    rect(w * 0.72, h * 0.3, w * 0.2, h * 0.07, block);
    rect(w * 0.74, h * 0.74, w * 0.18, h * 0.08, park);
    rect(w * 0.1, h * 0.76, w * 0.18, h * 0.08, park);

    if (showRoute) {
      final route = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(w * 0.15, h * 0.8)
        ..quadraticBezierTo(w * 0.4, h * 0.7, w * 0.45, h * 0.5)
        ..quadraticBezierTo(w * 0.55, h * 0.3, w * 0.82, h * 0.22);
      canvas.drawPath(path, route);

      // Origen y destino.
      canvas.drawCircle(Offset(w * 0.15, h * 0.8), 8,
          Paint()..color = AppColors.textPrimary);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.showRoute != showRoute;
}
