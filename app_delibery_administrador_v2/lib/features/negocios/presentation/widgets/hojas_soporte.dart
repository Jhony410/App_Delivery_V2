import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../data/models/negocio.dart';
import '../../providers/negocios_provider.dart';

/// Hoja de edición de un producto del catálogo, abierta desde «Editar» en
/// Soporte al negocio.
class HojaEditarProducto extends StatefulWidget {
  const HojaEditarProducto({
    super.key,
    required this.negocioId,
    required this.producto,
  });

  final String negocioId;
  final Producto producto;

  @override
  State<HojaEditarProducto> createState() => _HojaEditarProductoState();
}

class _HojaEditarProductoState extends State<HojaEditarProducto> {
  late final TextEditingController _nombre = TextEditingController(
    text: widget.producto.nombre,
  );
  late final TextEditingController _precio = TextEditingController(
    text: widget.producto.precio.toStringAsFixed(2),
  );
  late bool _disponible = widget.producto.disponible;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    super.dispose();
  }

  double? get _precioValido {
    final valor = double.tryParse(_precio.text.trim().replaceAll(',', '.'));
    if (valor == null || valor <= 0) return null;
    return valor;
  }

  Future<void> _guardar() async {
    final precio = _precioValido;
    if (precio == null || _nombre.text.trim().isEmpty) return;

    setState(() => _enviando = true);
    final provider = context.read<NegociosProvider>();
    final ok = await provider.actualizarProducto(
      negocioId: widget.negocioId,
      producto: widget.producto.copyWith(
        nombre: _nombre.text.trim(),
        precio: precio,
        disponible: _disponible,
      ),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      ok
          ? '${_nombre.text.trim()} actualizado en el catálogo.'
          : provider.error ?? 'No se pudo actualizar el producto.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Editar producto',
      subtitulo: 'Los cambios se aplican en nombre del negocio.',
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: _enviando ? 'Guardando…' : 'Guardar',
          expand: true,
          onPressed: _precioValido != null && !_enviando ? _guardar : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nombre del producto',
            controller: _nombre,
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Precio (S/)',
            controller: _precio,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            required: true,
            errorText: _precioValido == null
                ? 'Ingresa un precio válido'
                : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSwitchTile(
            title: 'Disponible',
            subtitle: 'Si lo apagas, el cliente lo verá como agotado',
            value: _disponible,
            onChanged: (valor) => setState(() => _disponible = valor),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Hoja de ajuste del horario de atención.
class HojaAjustarHorario extends StatefulWidget {
  const HojaAjustarHorario({super.key, required this.negocio});

  final Negocio negocio;

  @override
  State<HojaAjustarHorario> createState() => _HojaAjustarHorarioState();
}

class _HojaAjustarHorarioState extends State<HojaAjustarHorario> {
  late final TextEditingController _horario = TextEditingController(
    text: widget.negocio.horario,
  );
  bool _enviando = false;

  @override
  void dispose() {
    _horario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _enviando = true);
    final provider = context.read<NegociosProvider>();
    final ok = await provider.actualizarHorario(
      negocioId: widget.negocio.id,
      horario: _horario.text.trim(),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      ok
          ? 'Horario de ${widget.negocio.nombre}: ${_horario.text.trim()}.'
          : provider.error ?? 'No se pudo actualizar el horario.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Ajustar horario',
      subtitulo: widget.negocio.nombre,
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: _enviando ? 'Guardando…' : 'Guardar',
          expand: true,
          onPressed: _horario.text.trim().isEmpty || _enviando
              ? null
              : _guardar,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Horario de atención',
            controller: _horario,
            hint: '11:00–22:30',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Formato del diseño: hora de apertura, guion largo y hora de '
            'cierre.',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Hoja de ajuste de la comisión pactada con el negocio.
class HojaAjustarComision extends StatefulWidget {
  const HojaAjustarComision({super.key, required this.negocio});

  final Negocio negocio;

  @override
  State<HojaAjustarComision> createState() => _HojaAjustarComisionState();
}

class _HojaAjustarComisionState extends State<HojaAjustarComision> {
  late double _comision = widget.negocio.comision.toDouble();
  bool _enviando = false;

  Future<void> _guardar() async {
    setState(() => _enviando = true);
    final provider = context.read<NegociosProvider>();
    final ok = await provider.actualizarComision(
      negocioId: widget.negocio.id,
      comision: _comision.round(),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      ok
          ? 'Comisión de ${widget.negocio.nombre}: ${_comision.round()}%.'
          : provider.error ?? 'No se pudo actualizar la comisión.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Ajustar comisión',
      subtitulo: widget.negocio.nombre,
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: _enviando ? 'Guardando…' : 'Guardar',
          expand: true,
          onPressed: _enviando ? null : _guardar,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Comisión sobre el total del pedido',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${_comision.round()}%',
                style: AppTextStyles.screenTitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _comision,
            min: 5,
            max: 30,
            divisions: 25,
            label: '${_comision.round()}%',
            onChanged: (valor) => setState(() => _comision = valor),
          ),
          Text(
            'La comisión estándar de DelyPuno es 18% y la de bodegas, 12%.',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
