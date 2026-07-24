import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/session.dart';
import '../../../core/widgets/andean_pattern.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 02 · Onboarding. Se muestra solo la primera vez (guarda flag local).
/// Botón "Empezar" -> /login.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      icon: Icons.storefront_rounded,
      title: 'Todo Puno en una app',
      body: 'Comida, farmacia, mercado y licorería. Pide de tus comercios '
          'favoritos en minutos.',
    ),
    _Slide(
      icon: Icons.pedal_bike_rounded,
      title: 'Rápido como un chasqui',
      body: 'Repartidores locales que conocen la ciudad. Sigue tu pedido en '
          'vivo hasta tu puerta.',
    ),
    _Slide(
      icon: Icons.favorite_rounded,
      title: 'Hecho para tu pueblo',
      body: 'Descubre lugares, actividades y números útiles de tu zona con '
          'Mi Pueblo.',
    ),
  ];

  Future<void> _finish() async {
    await Session.instance.completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Saltar', style: AppText.link),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 190,
                              height: 190,
                              decoration: const BoxDecoration(
                                gradient: AppColors.headerGradient,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              // AndeanPattern es un Positioned: necesita un Stack.
                              child: const Stack(
                                children: [AndeanPattern(opacity: 0.18)],
                              ),
                            ),
                            Icon(s.icon, size: 84, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(s.title,
                            style: AppText.h2, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(s.body,
                            style: AppText.bodySecondary,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : const Color(0xFFD5E7DC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(isLast ? 'Empezar' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
