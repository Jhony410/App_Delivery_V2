import 'package:flutter/material.dart';

/// El chasqui corriendo: la marca de la app.
///
/// Reproduce en `CustomPainter` el SVG de 96×96 del canvas de diseño
/// (líneas de velocidad, penacho, cabeza, mochila, brazo y piernas).
class ChasquiLogo extends StatelessWidget {
  const ChasquiLogo({super.key, this.size = 48, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ChasquiPainter(color)),
    );
  }
}

class _ChasquiPainter extends CustomPainter {
  const _ChasquiPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 96;
    canvas.save();
    canvas.scale(s);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    Paint stroke(double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Líneas de velocidad a la izquierda.
    canvas.drawLine(const Offset(6, 38), const Offset(21, 38), stroke(5));
    canvas.drawLine(const Offset(3, 52), const Offset(23, 52), stroke(5));
    canvas.drawLine(const Offset(9, 66), const Offset(22, 66), stroke(5));

    // Penacho del casco.
    final plume = Path()
      ..moveTo(66, 5)
      ..relativeCubicTo(7, 1, 10, 7, 6, 13)
      ..relativeCubicTo(-4, 0, -8, -3, -9, -8)
      ..close();
    canvas.drawPath(plume, fill);

    // Cabeza y oreja.
    canvas.drawCircle(const Offset(61, 25), 10, fill);
    canvas.drawCircle(const Offset(54, 33), 3.2, fill);

    // Mochila (la encomienda) y su asa.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 30, 21, 21),
        const Radius.circular(5),
      ),
      fill,
    );
    final handle = Path()
      ..moveTo(42, 30)
      ..lineTo(42, 27)
      ..arcToPoint(const Offset(50, 27), radius: const Radius.circular(4))
      ..lineTo(50, 30);
    canvas.drawPath(handle, stroke(3));

    // Torso inclinado hacia adelante.
    final torso = Path()
      ..moveTo(57, 34)
      ..relativeCubicTo(5, 6, 4, 13, -1, 18)
      ..relativeLineTo(-7, -3)
      ..relativeCubicTo(3, -5, 4, -10, 2, -15)
      ..close();
    canvas.drawPath(torso, fill);

    // Brazo extendido.
    canvas.drawLine(const Offset(59, 41), const Offset(72, 44), stroke(8));

    // Piernas en zancada.
    canvas.drawLine(const Offset(52, 55), const Offset(63, 74), stroke(9));
    canvas.drawLine(const Offset(49, 57), const Offset(42, 75), stroke(9));

    // Pies.
    canvas.drawLine(const Offset(61, 74), const Offset(74, 74), stroke(5));
    canvas.drawLine(const Offset(35, 75), const Offset(48, 75), stroke(5));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChasquiPainter oldDelegate) => oldDelegate.color != color;
}

/// El chasqui con la animación de carrera del splash y del estado vacío
/// (`@keyframes chq-run` del diseño).
class RunningChasqui extends StatefulWidget {
  const RunningChasqui({
    super.key,
    this.size = 68,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 900),
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<RunningChasqui> createState() => _RunningChasquiState();
}

class _RunningChasquiState extends State<RunningChasqui> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(-5 + 10 * t, 2 - 6 * t),
          child: Transform.rotate(angle: (-3 + 6 * t) * 3.1415926 / 180, child: child),
        );
      },
      child: ChasquiLogo(size: widget.size, color: widget.color),
    );
  }
}
