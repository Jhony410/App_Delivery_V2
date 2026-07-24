import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/session.dart';
import '../../../core/widgets/andean_pattern.dart';
import '../../../core/widgets/brand.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

/// 03 · Login. Autentica y navega a /home. Enlaces a /register y a
/// "¿Olvidaste tu contraseña?".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  Future<void> _login() async {
    await Session.instance.signIn();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 32),
              child: Column(
                children: [
                  AuthTabs(
                    activeIndex: 0,
                    onTap: (i) {
                      if (i == 1) context.go(AppRoutes.register);
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthField(
                    label: 'Correo',
                    controller: _email,
                    hint: 'tucorreo@gmail.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  AuthField(
                    label: 'Contraseña',
                    controller: _password,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    trailing: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotSheet(context),
                      child: Text('¿Olvidaste tu contraseña?', style: AppText.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 22),
                  const AuthDivider(label: 'o continúa con'),
                  const SizedBox(height: 22),
                  GoogleButton(label: 'Continuar con Google', onPressed: _login),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta? ', style: AppText.bodySecondary),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.register),
                        child: Text('Regístrate',
                            style: AppText.link.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotSheet(BuildContext context) {
    final email = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: const BoxDecoration(
            color: AppColors.screenBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8D2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Recuperar contraseña', style: AppText.h3),
              const SizedBox(height: 6),
              Text('Te enviaremos un enlace para restablecerla.',
                  style: AppText.bodySecondary),
              const SizedBox(height: 18),
              AuthField(
                label: 'Correo',
                controller: email,
                hint: 'tucorreo@gmail.com',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enlace de recuperación enviado')),
                  );
                },
                child: const Text('Enviar enlace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          const AndeanPattern(opacity: 0.14),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DelyLogoOnWhite(),
                const SizedBox(height: 14),
                Text('DelyPuno',
                    style: AppText.h1.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
