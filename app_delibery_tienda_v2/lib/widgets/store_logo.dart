import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logotipo de DelyPuno Negocios: el toldo de tienda del canvas.
///
/// Se dibuja a mano para que no dependa de ningún asset y escale sin pérdida
/// en splash, login, inicio y perfil.
class StoreLogo extends StatelessWidget {
  const StoreLogo({
    super.key,
    this.size = 64,
    this.color = AppColors.primary,
    this.background = Colors.white,
    this.radius,
    this.shadow = true,
  });

  final double size;

  /// Color del toldo.
  final Color color;

  /// Fondo de la placa redondeada. `Colors.transparent` dibuja solo el ícono.
  final Color background;
  final double? radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius ?? size * 0.32),
        boxShadow: shadow && background != Colors.transparent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: size * 0.4,
                  offset: Offset(0, size * 0.16),
                  spreadRadius: -size * 0.1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(size * 0.58),
          painter: _StorefrontPainter(color),
        ),
      ),
    );
  }
}

/// Réplica del `<svg viewBox="0 0 48 48">` del canvas: toldo relleno, cuerpo
/// del local en trazo y puerta al centro.
class _StorefrontPainter extends CustomPainter {
  const _StorefrontPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 48;
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Toldo: M8 18 l2-8 h28 l2 8, con las cuatro ondas de la orilla.
    final awning = Path()
      ..moveTo(8 * k, 18 * k)
      ..lineTo(10 * k, 10 * k)
      ..lineTo(38 * k, 10 * k)
      ..lineTo(40 * k, 18 * k);
    for (var i = 0; i < 4; i++) {
      final x = 40 * k - i * 8 * k;
      awning.arcToPoint(
        Offset(x - 8 * k, 18 * k),
        radius: Radius.circular(4 * k),
        clockwise: true,
      );
    }
    canvas.drawPath(awning..close(), fill);

    // Cuerpo del local: M11 20 v18 h26 V20.
    canvas.drawPath(
      Path()
        ..moveTo(11 * k, 20 * k)
        ..lineTo(11 * k, 38 * k)
        ..lineTo(37 * k, 38 * k)
        ..lineTo(37 * k, 20 * k),
      stroke,
    );

    // Puerta: M20 38 v-9 h8 v9.
    canvas.drawPath(
      Path()
        ..moveTo(20 * k, 38 * k)
        ..lineTo(20 * k, 29 * k)
        ..lineTo(28 * k, 29 * k)
        ..lineTo(28 * k, 38 * k),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_StorefrontPainter old) => old.color != color;
}
