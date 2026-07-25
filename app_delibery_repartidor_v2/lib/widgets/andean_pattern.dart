import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// El motivo de marca: líneas diagonales punteadas que evocan la ruta del
/// chasqui. En el diseño es un `background-image` SVG de 44×44 al 13% de
/// opacidad, repetido sobre los degradados verdes.
class AndeanPattern extends StatelessWidget {
  const AndeanPattern({super.key, this.opacity = 0.13, this.color = Colors.white});

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(size: Size.infinite, painter: _AndeanPatternPainter(color)),
      ),
    );
  }
}

class _AndeanPatternPainter extends CustomPainter {
  const _AndeanPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const tile = 44.0;
    const dash = 2.0;
    const gap = 7.0;

    // Diagonales de abajo-izquierda a arriba-derecha, una por celda de 44px.
    for (double offset = -size.height; offset < size.width + tile; offset += tile) {
      final start = Offset(offset, size.height);
      final end = Offset(offset + size.height, 0);
      _drawDashedLine(canvas, start, end, paint, dash, gap);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint, double dash, double gap) {
    final delta = b - a;
    final length = delta.distance;
    if (length <= 0) return;
    final step = (dash + gap) / length;
    final unit = delta / length;

    for (double t = 0; t < 1; t += step) {
      final start = a + unit * (t * length);
      final endDistance = (t * length + dash).clamp(0.0, length);
      canvas.drawLine(start, a + unit * endDistance, paint);
    }
  }

  @override
  bool shouldRepaint(_AndeanPatternPainter oldDelegate) => oldDelegate.color != color;
}

/// Cabecera verde con degradado y motivo de ruta.
///
/// Se repite en login, alta de documentos, ganancias, perfil, centro de ayuda
/// y drawer. Recibe el contenido ya maquetado.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 16, 22, 26),
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(26)),
    this.safeTop = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  /// Añade el inset superior del sistema para no chocar con la barra de estado.
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    final top = safeTop ? MediaQuery.paddingOf(context).top : 0.0;
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: AndeanPattern()),
            Padding(
              padding: padding.copyWith(top: padding.top + top),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra superior de las pantallas de cuenta: botón de volver + título.
/// Frames 17 y 18.
class BackTitleBar extends StatelessWidget {
  const BackTitleBar({super.key, required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Icon(Icons.chevron_left_rounded, size: 24, color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.display(22),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Tarjeta blanca estándar del sistema (borde suave + sombra ligera).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = AppColors.borderSoft,
    this.radius = AppTheme.rCard,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
