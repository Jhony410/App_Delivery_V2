import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Qué ruta punteada dibuja el mapa bajo los marcadores.
enum MapRoute {
  /// Sin ruta: mapa en reposo (frames 06, 07, 25).
  ninguna,

  /// Frame 09 — del repartidor hacia el restaurante.
  alRestaurante,

  /// Frame 11 — del restaurante hacia el cliente.
  alCliente,

  /// Frame 13 — tres rutas de colores, una por pedido del lote.
  multiple,
}

/// El mapa de Puno estilizado sobre el que vive todo el núcleo operativo.
///
/// No es un mapa real: reproduce el lienzo del diseño (calles blancas, manzanas,
/// el lago) para que la UI se vea idéntica al canvas sin depender todavía de un
/// SDK de mapas. Cuando entre Google Maps, se sustituye solo este widget.
class MapBackdrop extends StatelessWidget {
  const MapBackdrop({
    super.key,
    this.route = MapRoute.ninguna,
    this.showHeatmap = false,
    this.grayscale = false,
    this.dim = 0,
    this.blur = false,
  });

  final MapRoute route;

  /// Frame 07 — manchas de demanda.
  final bool showHeatmap;

  /// Frame 21 — mapa apagado cuando el repartidor está desconectado.
  final bool grayscale;

  /// Velo oscuro sobre el mapa (frames 08, 12, 20).
  final double dim;

  /// Frame 08 — el mapa se desenfoca detrás de la oferta.
  final bool blur;

  @override
  Widget build(BuildContext context) {
    Widget map = CustomPaint(
      size: Size.infinite,
      painter: _MapPainter(route: route, showHeatmap: showHeatmap, grayscale: grayscale),
    );

    if (grayscale) {
      map = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: map,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: grayscale
                  ? const [AppColors.mapOffline, AppColors.mapOffline]
                  : const [AppColors.mapTop, AppColors.mapBottom],
            ),
          ),
        ),
        if (blur)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: map,
          )
        else
          map,
        if (dim > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: (grayscale ? const Color(0xFF3A3F3B) : const Color(0xFF0A1F16))
                  .withValues(alpha: dim),
            ),
          ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.route, required this.showHeatmap, required this.grayscale});

  final MapRoute route;
  final bool showHeatmap;
  final bool grayscale;

  /// El diseño está trazado sobre un lienzo de 390×844; escalamos a la pantalla.
  static const Size _design = Size(390, 844);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;

    canvas.save();
    // `cover`: llena la pantalla sin deformar las calles.
    final scale = math.max(size.width / _design.width, size.height / _design.height);
    canvas.translate(
      (size.width - _design.width * scale) / 2,
      (size.height - _design.height * scale) / 2,
    );
    canvas.scale(scale);
    canvas.clipRect(Rect.fromLTWH(0, 0, _design.width, _design.height));

    _paintWater(canvas);
    _paintBlocks(canvas);
    _paintStreets(canvas);
    if (showHeatmap && !grayscale) _paintHeatmap(canvas);
    _paintRoute(canvas);

    canvas.restore();
  }

  void _paintWater(Canvas canvas) {
    final water = Path()
      ..moveTo(300, 560)
      ..quadraticBezierTo(360, 540, 400, 590)
      ..lineTo(400, 730)
      ..quadraticBezierTo(345, 705, 300, 725)
      ..close();
    canvas.drawPath(water, Paint()..color = AppColors.mapWater.withValues(alpha: 0.5));
  }

  void _paintBlocks(Canvas canvas) {
    final park = Paint()..color = AppColors.mapBlock.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(40, 150, 120, 90), const Radius.circular(12)),
      park,
    );

    final block = Paint()..color = Colors.black.withValues(alpha: 0.05);
    const rects = [
      Rect.fromLTWH(205, 150, 90, 70),
      Rect.fromLTWH(55, 300, 105, 82),
      Rect.fromLTWH(220, 320, 95, 72),
      Rect.fromLTWH(90, 620, 115, 80),
    ];
    for (final r in rects) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)), block);
    }
  }

  void _paintStreets(Canvas canvas) {
    Paint street(double width, double opacity) => Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Avenidas principales.
    canvas.drawLine(const Offset(-10, 260), const Offset(400, 220), street(16, 1));
    canvas.drawLine(const Offset(40, -10), const Offset(120, 854), street(14, 1));
    canvas.drawLine(const Offset(-10, 500), const Offset(400, 470), street(15, 1));
    canvas.drawLine(const Offset(300, -10), const Offset(250, 854), street(13, 1));

    // Calles secundarias.
    canvas.drawLine(const Offset(-10, 380), const Offset(400, 360), street(7, 0.8));
    canvas.drawLine(const Offset(180, -10), const Offset(200, 854), street(7, 0.8));
    canvas.drawLine(const Offset(-10, 680), const Offset(400, 650), street(7, 0.8));
  }

  void _paintHeatmap(Canvas canvas) {
    void blob(Offset center, double radius, Color color, double opacity) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
        ).createShader(rect);
      canvas.drawCircle(center, radius, paint);
    }

    blob(const Offset(150, 300), 120, AppColors.demandVeryHigh, 0.55);
    blob(const Offset(270, 440), 110, AppColors.demandHigh, 0.5);
    blob(const Offset(90, 560), 120, AppColors.demandMedium, 0.5);
    blob(const Offset(300, 680), 115, AppColors.demandLow, 0.45);
  }

  void _paintRoute(Canvas canvas) {
    switch (route) {
      case MapRoute.ninguna:
        return;
      case MapRoute.alRestaurante:
        final path = Path()
          ..moveTo(195, 470)
          ..cubicTo(160, 400, 120, 360, 130, 240)
          ..cubicTo(140, 120, 210, 190, 230, 180);
        _dashed(canvas, path, AppColors.primary, 6);
      case MapRoute.alCliente:
        final path = Path()
          ..moveTo(195, 240)
          ..cubicTo(230, 320, 260, 380, 250, 520)
          ..cubicTo(240, 660, 190, 600, 175, 660);
        _dashed(canvas, path, AppColors.primary, 6);
      case MapRoute.multiple:
        final a = Path()
          ..moveTo(195, 460)
          ..cubicTo(150, 400, 130, 320, 150, 220);
        final b = Path()
          ..moveTo(195, 460)
          ..cubicTo(250, 420, 290, 360, 280, 250);
        final c = Path()
          ..moveTo(195, 460)
          ..cubicTo(200, 540, 170, 600, 130, 660);
        _dashed(canvas, a, AppColors.order1, 5);
        _dashed(canvas, b, AppColors.order2, 5);
        _dashed(canvas, c, AppColors.order3, 5);
    }
  }

  /// Traza la ruta con el punteado de marca (`stroke-dasharray: 2 12`).
  void _dashed(Canvas canvas, Path path, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const dash = 2.0;
    const gap = 12.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.showHeatmap != showHeatmap ||
      oldDelegate.grayscale != grayscale;
}

