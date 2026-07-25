import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chasqui_logo.dart';

/// Frame 02 — Login.
///
/// Puerta de entrada: teléfono +51 + contraseña, o Google. Cualquiera de las
/// dos avanza a la verificación por SMS.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.go(AppRoutes.smsVerification);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera de marca.
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                child: Stack(
                  children: [
                    const Positioned.fill(child: AndeanPattern()),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top + 40,
                        bottom: 34,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4D000000),
                                  blurRadius: 30,
                                  offset: Offset(0, 12),
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                            child: const ChasquiLogo(size: 46, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'CHASQUI',
                            style: AppText.display(22, color: Colors.white, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PORTAL DEL REPARTIDOR',
                            style: AppText.body(
                              11,
                              weight: FontWeight.w500,
                              color: AppColors.textOnBrandSoft,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Hola, chasqui 👋', style: AppText.display(20, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Inicia sesión para empezar a repartir', style: AppText.body(13)),
                  const SizedBox(height: 22),

                  Text('Celular', style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  _Field(
                    child: Row(
                      children: [
                        Text('+51', style: AppText.display(15, weight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Container(width: 1.5, height: 24, color: AppColors.border),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            style: AppText.body(15, weight: FontWeight.w500, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: '987 654 321',
                              hintStyle: AppText.body(15, weight: FontWeight.w500, color: AppColors.textHint),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text('Contraseña', style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  _Field(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _password,
                            obscureText: _obscure,
                            style: AppText.body(15, weight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 3),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: '••••••••',
                              hintStyle: AppText.body(15, color: AppColors.textHint, letterSpacing: 3),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showRecoverySheet(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: AppText.body(13, weight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  PrimaryButton(label: 'Iniciar sesión', onPressed: _submit),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('o continúa con', style: AppText.body(12, weight: FontWeight.w500)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 22),

                  SecondaryButton(
                    label: 'Continuar con Google',
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: const Color(0xFF4285F4),
                    height: 54,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('¿Quieres ser repartidor? ', style: AppText.body(13)),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.documentVerification),
                        child: Text(
                          'Regístrate',
                          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.primary),
                        ),
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

  void _showRecoverySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rSheet)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(26, 24, 26, 30 + MediaQuery.paddingOf(sheetContext).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 22),
            Text('Recuperar contraseña', style: AppText.display(20, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Te enviaremos un código al ${_phone.text.isEmpty ? "número registrado" : "+51 ${_phone.text}"} para que la restablezcas.',
              style: AppText.body(14, height: 1.5),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Enviarme el código',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.go(AppRoutes.smsVerification);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de formulario con el borde y la altura del diseño.
class _Field extends StatelessWidget {
  const _Field({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rField),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: child,
    );
  }
}
