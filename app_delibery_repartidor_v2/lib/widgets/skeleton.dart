import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bloque con brillo animado (`@keyframes chq-shim` del diseño).
/// Ladrillo base del frame 24.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 7,
    this.shape = BoxShape.rectangle,
  });

  /// Círculo para avatares del esqueleto.
  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.radius)
                : null,
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 + 2 * t, 0),
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// Pantalla de carga completa del núcleo operativo. Frame 24.
///
/// Reproduce la silueta del mapa: cabecera del repartidor, marcador central y
/// hoja inferior, todo en shimmer.
class OperationsSkeleton extends StatelessWidget {
  const OperationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AppColors.skeletonBase,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Skeleton(height: double.infinity, radius: 0),

          // Cabecera del repartidor.
          Positioned(
            top: topInset + 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
              ),
              child: Row(
                children: [
                  const Skeleton.circle(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          child: const Skeleton(height: 13, radius: 6),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.4,
                          child: const Skeleton(height: 11, radius: 6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Skeleton(width: 56, height: 32, radius: 20),
                ],
              ),
            ),
          ),

          // Marcador del repartidor.
          const Align(
            alignment: Alignment(0, -0.1),
            child: Skeleton.circle(size: 56),
          ),

          // Hoja inferior.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 30 + bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rSheet)),
                boxShadow: AppTheme.sheetShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.handle,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: const Skeleton(height: 18, radius: 8),
                  ),
                  const SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.45,
                    child: const Skeleton(height: 13, radius: 7),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Skeleton(height: 64, radius: 14)),
                      SizedBox(width: 10),
                      Expanded(child: Skeleton(height: 64, radius: 14)),
                      SizedBox(width: 10),
                      Expanded(child: Skeleton(height: 64, radius: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
