import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tipos de marcador del mapa, con los colores que fija la leyenda.
enum TipoMarcador {
  repartidor(AppColors.markerCourier, 'Repartidor'),
  negocio(AppColors.markerBusiness, 'Negocio'),
  cliente(AppColors.markerCustomer, 'Cliente'),
  problema(AppColors.markerProblem, 'Pedido con problema');

  const TipoMarcador(this.color, this.etiqueta);

  final Color color;
  final String etiqueta;
}

/// Un marcador colocado sobre el lienzo del mapa, en coordenadas relativas.
class MarcadorMapa {
  const MarcadorMapa({
    required this.x,
    required this.y,
    required this.tipo,
    this.pulsante = false,
    this.etiqueta,
    this.onTap,
  });

  /// Posición relativa dentro del mapa, de 0 a 1.
  final double x;
  final double y;

  final TipoMarcador tipo;

  /// Dibuja el anillo animado que el diseño usa sobre el repartidor activo.
  final bool pulsante;

  final String? etiqueta;
  final VoidCallback? onTap;
}

/// Lienzo del mapa del diseño.
///
/// El diseño dibuja el mapa con SVG: calles blancas sobre un degradado verde,
/// una ruta punteada animada y marcadores de colores. Se reproduce con
/// `CustomPaint`, sin `Image.network`, así que no hay imágenes remotas que
/// puedan fallar.
class AppMapaCanvas extends StatelessWidget {
  const AppMapaCanvas({
    super.key,
    required this.alto,
    this.marcadores = const [],
    this.mostrarRuta = true,
    this.mostrarLeyenda = false,
    this.leyenda = const [
      TipoMarcador.repartidor,
      TipoMarcador.negocio,
      TipoMarcador.cliente,
    ],
    this.expandido = false,
  });

  final double alto;
  final List<MarcadorMapa> marcadores;
  final bool mostrarRuta;
  final bool mostrarLeyenda;
  final List<TipoMarcador> leyenda;

  /// Ocupa todo el alto disponible en lugar de [alto] (frame 03).
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final mapa = ClipRRect(
      borderRadius: AppRadius.panel,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mapGradientStart, AppColors.mapGradientEnd],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ancho = constraints.maxWidth;
            final altura = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : alto;
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _PintorCalles(mostrarRuta: mostrarRuta)),
                for (final marcador in marcadores)
                  Positioned(
                    left: (marcador.x * ancho) - 12,
                    top: (marcador.y * altura) - 12,
                    child: _Marcador(marcador: marcador),
                  ),
                if (mostrarLeyenda)
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: _Leyenda(tipos: leyenda),
                  ),
              ],
            );
          },
        ),
      ),
    );

    return expandido ? mapa : SizedBox(height: alto, child: mapa);
  }
}

class _PintorCalles extends CustomPainter {
  const _PintorCalles({required this.mostrarRuta});

  final bool mostrarRuta;

  @override
  void paint(Canvas canvas, Size size) {
    final calle = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Avenidas horizontales y verticales, en proporciones del diseño.
    void trazar(Offset a, Offset b, double grosor) {
      calle.strokeWidth = grosor;
      canvas.drawLine(a, b, calle);
    }

    trazar(
      Offset(-10, size.height * 0.33),
      Offset(size.width + 10, size.height * 0.24),
      11,
    );
    trazar(
      Offset(-10, size.height * 0.71),
      Offset(size.width + 10, size.height * 0.62),
      10,
    );
    trazar(
      Offset(size.width * 0.24, -10),
      Offset(size.width * 0.32, size.height + 10),
      10,
    );
    trazar(
      Offset(size.width * 0.68, -10),
      Offset(size.width * 0.6, size.height + 10),
      9,
    );

    if (!mostrarRuta) return;

    // Ruta punteada del repartidor hacia el negocio.
    final ruta = Path()
      ..moveTo(size.width * 0.32, size.height * 0.76)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.62,
        size.width * 0.5,
        size.height * 0.57,
        size.width * 0.6,
        size.height * 0.33,
      );

    final trazoRuta = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final metrica in ruta.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metrica.length) {
        final segmento = metrica.extractPath(distancia, distancia + 2);
        canvas.drawPath(segmento, trazoRuta);
        distancia += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_PintorCalles oldDelegate) =>
      oldDelegate.mostrarRuta != mostrarRuta;
}

class _Marcador extends StatefulWidget {
  const _Marcador({required this.marcador});

  final MarcadorMapa marcador;

  @override
  State<_Marcador> createState() => _MarcadorState();
}

class _MarcadorState extends State<_Marcador>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.marcador.pulsante) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marcador = widget.marcador;
    final punto = Container(
      width: marcador.pulsante ? 16 : 14,
      height: marcador.pulsante ? 16 : 14,
      decoration: BoxDecoration(
        color: marcador.tipo.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: AppColors.markerShadow,
      ),
    );

    final contenido = SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (_controller != null)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) {
                final t = _controller!.value;
                return Opacity(
                  opacity: (0.5 * (1 - t)).clamp(0.0, 1.0),
                  child: Container(
                    width: 24 * (0.6 + t * 1.3),
                    height: 24 * (0.6 + t * 1.3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: marcador.tipo.color, width: 2),
                    ),
                  ),
                );
              },
            ),
          punto,
        ],
      ),
    );

    final conTooltip = marcador.etiqueta == null
        ? contenido
        : Tooltip(message: marcador.etiqueta!, child: contenido);

    if (marcador.onTap == null) return conTooltip;
    return GestureDetector(onTap: marcador.onTap, child: conTooltip);
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.tipos});

  final List<TipoMarcador> tipos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.chip,
        boxShadow: AppColors.floatingShadow,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: 4,
        children: [
          for (final tipo in tipos)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tipo.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(tipo.etiqueta, style: AppTextStyles.labelStrong),
              ],
            ),
        ],
      ),
    );
  }
}
