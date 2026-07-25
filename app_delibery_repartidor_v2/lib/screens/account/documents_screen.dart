import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/buttons.dart';

/// Frame 17 — Mis documentos.
///
/// Banner de resumen y las tarjetas con estado y vencimiento. Cada tarjeta
/// abre su hoja de detalle: ninguna fila es decorativa.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late List<RiderDocument> _documents = List.of(DemoData.riderDocuments);

  /// "Al día" incluye los que están por vencer: siguen siendo válidos hoy.
  /// Solo un documento pendiente o en revisión rompe el estado verde.
  bool get _allValid => _documents.every(
        (d) => d.status == DocumentStatus.verificado || d.status == DocumentStatus.porVencer,
      );

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      currentRoute: AppRoutes.documents,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  const BackToMapButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mis documentos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(22),
                    ),
                  ),
                  const DrawerMenuButton(onSurface: true),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 30 + MediaQuery.paddingOf(context).bottom),
                children: [
                  _SummaryBanner(allValid: _allValid),
                  const SizedBox(height: 12),
                  for (final document in _documents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DocumentCard(
                        document: document,
                        onTap: () => _showDocumentSheet(document),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentSheet(RiderDocument document) {
    final needsRenewal = document.status != DocumentStatus.verificado;

    showAccountSheet(
      context,
      title: document.name,
      subtitle: document.expiry,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: document.status.background,
              borderRadius: BorderRadius.circular(AppTheme.rField),
            ),
            child: Row(
              children: [
                Icon(
                  needsRenewal ? Icons.error_outline_rounded : Icons.verified_rounded,
                  size: 20,
                  color: document.status.color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    document.status.label,
                    style: AppText.body(13, weight: FontWeight.w600, color: document.status.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: needsRenewal ? 'Actualizar documento' : 'Volver a subir',
            icon: Icons.file_upload_outlined,
            onPressed: () => _renew(document),
          ),
        ],
      ),
    );
  }

  /// Simula el envío de una versión nueva del documento.
  void _renew(RiderDocument document) {
    Navigator.of(context).pop();
    setState(() {
      _documents = [
        for (final d in _documents)
          if (d.name == document.name)
            RiderDocument(
              name: d.name,
              icon: d.icon,
              status: DocumentStatus.enRevision,
              expiry: 'En revisión · respuesta en 24 h',
            )
          else
            d,
      ];
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${document.name} enviado a revisión'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// Banner superior: verde cuando todo está al día, ámbar si algo falta.
class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.allValid});

  final bool allValid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: allValid ? AppColors.primarySoft : AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          Icon(
            allValid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
            size: 20,
            color: allValid ? AppColors.primaryOnSoft : AppColors.warning,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              allValid
                  ? 'Todos tus documentos están al día'
                  : 'Tienes documentos por revisar o subir',
              style: AppText.body(
                13,
                weight: FontWeight.w600,
                color: allValid ? AppColors.primaryDark : AppColors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.onTap});

  final RiderDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warn = document.status == DocumentStatus.porVencer;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppTheme.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.rCard),
            border: Border.all(color: warn ? AppColors.warningBorder : AppColors.borderSoft),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: document.status.background,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(document.icon, size: 24, color: document.status.color),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        document.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(15, weight: FontWeight.w700),
                      ),
                      Text(
                        document.expiry,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                          11,
                          color: warn ? AppColors.warning : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: document.status.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(document.status.badge, style: AppText.chip(document.status.color)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
