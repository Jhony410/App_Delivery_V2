import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../data/models/configuracion_operativa.dart';
import '../../providers/configuracion_provider.dart';

/// Hoja de edición de una tarifa o comisión. Devuelve el nuevo valor.
class HojaEditarTarifa extends StatefulWidget {
  const HojaEditarTarifa({super.key, required this.parametro});

  final ParametroTarifa parametro;

  @override
  State<HojaEditarTarifa> createState() => _HojaEditarTarifaState();
}

class _HojaEditarTarifaState extends State<HojaEditarTarifa> {
  late final TextEditingController _valor = TextEditingController(
    text: widget.parametro.unidad == '%'
        ? widget.parametro.valor.toStringAsFixed(0)
        : widget.parametro.valor.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  double? get _valorValido {
    final valor = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (valor == null || valor < 0) return null;
    if (widget.parametro.unidad == '%' && valor > 100) return null;
    return valor;
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: widget.parametro.titulo,
      subtitulo: widget.parametro.descripcion,
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: 'Aplicar',
          expand: true,
          onPressed: _valorValido == null
              ? null
              : () => Navigator.of(context).pop(_valorValido),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: widget.parametro.unidad == '%'
                ? 'Porcentaje (%)'
                : 'Importe (S/)',
            controller: _valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            required: true,
            errorText: _valorValido == null
                ? widget.parametro.unidad == '%'
                      ? 'Ingresa un porcentaje entre 0 y 100'
                      : 'Ingresa un importe válido'
                : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'El cambio queda pendiente hasta que pulses «Guardar cambios» en '
            'la pantalla de configuración.',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Hoja de cambio de rol de un miembro. Devuelve el rol elegido.
class HojaEditarRol extends StatefulWidget {
  const HojaEditarRol({super.key, required this.miembro});

  final MiembroEquipo miembro;

  @override
  State<HojaEditarRol> createState() => _HojaEditarRolState();
}

class _HojaEditarRolState extends State<HojaEditarRol> {
  late RolEquipo _rol = widget.miembro.rol;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Editar rol',
      subtitulo: '${widget.miembro.nombre} · ${widget.miembro.correo}',
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: 'Aplicar',
          expand: true,
          onPressed: _rol == widget.miembro.rol
              ? null
              : () => Navigator.of(context).pop(_rol),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<RolEquipo>(
            groupValue: _rol,
            onChanged: (valor) => setState(() => _rol = valor ?? _rol),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final rol in RolEquipo.values)
                  RadioListTile<RolEquipo>(
                    value: rol,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: Text(
                      rol.etiqueta,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                    subtitle: Text(
                      rol.permisos,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Hoja de invitación de un nuevo miembro al equipo de operaciones.
class HojaInvitarMiembro extends StatefulWidget {
  const HojaInvitarMiembro({super.key});

  @override
  State<HojaInvitarMiembro> createState() => _HojaInvitarMiembroState();
}

class _HojaInvitarMiembroState extends State<HojaInvitarMiembro> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  RolEquipo _rol = RolEquipo.soporte;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  bool get _valido =>
      _nombre.text.trim().length > 3 && _correo.text.trim().contains('@');

  Future<void> _invitar() async {
    setState(() => _enviando = true);
    final provider = context.read<ConfiguracionProvider>();
    final ok = await provider.invitar(
      nombre: _nombre.text.trim(),
      correo: _correo.text.trim(),
      rol: _rol,
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      ok
          ? 'Invitación enviada a ${_correo.text.trim()} como '
                '${_rol.etiqueta}.'
          : provider.error ?? 'No se pudo enviar la invitación.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Invitar al equipo',
      subtitulo: 'Recibirá acceso al panel con el rol que elijas.',
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: _enviando ? 'Enviando…' : 'Enviar invitación',
          expand: true,
          onPressed: _valido && !_enviando ? _invitar : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nombre',
            controller: _nombre,
            hint: 'Marco Vilca',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Correo',
            controller: _correo,
            hint: 'marco@delypuno.pe',
            keyboardType: TextInputType.emailAddress,
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<RolEquipo>(
            label: 'Rol',
            value: _rol,
            items: RolEquipo.values,
            itemLabel: (rol) => '${rol.etiqueta} · ${rol.permisos}',
            onChanged: (rol) => setState(() => _rol = rol ?? _rol),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
