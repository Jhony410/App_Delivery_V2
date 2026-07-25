import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/store_logo.dart';

/// **Pantalla 02 · Onboarding.** Llega desde Splash, sale a Login.
///
/// El canvas `DelyNegocios.dc.html` no trae un frame de onboarding (su hueco
/// nº 11 lo ocupa el esqueleto de carga), así que esta pantalla se construyó
/// con el mismo lenguaje visual del frame 01: degradado de marca, Poppins
/// grande y un solo botón blanco de avance.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pasos = <({IconData icon, String titulo, String texto})>[
    (
      icon: Icons.notifications_active_outlined,
      titulo: 'Los pedidos llegan solos',
      texto:
          'Cuando un cliente compra, tu celular suena y la alerta aparece a pantalla completa. No se te escapa ninguno.',
    ),
    (
      icon: Icons.delivery_dining_outlined,
      titulo: 'Un chasqui lo recoge',
      texto:
          'Marca el pedido como listo y nosotros buscamos al repartidor. Tú solo cocinas y despachas.',
    ),
    (
      icon: Icons.trending_up_rounded,
      titulo: 'Mira cuánto vendes',
      texto:
          'Ventas del día, pedidos y ganancia total, en números grandes y claros. Sin planillas ni cuadernos.',
    ),
  ];

  bool get _esUltimo => _page == _pasos.length - 1;

  void _siguiente() {
    if (_esUltimo) {
      _irALogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _irALogin() {
    AppStateScope.read(context).marcarOnboardingVisto();
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Igual que en el splash: el degradado tiene que ocupar la pantalla
      // entera, no el ancho de su hijo más ancho.
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      const StoreLogo(size: 44, radius: 14, shadow: false),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'DelyPuno Negocios',
                          style: AppText.display(
                            17,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _irALogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textOnBrandSoft,
                          textStyle: AppText.body(16, weight: FontWeight.w700),
                        ),
                        child: const Text('Saltar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pasos.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final paso = _pasos[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(42),
                              ),
                              child: Icon(
                                paso.icon,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 34),
                            Text(
                              paso.titulo,
                              textAlign: TextAlign.center,
                              style: AppText.display(28, color: Colors.white),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              paso.texto,
                              textAlign: TextAlign.center,
                              style: AppText.body(
                                17,
                                weight: FontWeight.w500,
                                color: AppColors.textOnBrandStrong,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pasos.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: i == _page ? 1 : 0.45,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                  child: OnBrandButton(
                    label: _esUltimo ? 'Comenzar' : 'Siguiente',
                    onPressed: _siguiente,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
