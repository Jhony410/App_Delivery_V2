import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_buttons.dart';

/// Modal de confirmación del frame 14: cuadro de icono, título, texto de
/// apoyo, campo de motivo opcional y dos botones al pie.
///
/// Devuelve el motivo escrito al confirmar, cadena vacía si no se pedía
/// motivo, y `null` si se cancela.
Future<String?> mostrarConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String etiquetaConfirmar,
  String etiquetaCancelar = 'Cancelar',
  bool destructiva = true,
  bool pedirMotivo = false,
  String motivoHint = 'Motivo obligatorio…',
  IconData icono = Icons.warning_amber_rounded,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DialogoConfirmacion(
      titulo: titulo,
      mensaje: mensaje,
      etiquetaConfirmar: etiquetaConfirmar,
      etiquetaCancelar: etiquetaCancelar,
      destructiva: destructiva,
      pedirMotivo: pedirMotivo,
      motivoHint: motivoHint,
      icono: icono,
    ),
  );
}

class _DialogoConfirmacion extends StatefulWidget {
  const _DialogoConfirmacion({
    required this.titulo,
    required this.mensaje,
    required this.etiquetaConfirmar,
    required this.etiquetaCancelar,
    required this.destructiva,
    required this.pedirMotivo,
    required this.motivoHint,
    required this.icono,
  });

  final String titulo;
  final String mensaje;
  final String etiquetaConfirmar;
  final String etiquetaCancelar;
  final bool destructiva;
  final bool pedirMotivo;
  final String motivoHint;
  final IconData icono;

  @override
  State<_DialogoConfirmacion> createState() => _DialogoConfirmacionState();
}

class _DialogoConfirmacionState extends State<_DialogoConfirmacion> {
  final TextEditingController _motivo = TextEditingController();
  bool _puedeConfirmar = false;

  @override
  void initState() {
    super.initState();
    _puedeConfirmar = !widget.pedirMotivo;
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final acento = widget.destructiva
        ? AppColors.dangerText
        : AppColors.primary;
    final acentoFondo = widget.destructiva
        ? AppColors.dangerSoft
        : AppColors.primarySoft;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: acentoFondo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(widget.icono, size: 24, color: acento),
              ),
              const SizedBox(height: 14),
              Text(
                widget.titulo,
                style: AppTextStyles.sectionTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.mensaje,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.pedirMotivo) ...[
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _motivo,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(hintText: widget.motivoHint),
                  onChanged: (valor) {
                    final valido = valor.trim().isNotEmpty;
                    if (valido != _puedeConfirmar) {
                      setState(() => _puedeConfirmar = valido);
                    }
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton.neutral(
                      label: widget.etiquetaCancelar,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: AppButton(
                      label: widget.etiquetaConfirmar,
                      expand: true,
                      variant: widget.destructiva
                          ? AppButtonVariant.destructive
                          : AppButtonVariant.primary,
                      onPressed: _puedeConfirmar
                          ? () => Navigator.of(context).pop(_motivo.text.trim())
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Envoltura estándar de las hojas inferiores del panel: título, subtítulo
/// opcional, contenido desplazable y botonera al pie.
///
/// El contenido siempre va dentro de un scroll y respeta el teclado y el
/// `SafeArea`, así que ninguna hoja puede desbordar.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.titulo,
    required this.child,
    this.subtitulo,
    this.acciones,
    this.maxWidth = 520,
  });

  final String titulo;
  final String? subtitulo;
  final Widget child;
  final List<Widget>? acciones;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: media.size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titulo,
                        style: AppTextStyles.sectionTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: child,
                  ),
                ),
                if (acciones != null && acciones!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < acciones!.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm + 2),
                          Expanded(child: acciones![i]),
                        ],
                      ],
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

/// Abre una [AppBottomSheet] con la configuración estándar del panel.
Future<T?> mostrarHoja<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: builder,
  );
}

/// Aviso breve al pie de la pantalla. Toda acción que no navega deja rastro
/// aquí, para que ningún control quede sin respuesta.
void mostrarAviso(BuildContext context, String mensaje, {bool exito = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              exito ? Icons.check_circle : Icons.info_outline,
              size: 18,
              color: exito ? AppColors.success : AppColors.textOnPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                mensaje,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
