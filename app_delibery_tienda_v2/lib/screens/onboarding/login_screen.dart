import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/store_logo.dart';

/// **Pantalla 03 · Login** ("Ingresa a tu local").
///
/// Salidas:
/// - "Ingresar" → Inicio (shell con bottom nav)
/// - "Regístralo" → Verificación del negocio
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _celular = TextEditingController();
  final _password = TextEditingController();
  bool _verPassword = false;

  /// El canvas exige campos grandes y un botón que solo se activa con datos.
  bool get _puedeIngresar =>
      _celular.text.trim().length >= 9 && _password.text.length >= 4;

  @override
  void initState() {
    super.initState();
    _celular.addListener(_refrescar);
    _password.addListener(_refrescar);
  }

  void _refrescar() => setState(() {});

  void _ingresar() {
    AppStateScope.read(context).iniciarSesion();
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _celular.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cabecera(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingresa a tu local',
                    style: AppText.display(22, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Usa el celular de tu negocio',
                    style: AppText.body(16, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  Text('Celular', style: AppText.fieldLabel()),
                  const SizedBox(height: 8),
                  _campoCelular(),
                  const SizedBox(height: 18),
                  Text('Contraseña', style: AppText.fieldLabel()),
                  const SizedBox(height: 8),
                  _campoPassword(),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Ingresar',
                    onPressed: _puedeIngresar ? _ingresar : null,
                  ),
                  const SizedBox(height: 22),
                  _enlaceRegistro(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecera(BuildContext context) {
    return Container(
      height: 226,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const StoreLogo(size: 80, radius: 26),
            const SizedBox(height: 14),
            Text(
              'DelyPuno Negocios',
              style: AppText.display(22, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoCelular() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          Text('+51', style: AppText.display(18, weight: FontWeight.w700)),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 26, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _celular,
              keyboardType: TextInputType.phone,
              maxLength: 9,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppText.body(
                18,
                weight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isCollapsed: true,
                hintText: '987 654 321',
                hintStyle: AppText.body(
                  18,
                  weight: FontWeight.w500,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoPassword() {
    final activo = _password.text.isNotEmpty;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(
          color: activo ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppTheme.rField),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _password,
              obscureText: !_verPassword,
              style: AppText.body(
                18,
                weight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: _verPassword ? 0 : 3,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _verPassword = !_verPassword),
            icon: Icon(
              _verPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: _verPassword ? 'Ocultar contraseña' : 'Ver contraseña',
          ),
        ],
      ),
    );
  }

  Widget _enlaceRegistro(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '¿Tu negocio aún no está? ',
            style: AppText.body(16, weight: FontWeight.w500),
          ),
          GestureDetector(
            // `push` y no `go`: así el botón atrás del sistema devuelve al
            // Login en vez de cerrar la app.
            onTap: () => context.push(AppRoutes.businessVerification),
            child: Text(
              'Regístralo',
              style: AppText.body(
                16,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
