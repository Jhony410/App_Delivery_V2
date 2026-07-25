import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bloque con brillo animado. Es el `.dn-sk` del canvas (frame 11).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  /// `null` ocupa todo el ancho disponible.
  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1 - 2 * (1 - _c.value), 0),
            end: Alignment(1 + 2 * _c.value, 0),
            colors: const [
              AppColors.skeletonBase,
              AppColors.skeletonHighlight,
              AppColors.skeletonBase,
            ],
            stops: const [0.25, 0.5, 0.75],
          ),
        ),
      ),
    );
  }
}

/// Lista de tarjetas fantasma mientras cargan Pedidos o Productos.
///
/// Reproduce el frame 11 del canvas: se usa con `LoadStatus.cargando`, que es
/// el estado en que queda la app tras pulsar "Reintentar".
class OrdersSkeleton extends StatelessWidget {
  const OrdersSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (index > 0) ...[
              SkeletonBox(width: 140, height: 26, radius: AppTheme.rPill),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150, height: 18),
                      SizedBox(height: 10),
                      SkeletonBox(width: 190, height: 15, radius: 7),
                    ],
                  ),
                ),
                SkeletonBox(width: 70, height: 26),
              ],
            ),
            if (index == 0) ...[
              const SizedBox(height: 16),
              const SkeletonBox(height: 52, radius: 14),
            ],
            if (index < 2) ...[
              const SizedBox(height: 14),
              const SkeletonBox(height: 56, radius: AppTheme.rButton),
            ],
          ],
        ),
      ),
    );
  }
}