/// Marcador del repartidor: punto negro con anillo blanco y pulso opcional.
class RiderMarker extends StatefulWidget {
  const RiderMarker({super.key, this.pulsing = false});

  /// Frame 06 — el pulso indica que está buscando pedidos.
  final bool pulsing;

  @override
  State<RiderMarker> createState() => _RiderMarkerState();
}

class _RiderMarkerState extends State<RiderMarker> with SingleTickerProviderStateMixin {
  // Se crea en `initState`, no de forma diferida: si fuera `late` y el
  // marcador nunca pulsara, `dispose` intentaría construirlo con el elemento
  // ya desactivado y reventaría.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.pulsing) _controller.repeat();
  }

  @override
  void didUpdateWidget(RiderMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.pulsing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulsing)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeOut.transform(_controller.value);
                return Container(
                  width: 40 + 90 * t,
                  height: 40 + 90 * t,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18 * (1 - t)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          if (widget.pulsing)
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(color: Color(0x59000000), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chincheta de destino: gota invertida con emoji o ícono dentro.
class MapPin extends StatelessWidget {
  const MapPin({super.key, this.emoji, this.icon, this.color = AppColors.primary, this.size = 38});

  final String? emoji;
  final IconData? icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
            bottomLeft: Radius.circular(3),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 5), spreadRadius: -3),
          ],
        ),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: emoji != null
              ? Text(emoji!, style: TextStyle(fontSize: size * 0.42))
              : Icon(icon ?? Icons.home_rounded, size: size * 0.42, color: Colors.white),
        ),
      ),
    );
  }
}

/// Botón flotante cuadrado del mapa (capas, centrar, Maps).
class MapFab extends StatelessWidget {
  const MapFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.iconColor = AppColors.primary,
    this.size = 46,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;

  /// Texto pequeño bajo el ícono ("Maps", frames 09 y 11).
  final String? label;
  final Color iconColor;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: iconColor),
              if (label != null)
                Text(label!, style: AppText.body(8, weight: FontWeight.w700, color: iconColor)),
            ],
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
        boxShadow: AppTheme.floatingShadow,
      ),
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
    );
  }
}
