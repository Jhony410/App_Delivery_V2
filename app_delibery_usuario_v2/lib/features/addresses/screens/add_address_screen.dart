import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/map_backdrop.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 16 · Agregar dirección. Dirección + ubicación actual + mini-mapa + referencia.
/// "Ajustar en el mapa" -> /adjust-map (recuerda que viene de add-address).
/// Guardar -> confirma en /adjust-map y vuelve a /addresses.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _address = TextEditingController(text: 'Jr. 2 de Mayo con Jr. Ayacucho');
  final _reference = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Dirección', style: AppText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _address,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Obteniendo tu ubicación…')),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Usar mi ubicación actual',
                          style: AppText.label.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Tu punto en el mapa', style: AppText.label),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push(
                      AppRoutes.adjustMapFrom(AppRoutes.nAddAddress)),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Stack(
                      children: [
                        Positioned.fill(child: MapBackdrop(showCenterPin: true)),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: _TapHint(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                      AppRoutes.adjustMapFrom(AppRoutes.nAddAddress)),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Ajustar el punto en el mapa'),
                ),
                const SizedBox(height: 18),
                Text('Referencia', style: AppText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _reference,
                  decoration: const InputDecoration(hintText: 'Opcional'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            // Guardar -> confirma en el mapa y su confirmación vuelve a /addresses.
            child: ElevatedButton(
              onPressed: () =>
                  context.push(AppRoutes.adjustMapFrom(AppRoutes.nAddresses)),
              child: const Text('Guardar dirección'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Text('Agregar dirección', style: AppText.h3),
        ],
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Toca para ajustar',
          style: AppText.badge.copyWith(color: Colors.white)),
    );
  }
}
