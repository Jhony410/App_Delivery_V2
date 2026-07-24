import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/widgets/business_card.dart';
import '../../../core/widgets/states.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 06 · Búsqueda (pestaña). Estado vacío con sugerencias; al escribir muestra
/// resultados que llevan a /business/:id.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  final _recent = <String>['Pollo a la brasa', 'Ibuprofeno', 'Cerveza'];

  List<Business> get _results {
    if (_query.trim().isEmpty) return const [];
    final q = _query.toLowerCase();
    return DemoData.businesses
        .where((b) =>
            b.name.toLowerCase().contains(q) || b.tags.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _searchBar(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      style: AppText.body,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Busca platos, comercios, medicinas…',
                        hintStyle:
                            AppText.body.copyWith(color: AppColors.textPlaceholder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_query.isNotEmpty)
            TextButton(
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
              child: Text('Cancelar', style: AppText.link),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_query.trim().isNotEmpty) {
      final results = _results;
      if (results.isEmpty) {
        return const EmptyState(
          icon: Icons.search_off,
          title: 'Sin resultados',
          message: 'Prueba con otra palabra o revisa la ortografía.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) => BusinessListCard(
          business: results[i],
          onTap: () => context.push(AppRoutes.businessTo(results[i].id)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Búsquedas recientes', style: AppText.cardTitle),
            GestureDetector(
              onTap: () => setState(_recent.clear),
              child: Text('Borrar', style: AppText.caption),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final term in _recent)
              GestureDetector(
                onTap: () {
                  _controller.text = term;
                  setState(() => _query = term);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 7),
                      Text(term, style: AppText.bodySecondary),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Populares en Puno', style: AppText.cardTitle),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _popularCard('Trucha frita', const [Color(0xFFF2C98F), Color(0xFFD98324)]),
            _popularCard('Chairo paceño', const [Color(0xFFBEE6CE), Color(0xFF5FB98A)]),
          ],
        ),
        const SizedBox(height: 26),
        const EmptyState(
          icon: Icons.search,
          title: 'Empieza a escribir',
          message:
              'Busca platos, comercios, medicinas o productos del mercado en todo Puno.',
        ),
      ],
    );
  }

  Widget _popularCard(String label, List<Color> gradient) {
    return GestureDetector(
      onTap: () {
        _controller.text = label;
        setState(() => _query = label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(label, style: AppText.cardTitle.copyWith(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
