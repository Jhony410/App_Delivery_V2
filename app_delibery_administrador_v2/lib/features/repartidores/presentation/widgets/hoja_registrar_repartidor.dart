import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../providers/repartidores_provider.dart';

/// Hoja de alta de repartidor.
///
/// El diseño incluye el botón «+ Registrar repartidor» pero no dibuja la
/// pantalla de destino, así que el formulario se arma con los campos y
/// botones del frame 14 en lugar de inventar una pantalla nueva.
class HojaRegistrarRepartidor extends StatefulWidget {
  const HojaRegistrarRepartidor({super.key});

  @override
  State<HojaRegistrarRepartidor> createState() =>
      _HojaRegistrarRepartidorState();
}

class _HojaRegistrarRepartidorState extends State<HojaRegistrarRepartidor> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _celular = TextEditingController();
  final TextEditingController _placa = TextEditingController();
  String _vehiculo = 'Moto';
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _dni.dispose();
    _celular.dispose();
    _placa.dispose();
    super.dispose();
  }

  bool get _valido =>
      _nombre.text.trim().length > 3 &&
      _dni.text.trim().length >= 8 &&
      _celular.text.trim().length >= 9;

  Future<void> _registrar() async {
    setState(() => _enviando = true);
    final provider = context.read<RepartidoresProvider>();
    final creado = await provider.registrar(
      nombre: _nombre.text.trim(),
      dni: _dni.text.trim(),
      celular: _celular.text.trim(),
      vehiculo: _vehiculo,
      placa: _placa.text.trim(),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    mostrarAviso(
      context,
      creado == null
          ? provider.error ?? 'No se pudo registrar al repartidor.'
          : '${creado.nombre} quedó registrado con documentos por verificar.',
      exito: creado != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      titulo: 'Registrar repartidor',
      subtitulo:
          'Entrará en CHASQUI con los cinco documentos por verificar. '
          'Zonas activas: ${DelyMockStore.zonas.take(3).join(', ')}.',
      acciones: [
        AppButton.neutral(
          label: 'Cancelar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
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
            label: 'Nombre completo',
            controller: _nombre,
            hint: 'Rubén Mamani Quispe',
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'DNI',
            controller: _dni,
            hint: '45871234',
            keyboardType: TextInputType.number,
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Celular',
            controller: _celular,
            hint: '987 654 321',
            keyboardType: TextInputType.phone,
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<String>(
            label: 'Vehículo',
            value: _vehiculo,
            items: const ['Moto', 'Bicicleta', 'Auto', 'A pie'],
            itemLabel: (v) => v,
            onChanged: (v) => setState(() => _vehiculo = v ?? 'Moto'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Placa',
            controller: _placa,
            hint: 'ABC-123',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
