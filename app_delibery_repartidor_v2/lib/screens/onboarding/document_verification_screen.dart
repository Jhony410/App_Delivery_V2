import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/buttons.dart';

/// Frame 05 — Verificación de documentos (alta del repartidor).
///
/// Último paso del onboarding: 3 de 5 documentos aprobados. Cuando los cinco
/// están listos, "Enviar a revisión" abre el núcleo operativo.
class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  late List<RiderDocument> _documents = List.of(DemoData.onboardingDocuments);

  int get _approved =>
      _documents.where((d) => d.status != DocumentStatus.pendiente).length;

  bool get _canSubmit => _documents.every((d) => d.status != DocumentStatus.pendiente);

  /// Simula la subida del documento que falta.
  void _upload(int index) {
    setState(() {
      _documents = [
        for (var i = 0; i < _documents.length; i++)
          if (i == index)
            RiderDocument(
              name: _documents[i].name,
              icon: _documents[i].icon,
              status: DocumentStatus.enRevision,
              expiry: _documents[i].expiry,
            )
          else
            _documents[i],
      ];
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${_documents[index].name} enviado a revisión'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final total = _documents.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          BrandHeader(
            borderRadius: BorderRadius.zero,
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verifica tus documentos',
                  style: AppText.display(22, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Necesarios para repartir en moto',
                  style: AppText.body(13, color: AppColors.textOnBrandSoft),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : _approved / total,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_approved / $total',
                      style: AppText.display(12, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              itemCount: _documents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _DocumentTile(
                document: _documents[index],
                onUpload: () => _upload(index),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.paddingOf(context).bottom),
            child: PrimaryButton(
              label: 'Enviar a revisión',
              // Deshabilitado hasta subir todo: es el botón gris del frame 05.
              onPressed: _canSubmit ? () => context.go(AppRoutes.operations) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.onUpload});

  final RiderDocument document;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final pending = document.status == DocumentStatus.pendiente;
    final inReview = document.status == DocumentStatus.enRevision;
    final verified = document.status == DocumentStatus.verificado;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(
          color: inReview ? AppColors.primary : AppColors.borderSoft,
          width: inReview ? 1.5 : 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pending ? AppColors.fill : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              document.icon,
              size: 24,
              color: pending ? AppColors.neutral : AppColors.primary,
            ),
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
                  document.status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, color: document.status.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (verified)
            const Icon(Icons.check_circle_rounded, size: 24, color: AppColors.online)
          else if (inReview)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('REVISANDO', style: AppText.chip(AppColors.warning)),
            )
          else
            TextButton(
              onPressed: onUpload,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Subir',
                style: AppText.display(12, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
