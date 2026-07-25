import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/chasqui_logo.dart';

/// Frame 01 — Splash.
///
/// Es la ruta inicial. Tras la animación de marca avanza sola al Login: ese
/// es el punto de entrada de todo el flujo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _rings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AndeanPattern(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox.square(
                    dimension: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _Ring(controller: _rings, delay: 0),
                        _Ring(controller: _rings, delay: 0.5),
                        Container(
                          width: 118,
                          height: 118,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x59000000),
                                blurRadius: 40,
                                offset: Offset(0, 16),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: const RunningChasqui(size: 68, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'CHASQUI',
                    style: AppText.display(36, color: Colors.white, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'EL MENSAJERO DE DELYPUNO',
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      13,
                      weight: FontWeight.w500,
                      color: AppColors.textOnBrandSoft,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                      backgroundColor: Color(0x55FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Repartidor · v1.0 · Puno',
                    style: AppText.body(11, weight: FontWeight.w500, color: const Color(0xFFBFE2CD)),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Anillo que se expande y se desvanece (`@keyframes chq-ring`).
class _Ring extends StatelessWidget {
  const _Ring({required this.controller, required this.delay});

  final AnimationController controller;

  /// Desfase entre 0 y 1 para escalonar los dos anillos.
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + delay) % 1.0;
        final eased = Curves.easeOut.transform(t);
        return Transform.scale(
          scale: 0.6 + 1.2 * eased,
          child: Opacity(
            opacity: (0.5 * (1 - eased)).clamp(0.0, 1.0),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
