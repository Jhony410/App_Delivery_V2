import 'package:flutter/material.dart';

import '../../features/reportes/data/models/reporte_mensual.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Gráfico de barras del diseño: barras verde claro y la destacada en verde
/// sólido, con el rótulo debajo.
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.puntos,
    this.alto = 170,
    this.radioSuperior = 8,
    this.separacion = 14,
  });

  final List<PuntoSerie> puntos;
  final double alto;
  final double radioSuperior;
  final double separacion;

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) return SizedBox(height: alto);

    final maximo = puntos.map((p) => p.valor).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: alto,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < puntos.length; i++) ...[
            if (i > 0) SizedBox(width: separacion),
            Expanded(
              child: _Barra(
                punto: puntos[i],
                fraccion: maximo <= 0 ? 0 : puntos[i].valor / maximo,
                radioSuperior: radioSuperior,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.punto,
    required this.fraccion,
    required this.radioSuperior,
  });

  final PuntoSerie punto;
  final double fraccion;
  final double radioSuperior;

  @override
  Widget build(BuildContext context) {
    // La barra ocupa el espacio que sobra tras el rótulo, en lugar de un alto
    // calculado: así el gráfico nunca desborda aunque la fuente que acabe
    // cargando sea más alta de lo previsto.
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: fraccion.clamp(0.03, 1.0),
              child: Tooltip(
                message: '${punto.etiqueta}: S/ ${punto.valor.round()}',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: punto.destacado
                        ? AppColors.primary
                        : AppColors.primaryMuted,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radioSuperior),
                      bottom: const Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          punto.etiqueta,
          style:
              (punto.destacado
                      ? AppTextStyles.labelStrong.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      : AppTextStyles.captionMedium)
                  .copyWith(
                    color: punto.destacado
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Gráfico de área del diseño (pedidos por hora): línea verde, relleno en
/// degradado, líneas guía y un punto marcado en el máximo.
class AppAreaChart extends StatelessWidget {
  const AppAreaChart({
    super.key,
    required this.puntos,
    required this.etiquetasEjeX,
    this.alto = 150,
  });

  final List<PuntoSerie> puntos;

  /// Rótulos del eje horizontal, tal como los lista el diseño.
  final List<String> etiquetasEjeX;

  final double alto;

  @override
  Widget build(BuildContext context) {
    if (puntos.length < 2) return SizedBox(height: alto);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: alto,
          child: CustomPaint(painter: _PintorArea(puntos: puntos)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final etiqueta in etiquetasEjeX)
              Flexible(
                child: Text(
                  etiqueta,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PintorArea extends CustomPainter {
  const _PintorArea({required this.puntos});

  final List<PuntoSerie> puntos;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final maximo = puntos.map((p) => p.valor).reduce((a, b) => a > b ? a : b);
    final divisor = maximo <= 0 ? 1 : maximo;
    final paso = size.width / (puntos.length - 1);

    final coordenadas = <Offset>[
      for (var i = 0; i < puntos.length; i++)
        Offset(
          paso * i,
          size.height - (puntos[i].valor / divisor) * (size.height * 0.88),
        ),
    ];

    // Líneas guía horizontales.
    final guia = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final fraccion in const [0.27, 0.5, 0.73]) {
      final y = size.height * fraccion;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guia);
    }

    final trazo = Path()..moveTo(coordenadas.first.dx, coordenadas.first.dy);
    for (final punto in coordenadas.skip(1)) {
      trazo.lineTo(punto.dx, punto.dy);
    }

    final relleno = Path.from(trazo)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      relleno,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x470E7A4F), Color(0x000E7A4F)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      trazo,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final indiceMaximo = puntos.indexWhere((p) => p.destacado);
    if (indiceMaximo != -1) {
      final centro = coordenadas[indiceMaximo];
      canvas
        ..drawCircle(centro, 5.5, Paint()..color = AppColors.surface)
        ..drawCircle(
          centro,
          5.5,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
    }
  }

  @override
  bool shouldRepaint(_PintorArea oldDelegate) => oldDelegate.puntos != puntos;
}

/// Barra horizontal de participación por categoría (frame 11) y de zonas de
/// conexión (frame 05).
class AppProgressRow extends StatelessWidget {
  const AppProgressRow({
    super.key,
    required this.etiqueta,
    required this.porcentaje,
    this.color = AppColors.primary,
    this.fondo = AppColors.border,
  });

  final String etiqueta;
  final int porcentaje;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  etiqueta,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$porcentaje%', style: AppTextStyles.amount),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: (porcentaje / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: fondo,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
