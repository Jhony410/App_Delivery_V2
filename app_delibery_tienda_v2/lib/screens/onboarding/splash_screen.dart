import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/store_logo.dart';

/// **Pantalla 01 · Splash.** Ruta inicial de la app (`/`).
///
/// Tras la animación decide a dónde ir según el estado de sesión:
/// - sesión iniciada → Inicio (shell con bottom nav)
/// - onboarding ya visto → Login
/// - primera vez → Onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _continuar);
  }

  void _continuar() {
    if (!mounted) return;
    final state = AppStateScope.read(context);

    final destino = state.sesionIniciada
        ? AppRoutes.home
        : state.onboardingVisto
        ? AppRoutes.login
        : AppRoutes.onboarding;

    context.go(destino);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // `SizedBox.expand` es imprescindible: un `DecoratedBox` se ajusta al
      // ancho de su hijo, y la `Column` solo mide lo que ocupa su texto más
      // largo. Sin esto el degradado pinta una franja y deja el resto blanco.
      body: SizedBox.expand(
        key: const Key('splash-background'),
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const _PulsingLogo(),
                const SizedBox(height: 26),
                Text(
                  'DelyPuno',
                  style: AppText.display(
                    34,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'para Negocios',
                  style: AppText.body(
                    15,
                    weight: FontWeight.w600,
                    color: AppColors.textOnBrandSoft,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'TU LOCAL, MÁS PEDIDOS',
                  style: AppText.body(
                    12,
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
                const SizedBox(height: 30),
                Text(
                  'Comerciante · v1.0 · Puno',
                  style: AppText.body(
                    12,
                    weight: FontWeight.w500,
                    color: AppColors.textOnBrandSoft,
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo con los dos anillos que se expanden, como el `dn-ring` del canvas.
class _PulsingLogo extends StatefulWidget {
  const _PulsingLogo();

  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            _anillo((_c.value) % 1),
            _anillo((_c.value + 0.5) % 1),
            child!,
          ],
        ),
        child: const StoreLogo(size: 118, radius: 38),
      ),
    );
  }

  Widget _anillo(double t) => Transform.scale(
    scale: 0.6 + t * 1.3,
    child: Opacity(
      opacity: (0.5 * (1 - t)).clamp(0, 1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  );
}
