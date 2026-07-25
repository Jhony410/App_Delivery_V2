import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Temporizador circular de la oferta entrante.
/// Frame 27 · "Temporizador 20s" y frame 08.
class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
    this.size = 56,
    this.showUnit = false,
  });

  final int secondsLeft;
  final int totalSeconds;
  final double size;

  /// Muestra "seg" bajo la cifra (variante grande del frame 27).
  final bool showUnit;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : (secondsLeft / totalSeconds).clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _TimerRingPainter(progress: progress, strokeWidth: size * 0.16),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$secondsLeft',
                style: AppText.display(
                  size * 0.32,
                  weight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              if (showUnit)
                Text('seg', style: AppText.body(size * 0.1, weight: FontWeight.w600, color: AppColors.neutral)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final track = Paint()
      ..color = AppColors.borderSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
}
