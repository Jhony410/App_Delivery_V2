import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../providers/sesion_provider.dart';

/// Acceso al panel de operaciones.
///
/// No procede del diseño importado: se construyó con los componentes del
/// frame 14 (campo, botón primario, tarjeta) para dar una puerta de entrada
/// al panel. Al conectar Firebase Auth solo cambia [SesionProvider].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correo = TextEditingController(
    text: DelyMockStore.operadorCorreo,
  );
  final TextEditingController _contrasena = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    final sesion = context.read<SesionProvider>();
    await sesion.iniciarSesion(
      correo: _correo.text,
      contrasena: _contrasena.text,
    );
    // La redirección la resuelve el router al cambiar el estado de sesión.
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AdminLogo(size: 64),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'DelyPuno',
                    style: AppTextStyles.brandTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'OPERACIONES',
                    style: AppTextStyles.captionStrong.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Torre de control de DelyPuno, DelyPuno Negocios y CHASQUI',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xl + 4),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppTextField(
                          label: 'Correo del equipo',
                          controller: _correo,
                          hint: 'nombre@delypuno.pe',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.alternate_email,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            AppTextField(
                              label: 'Contraseña',
                              controller: _contrasena,
                              hint: '••••••••',
                              obscureText: !_mostrarContrasena,
                              prefixIcon: Icons.lock_outline,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xl,
                                right: 4,
                              ),
                              child: IconButton(
                                tooltip: _mostrarContrasena
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                icon: Icon(
                                  _mostrarContrasena
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _mostrarContrasena = !_mostrarContrasena,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sesion.hayError) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: AppRadius.control,
                              border: Border.all(
                                color: AppColors.dangerSoftBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: AppColors.dangerText,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    sesion.error!,
                                    style: AppTextStyles.captionSmall.copyWith(
                                      color: AppColors.dangerText,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        if (sesion.cargando)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 11),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          )
                        else
                          AppButton.primary(
                            label: 'Ingresar al panel',
                            expand: true,
                            onPressed: _ingresar,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Sistema operativo · ${DelyMockStore.versionSistema}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
