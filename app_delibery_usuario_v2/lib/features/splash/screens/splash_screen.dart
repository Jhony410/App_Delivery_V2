import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/session.dart';
import '../../../core/widgets/andean_pattern.dart';
import '../../../core/widgets/brand.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 01 · Splash. Ruta inicial. Verifica sesión y decide el destino:
/// onboarding no visto -> /onboarding, sin sesión -> /login, con sesión -> /home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final session = Session.instance;
    if (!await session.onboardingSeen) {
      if (mounted) context.go(AppRoutes.onboarding);
    } else if (!await session.isLoggedIn) {
      if (mounted) context.go(AppRoutes.login);
    } else {
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            const AndeanPattern(opacity: 0.14),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.94, end: 1.06).animate(
                      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
                    ),
                    child: const DelyLogoOnWhite(size: 118, radius: 36),
                  ),
                  const SizedBox(height: 26),
                  Text('DelyPuno', style: AppText.display),
                  const SizedBox(height: 6),
                  Text(
                    'RÁPIDO COMO UN CHASQUI',
                    style: AppText.body.copyWith(
                      color: const Color(0xFFCFEAD9),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v2.0 · Melgar · Puno',
                  style: AppText.small.copyWith(color: const Color(0xFFBFE2CD)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
