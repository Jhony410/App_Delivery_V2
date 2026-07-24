import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/session.dart';
import '../../../core/widgets/brand.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

/// 04 · Registro. Crea la cuenta y navega a /home. Botón volver / toggle -> /login.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = true;

  Future<void> _register() async {
    await Session.instance.signIn();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const DelyLogo(size: 40, radius: 12, iconScale: 0.6),
                  const SizedBox(width: 10),
                  Text('Crea tu cuenta', style: AppText.h3),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AuthTabs(
                activeIndex: 1,
                onTap: (i) {
                  if (i == 0) context.go(AppRoutes.login);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthField(
                      label: 'Nombre completo',
                      controller: _name,
                      hint: 'Ana Condori',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: 'Número de teléfono',
                      controller: _phone,
                      hint: '987 654 321',
                      prefixText: '🇵🇪 +51  ',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: 'Correo electrónico',
                      controller: _email,
                      hint: 'ana.condori@gmail.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: 'Contraseña',
                      controller: _password,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: (v) => setState(() => _accepted = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                style: AppText.caption,
                                children: [
                                  const TextSpan(text: 'Acepto los '),
                                  TextSpan(
                                    text: 'Términos y condiciones',
                                    style: AppText.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                      text: ' y la Política de privacidad de DelyPuno.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _accepted ? _register : null,
                      child: const Text('Crear cuenta'),
                    ),
                    const SizedBox(height: 20),
                    const AuthDivider(label: 'o regístrate con'),
                    const SizedBox(height: 20),
                    GoogleButton(
                        label: 'Continuar con Google', onPressed: _register),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿Ya tienes cuenta? ', style: AppText.bodySecondary),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text('Inicia sesión',
                                style: AppText.link
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
