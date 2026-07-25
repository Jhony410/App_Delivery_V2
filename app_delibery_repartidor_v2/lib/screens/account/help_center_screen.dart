import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/buttons.dart';

/// Frame 19 — Centro de ayuda.
///
/// Buscador, acceso directo a soporte por WhatsApp, preguntas frecuentes
/// desplegables y el botón para reportar un problema con un pedido.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const String _supportNumber = '+51 984 112 550';

  final TextEditingController _search = TextEditingController();

  /// Índice de la pregunta abierta; `null` si están todas cerradas.
  int? _expanded;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FaqEntry> get _results {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return DemoData.faqs;
    return DemoData.faqs
        .where((f) =>
            f.question.toLowerCase().contains(query) || f.answer.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return AccountScaffold(
      currentRoute: AppRoutes.help,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandHeader(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(children: [DrawerMenuButton()]),
                  const SizedBox(height: 16),
                  Text('¿En qué te ayudamos?', style: AppText.display(22, color: Colors.white)),
                  const SizedBox(height: 14),
                  _SearchField(
                    controller: _search,
                    onChanged: (_) => setState(() => _expanded = null),
                  ),
                ],
              ),
            ),

            // ---- Soporte por WhatsApp ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _WhatsAppCard(onTap: _openWhatsApp),
            ),

            // ---- Preguntas frecuentes ----
            Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 30 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Preguntas frecuentes',
                    style: AppText.display(16, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (results.isEmpty)
                    _NoResults(query: _search.text.trim())
                  else
                    SettingsGroup(
                      children: [
                        for (var i = 0; i < results.length; i++)
                          _FaqTile(
                            entry: results[i],
                            expanded: _expanded == i,
                            divider: i < results.length - 1,
                            onTap: () => setState(() => _expanded = _expanded == i ? null : i),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  DangerButton(
                    label: 'Reportar un problema con un pedido',
                    icon: Icons.warning_amber_rounded,
                    onPressed: _reportProblem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWhatsApp() {
    final messenger = ScaffoldMessenger.of(context);

    showAccountSheet(
      context,
      title: 'Soporte por WhatsApp',
      subtitle: 'Escríbenos y te respondemos en unos 5 minutos, cualquier día y hora.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(AppTheme.rCard),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.whatsapp),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _supportNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(16, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Copiar número',
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _supportNumber));
              Navigator.of(context).pop();
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Número de soporte copiado'),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
        ],
      ),
    );
  }

  void _reportProblem() {
    const reasons = [
      ('El cliente no estaba en la dirección', Icons.person_off_outlined),
      ('El restaurante entregó el pedido incompleto', Icons.remove_shopping_cart_outlined),
      ('Tuve un problema con mi moto', Icons.two_wheeler_outlined),
      ('Otro motivo', Icons.more_horiz_rounded),
    ];

    final messenger = ScaffoldMessenger.of(context);

    showAccountSheet(
      context,
      title: 'Reportar un problema',
      subtitle: 'Cuéntanos qué pasó con el pedido ${DemoData.incomingOrder.id}. '
          'Un reporte no afecta tu calificación.',
      child: SettingsGroup(
        children: [
          for (var i = 0; i < reasons.length; i++)
            SettingsRow(
              icon: reasons[i].$2,
              label: reasons[i].$1,
              divider: i < reasons.length - 1,
              onTap: () {
                Navigator.of(context).pop();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Reporte enviado. Soporte te escribirá por WhatsApp.'),
                      backgroundColor: AppColors.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
        ],
      ),
    );
  }
}

/// Buscador blanco sobre la cabecera verde.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rField),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: AppText.body(14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Busca un problema…',
                hintStyle: AppText.body(14, color: AppColors.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta verde de soporte por WhatsApp.
class _WhatsAppCard extends StatelessWidget {
  const _WhatsAppCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whatsapp,
      borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.whatsapp.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Soporte por WhatsApp',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(16, weight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Respuesta en ~5 min · 24/7',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pregunta frecuente desplegable.
class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.entry,
    required this.expanded,
    required this.divider,
    required this.onTap,
  });

  final FaqEntry entry;
  final bool expanded;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(entry.icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          entry.question,
                          style: AppText.body(14, weight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: expanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10, left: 33),
                            child: Text(entry.answer, style: AppText.body(13, height: 1.55)),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (divider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

/// Búsqueda sin coincidencias: nunca deja la lista en blanco.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 36, color: AppColors.neutral),
          const SizedBox(height: 10),
          Text(
            'Sin resultados para "$query"',
            textAlign: TextAlign.center,
            style: AppText.display(15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Escríbenos por WhatsApp y lo vemos contigo.',
            textAlign: TextAlign.center,
            style: AppText.body(12),
          ),
        ],
      ),
    );
  }
}
