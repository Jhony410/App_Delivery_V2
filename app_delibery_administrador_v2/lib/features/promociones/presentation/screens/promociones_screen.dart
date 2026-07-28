import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../../negocios/providers/negocios_provider.dart';
import '../../data/models/promocion.dart';
import '../../providers/promociones_provider.dart';

/// Frame 10 · Promociones.
///
/// Creador de promoción con vista previa en vivo del banner tal como lo verá
/// el cliente, más el listado de promociones activas.
class PromocionesScreen extends StatefulWidget {
  const PromocionesScreen({super.key});

  @override
  State<PromocionesScreen> createState() => _PromocionesScreenState();
}

class _PromocionesScreenState extends State<PromocionesScreen> {
  late final TextEditingController _titulo;
  late final TextEditingController _valor;
  late final TextEditingController _desde;
  late final TextEditingController _hasta;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PromocionesProvider>();
    _titulo = TextEditingController(text: provider.titulo);
    _valor = TextEditingController(text: provider.valor);
    _desde = TextEditingController(text: provider.desde);
    _hasta = TextEditingController(text: provider.hasta);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      provider.cargar();
      context.read<NegociosProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _titulo.dispose();
    _valor.dispose();
    _desde.dispose();
    _hasta.dispose();
    super.dispose();
  }

  Future<void> _guardar({required bool publicar}) async {
    final provider = context.read<PromocionesProvider>();
    final ok = await provider.guardar(publicar: publicar);
    if (!mounted) return;
    mostrarAviso(
      context,
      ok
          ? publicar
                ? '«${provider.titulo}» publicada en la app del cliente.'
                : '«${provider.titulo}» guardada como borrador.'
          : provider.error ?? 'No se pudo guardar la promoción.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<PromocionesProvider>();
    final negocios = context.watch<NegociosProvider>();

    return AdminScreen(
      titulo: 'Promociones',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageHeader(titulo: 'Promociones'),
          const SizedBox(height: AppSpacing.xl),
          AdminTwoColumns(
            flexIzquierda: 12,
            flexDerecha: 10,
            izquierda: AppSectionCard(
              title: 'Nueva promoción',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Título',
                    controller: _titulo,
                    hint: '2×1 en pollo a la brasa',
                    required: true,
                    onChanged: provider.cambiarTitulo,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tipo',
                    style: AppTextStyles.labelStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final tipo in TipoPromocion.values)
                        AppFilterChip(
                          label: tipo.etiqueta,
                          selected: provider.tipo == tipo,
                          onTap: () => provider.cambiarTipo(tipo),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Valor',
                    controller: _valor,
                    hint: '25%',
                    required: true,
                    onChanged: provider.cambiarValor,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Desde',
                          controller: _desde,
                          hint: '28 jul. 2026',
                          onChanged: provider.cambiarDesde,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Hasta',
                          controller: _hasta,
                          hint: '04 ago. 2026',
                          onChanged: provider.cambiarHasta,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Negocios incluidos',
                    style: AppTextStyles.labelStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final nombre in provider.negociosIncluidos)
                        _ChipNegocio(
                          nombre: nombre,
                          onQuitar: () => provider.quitarNegocio(nombre),
                        ),
                      _BotonAnadirNegocio(
                        disponibles: [
                          for (final n in negocios.negocios)
                            if (!provider.negociosIncluidos.contains(n.nombre))
                              n.nombre,
                        ],
                        onAnadir: provider.agregarNegocio,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.primary(
                          label: 'Publicar promoción',
                          expand: true,
                          onPressed: provider.borradorValido
                              ? () => _guardar(publicar: true)
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: AppButton.neutral(
                          label: 'Guardar borrador',
                          expand: true,
                          onPressed: provider.borradorValido
                              ? () => _guardar(publicar: false)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            derecha: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSectionCard(
                  title: 'Vista previa · app del cliente',
                  child: _BannerPreview(
                    titulo: provider.titulo,
                    detalle: provider.textoBanner,
                  ),
                ),
                const SizedBox(height: AppSpacing.gridGap),
                AppSectionCard(
                  title: 'Promociones activas',
                  child: VistaAsync(
                    cargando: provider.cargando,
                    error: provider.error,
                    vacio: provider.promociones.isEmpty,
                    onReintentar: () => provider.cargar(forzar: true),
                    tituloVacio: 'Sin promociones',
                    mensajeVacio:
                        'Publica la primera promoción desde el creador.',
                    iconoVacio: Icons.card_giftcard,
                    skeletons: 2,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final promocion in provider.promociones)
                          _FilaPromocion(promocion: promocion),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipNegocio extends StatelessWidget {
  const _ChipNegocio({required this.nombre, required this.onQuitar});

  final String nombre;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 14,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.primarySoftBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              nombre,
              style: AppTextStyles.labelStrong.copyWith(
                color: AppColors.primaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: onQuitar,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAnadirNegocio extends StatelessWidget {
  const _BotonAnadirNegocio({
    required this.disponibles,
    required this.onAnadir,
  });

  final List<String> disponibles;
  final ValueChanged<String> onAnadir;

  @override
  Widget build(BuildContext context) {
    if (disponibles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceNeutral,
          borderRadius: AppRadius.chip,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          'Todos incluidos',
          style: AppTextStyles.labelStrong.copyWith(
            color: AppColors.textDisabled,
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Añadir negocio',
      onSelected: onAnadir,
      color: AppColors.surface,
      itemBuilder: (context) => [
        for (final nombre in disponibles)
          PopupMenuItem<String>(value: nombre, child: Text(nombre)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.chip,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          '+ Añadir',
          style: AppTextStyles.labelStrong.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _BannerPreview extends StatelessWidget {
  const _BannerPreview({required this.titulo, required this.detalle});

  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.panel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.22),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              'SOLO ESTA SEMANA',
              style: AppTextStyles.badge.copyWith(
                color: AppColors.textOnPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            titulo.isEmpty ? 'Título de la promoción' : titulo,
            style: AppTextStyles.panelTitle.copyWith(
              color: AppColors.textOnPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            detalle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilaPromocion extends StatelessWidget {
  const _FilaPromocion({required this.promocion});

  final Promocion promocion;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PromocionesProvider>();
    final activa =
        promocion.estado == EstadoPromocion.activa ||
        promocion.estado == EstadoPromocion.terminaHoy;

    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          promocion.titulo,
          style: AppTextStyles.bodySmallStrong,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          promocion.alcance,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final insignia = AppBadge(
      label: promocion.estado.etiqueta,
      tone: switch (promocion.estado) {
        EstadoPromocion.activa => AppBadgeTone.ok,
        EstadoPromocion.terminaHoy => AppBadgeTone.amber,
        EstadoPromocion.borrador => AppBadgeTone.neutral,
        EstadoPromocion.finalizada => AppBadgeTone.neutral,
      },
      dense: true,
    );

    final boton = AppTextActionButton(
      label: 'Finalizar',
      height: 34,
      color: AppColors.dangerText,
      onPressed: () async {
        final ok = await provider.finalizar(promocion.id);
        if (!context.mounted) return;
        mostrarAviso(
          context,
          ok
              ? '«${promocion.titulo}» finalizada.'
              : provider.error ?? 'No se pudo finalizar la promoción.',
          exito: ok,
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Con poco ancho, la insignia y la acción bajan a su propia línea
          // en lugar de comprimir el título.
          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                textos,
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [insignia, if (activa) boton],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: textos),
              const SizedBox(width: AppSpacing.sm),
              insignia,
              if (activa) ...[const SizedBox(width: AppSpacing.sm), boton],
            ],
          );
        },
      ),
    );
  }
}
