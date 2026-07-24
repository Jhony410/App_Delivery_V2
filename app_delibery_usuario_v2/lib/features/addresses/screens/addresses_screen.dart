import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/andean_pattern.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 15 · Mis direcciones. Lista con editar/eliminar. Botón "+" -> /add-address.
/// Tocar una dirección -> /adjust-map (para reubicar el pin).
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int _selected = 0;

  final _addresses = <_Address>[
    const _Address(
      icon: Icons.home_rounded,
      iconBg: AppColors.greenLight,
      iconColor: AppColors.primary,
      tag: 'Principal',
      tagColor: AppColors.primaryDark,
      tagBg: AppColors.greenLight,
      title: 'Jr. Lima 320 con Jr. Puno',
      reference: 'Frente a la Plaza de Armas',
    ),
    const _Address(
      icon: Icons.work_outline,
      iconBg: Color(0xFFEDEBFB),
      iconColor: AppColors.yape,
      tag: 'Trabajo',
      tagColor: AppColors.yape,
      tagBg: Color(0xFFEDEBFB),
      title: 'Jr. Deustua 145',
      reference: 'Oficina 2° piso',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addAddress),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _addressCard(context, i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 20),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Stack(
        children: [
          const AndeanPattern(),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              Text('Mis direcciones',
                  style: AppText.h2.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, int i) {
    final a = _addresses[i];
    final selected = i == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFCDD1CA),
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: a.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(a.icon, color: a.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.tagBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(a.tag,
                        style: AppText.badge.copyWith(color: a.tagColor, fontSize: 9)),
                  ),
                  const SizedBox(height: 4),
                  Text(a.title,
                      style: AppText.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('📍 ${a.reference}', style: AppText.caption),
                ],
              ),
            ),
            Column(
              children: [
                _miniBtn(Icons.edit_outlined, AppColors.greenLight,
                    AppColors.primary, () => context.push(AppRoutes.addAddress)),
                const SizedBox(height: 8),
                _miniBtn(Icons.delete_outline, const Color(0xFFFDEEE9),
                    AppColors.dangerSoft, () => _delete(i)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  void _delete(int i) {
    setState(() {
      _addresses.removeAt(i);
      if (_selected >= _addresses.length) _selected = 0;
    });
  }
}

class _Address {
  const _Address({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.title,
    required this.reference,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String tag;
  final Color tagColor;
  final Color tagBg;
  final String title;
  final String reference;
}
