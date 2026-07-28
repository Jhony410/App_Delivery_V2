import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../providers/negocios_provider.dart';

/// Hoja de alta de negocio.
///
/// El diseño incluye «+ Registrar negocio» sin dibujar su destino, así que el
/// formulario reutiliza los campos y botones del frame 14.
class HojaRegistrarNegocio extends StatefulWidget {
  const HojaRegistrarNegocio({super.key});

  @override
  State<HojaRegistrarNegocio> createState() => _HojaRegistrarNegocioState();
}

class _HojaRegistrarNegocioState extends State<HojaRegistrarNegocio> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _horario = TextEditingController(
    text: '08:00–22:00',
  );
  String _categoria = 'Comida';
  bool _enviando = false;

  /// La comisión de bodegas es preferente (12%), el resto va al 18%.
  int get _comision => _categoria == 'Bodega' ? 12 : 18;

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _horario.dispose();
    super.dispose();
  }

  bool get _valido =>
      _nombre.text.trim().length > 3 &&
      _direccion.text.trim().length > 5 &&
      _horario.text.trim().isNotEmpty;

  Future<void> _registrar() async {
    setState(() => _enviando = true);
    final provider = context.read<NegociosProvider>();
    final creado = await provider.registrar(
      nombre: _nombre.text.trim(),
      categoria: _categoria,
      direccion: _direccion.text.trim(),
      horario: _horario.text.trim(),
      comision: _comision,
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      creado == null
          ? provider.error ?? 'No se pudo registrar el negocio.'
          : '${creado.nombre} quedó registrado como cerrado, con '
                '$_comision% de comisión. Ábrelo desde Soporte cuando esté '
                'listo.',
      exito: creado != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Registrar negocio',
      subtitulo:
          'Entra como cerrado hasta que el comerciante confirme su catálogo.',
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.destructive(
          label: _enviando ? 'Registrando…' : 'Registrar',
          expand: true,
          onPressed: _valido && !_enviando ? _registrar : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nombre del negocio',
            controller: _nombre,
            hint: 'Pollería El Cholo',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<String>(
            label: 'Categoría',
            value: _categoria,
            items: const ['Comida', 'Farmacia', 'Bodega', 'Cafetería', 'Otros'],
            itemLabel: (c) => c,
            onChanged: (c) => setState(() => _categoria = c ?? 'Comida'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Dirección',
            controller: _direccion,
            hint: 'Jr. Lima 320',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Horario de atención',
            controller: _horario,
            hint: '11:00–23:00',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSettingRow(
            title: 'Comisión inicial',
            subtitle: _categoria == 'Bodega'
                ? 'Categoría con margen bajo'
                : 'Acuerdo estándar',
            value: '$_comision%',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
