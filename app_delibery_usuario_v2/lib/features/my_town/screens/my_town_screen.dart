import 'package:flutter/material.dart';

import '../../../core/widgets/andean_pattern.dart';
import '../../../theme/app_theme.dart';

/// 18 · Mi Pueblo (Melgar). Pestaña de la barra inferior. Selector de zona,
/// actividades, lugares y números útiles. También accesible desde el header
/// del Home.
class MyTownScreen extends StatefulWidget {
  const MyTownScreen({super.key});

  @override
  State<MyTownScreen> createState() => _MyTownScreenState();
}

class _MyTownScreenState extends State<MyTownScreen> {
  int _tab = 2; // 0 Actividades, 1 Lugares, 2 Números útiles

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      body: Column(
        children: [
          _hero(context),
          _tabs(),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      height: 210 + MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7FB98F), Color(0xFF3C6E4E)],
        ),
      ),
      child: Stack(
        children: [
          const AndeanPattern(opacity: 0.18),
          Positioned(
            bottom: 16,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Melgar',
                    style: AppText.display.copyWith(fontSize: 26, color: Colors.white)),
                Text('Provincia de Puno · Ayaviri',
                    style: AppText.caption.copyWith(color: const Color(0xFFE4F0E8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    final tabs = [
      ('🎉 Actividades', '8'),
      ('📍 Lugares', '13'),
      ('📞 Números útiles', '2'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descubre lo mejor de nuestro pueblo: qué hacer, dónde ir y a '
              'quién llamar.', style: AppText.bodySecondary),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (context, i) {
                final active = i == _tab;
                return GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Row(
                      children: [
                        Text(tabs[i].$1,
                            style: AppText.bodySecondary.copyWith(
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : AppColors.textPrimary,
                            )),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(tabs[i].$2,
                              style: AppText.small.copyWith(
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : AppColors.primaryDark,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_tab == 2) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _phoneCard('Serenazgo Melgar', '951 015 995'),
          const SizedBox(height: 14),
          _phoneCard('Comisaría PNP Ayaviri', '964 778 078'),
        ],
      );
    }
    final items = _tab == 0
        ? const [
            ('Feria dominical de Ayaviri', 'Domingos · Plaza de Armas'),
            ('Festival del Queso', 'Julio · Explanada municipal'),
            ('Ruta de las chullpas', 'Todo el año · a 20 min'),
          ]
        : const [
            ('Catedral San Francisco de Asís', 'Centro histórico'),
            ('Mirador de Ayaviri', 'Vista panorámica'),
            ('Cañón de Tinajani', 'Formaciones rocosas · 15 km'),
          ];
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: AppColors.greenLight, shape: BoxShape.circle),
              child: Icon(_tab == 0 ? Icons.celebration : Icons.place,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i].$1, style: AppText.cardTitle),
                  Text(items[i].$2, style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneCard(String name, String number) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.greenLight, shape: BoxShape.circle),
            child: const Icon(Icons.call, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.cardTitle),
                Text(number,
                    style: AppText.bodySecondary
                        .copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Llamando a $name…')),
            ),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call, color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text('Llamar',
                      style: AppText.buttonSm.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
