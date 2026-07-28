import 'package:flutter/material.dart';

import '../data/dely_mock_store.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_avatar.dart';
import 'app_badge.dart';
import 'app_buttons.dart';
import 'app_fields.dart';

/// Un ítem de la barra lateral del diseño (`AdminSidebar.dc.html`).
class DestinoAdmin {
  const DestinoAdmin({
    required this.etiqueta,
    required this.icono,
    required this.ruta,
  });

  final String etiqueta;
  final IconData icono;
  final String ruta;

  /// Los diez destinos, en el orden exacto de la barra lateral.
  static const List<DestinoAdmin> todos = [
    DestinoAdmin(
      etiqueta: 'Dashboard',
      icono: Icons.dashboard_outlined,
      ruta: AppRoutes.dashboard,
    ),
    DestinoAdmin(
      etiqueta: 'Pedidos',
      icono: Icons.shopping_bag_outlined,
      ruta: AppRoutes.pedidos,
    ),
    DestinoAdmin(
      etiqueta: 'Mapa en vivo',
      icono: Icons.map_outlined,
      ruta: AppRoutes.mapa,
    ),
    DestinoAdmin(
      etiqueta: 'Repartidores',
      icono: Icons.two_wheeler_outlined,
      ruta: AppRoutes.repartidores,
    ),
    DestinoAdmin(
      etiqueta: 'Negocios',
      icono: Icons.storefront_outlined,
      ruta: AppRoutes.negocios,
    ),
    DestinoAdmin(
      etiqueta: 'Clientes',
      icono: Icons.person_outline,
      ruta: AppRoutes.clientes,
    ),
    DestinoAdmin(
      etiqueta: 'Promociones',
      icono: Icons.card_giftcard,
      ruta: AppRoutes.promociones,
    ),
    DestinoAdmin(
      etiqueta: 'Reportes',
      icono: Icons.bar_chart_rounded,
      ruta: AppRoutes.reportes,
    ),
    DestinoAdmin(
      etiqueta: 'Pagos',
      icono: Icons.credit_card,
      ruta: AppRoutes.pagos,
    ),
    DestinoAdmin(
      etiqueta: 'Configuración',
      icono: Icons.settings_outlined,
      ruta: AppRoutes.configuracion,
    ),
  ];
}

/// Logotipo de DelyPuno Operaciones sobre el degradado de marca.
class AdminLogo extends StatelessWidget {
  const AdminLogo({super.key, this.size = AppSizes.avatarLg});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: AppColors.logoShadow,
      ),
      child: Icon(
        Icons.delivery_dining,
        size: size * 0.58,
        color: AppColors.textOnPrimary,
      ),
    );
  }
}

/// Barra lateral persistente del panel.
///
/// Es el mismo widget en escritorio (columna fija de 260 px) y en pantallas
/// estrechas (contenido del `Drawer`), de modo que la navegación y el estado
/// activo no se duplican.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.indiceActivo,
    required this.onDestino,
    this.pedidosActivos = 0,
    this.documentosPorVerificar = 0,
  });

  final int indiceActivo;
  final ValueChanged<int> onDestino;
  final int pedidosActivos;
  final int documentosPorVerificar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.borderStrong)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: 22,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const AdminLogo(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DelyPuno',
                          style: AppTextStyles.cardTitle.copyWith(height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'OPERACIONES',
                          style: AppTextStyles.captionStrong.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                itemCount: DestinoAdmin.todos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 3),
                itemBuilder: (context, indice) {
                  final destino = DestinoAdmin.todos[indice];
                  return _ItemNavegacion(
                    destino: destino,
                    activo: indice == indiceActivo,
                    contador: switch (indice) {
                      1 when pedidosActivos > 0 => AppCounterBadge(
                        value: pedidosActivos,
                      ),
                      3 when documentosPorVerificar > 0 => AppCounterBadge(
                        value: documentosPorVerificar,
                        tone: AppBadgeTone.amber,
                      ),
                      _ => null,
                    },
                    onTap: () => onDestino(indice),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.18),
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Text(
                      'Sistema operativo · ${DelyMockStore.versionSistema}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

class _ItemNavegacion extends StatelessWidget {
  const _ItemNavegacion({
    required this.destino,
    required this.activo,
    required this.onTap,
    this.contador,
  });

  final DestinoAdmin destino;
  final bool activo;
  final VoidCallback onTap;
  final Widget? contador;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? AppColors.primarySoft : Colors.transparent,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.control,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              Icon(
                destino.icono,
                size: 20,
                color: activo ? AppColors.primaryDark : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  destino.etiqueta,
                  style: activo
                      ? AppTextStyles.navActive.copyWith(
                          color: AppColors.primaryDark,
                        )
                      : AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?contador,
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra superior del panel: buscador, fecha, notificaciones y operador.
///
/// En pantallas estrechas oculta el buscador y la ficha del operador para
/// dejar sitio al título, y añade el botón del menú lateral.
class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.hintBusqueda,
    required this.onBuscar,
    required this.nombreOperador,
    required this.rolOperador,
    this.titulo,
    this.onMenu,
    this.onNotificaciones,
    this.onPerfil,
  });

  final String hintBusqueda;
  final ValueChanged<String> onBuscar;
  final String nombreOperador;
  final String rolOperador;

  /// Se muestra en lugar del buscador cuando no cabe.
  final String? titulo;

  final VoidCallback? onMenu;
  final VoidCallback? onNotificaciones;
  final VoidCallback? onPerfil;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacta = constraints.maxWidth < AppSizes.sidebarBreakpoint;
        final muyCompacta = constraints.maxWidth < AppSizes.compactBreakpoint;

        return Container(
          height: AppSizes.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
          ),
          child: Row(
            children: [
              if (onMenu != null) ...[
                AppIconButton(
                  icon: Icons.menu,
                  tooltip: 'Abrir menú',
                  onPressed: onMenu,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (compacta)
                Expanded(
                  child: Text(
                    titulo ?? 'DelyPuno Operaciones',
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Expanded(
                  child: AppSearchField(
                    hint: hintBusqueda,
                    onChanged: onBuscar,
                  ),
                ),
              const SizedBox(width: AppSpacing.lg),
              if (!muyCompacta) ...[
                RichText(
                  text: TextSpan(
                    text: '${DelyMockStore.fechaPanel} · ',
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: DelyMockStore.horaPanel,
                        style: AppTextStyles.bodyStrong,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.cardPaddingTight),
              ],
              AppIconButton(
                icon: Icons.notifications_none,
                tooltip: 'Notificaciones',
                showDot: true,
                onPressed: onNotificaciones,
              ),
              const SizedBox(width: AppSpacing.cardPaddingTight),
              InkWell(
                onTap: onPerfil,
                borderRadius: AppRadius.control,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAvatar(nombre: nombreOperador),
                      if (!compacta) ...[
                        const SizedBox(width: AppSpacing.sm + 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nombreOperador,
                                style: AppTextStyles.amount,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                rolOperador,
                                style: AppTextStyles.captionMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Encabezado de contenido: miga de pan, título y acciones a la derecha.
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.titulo,
    this.migaDePan,
    this.subtitulo,
    this.acciones = const [],
  });

  final String titulo;

  /// «Inicio / Pedidos».
  final String? migaDePan;

  /// Texto a la derecha del título («42 activos · 186 hoy»).
  final String? subtitulo;

  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacta = constraints.maxWidth < AppSizes.compactBreakpoint;
        final titulos = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (migaDePan != null)
              Text(
                migaDePan!,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              titulo,
              style: AppTextStyles.pageTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitulo!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );

        if (compacta) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titulos,
              if (acciones.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm + 2,
                  runSpacing: AppSpacing.sm,
                  children: acciones,
                ),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titulos),
            if (acciones.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm + 2,
                runSpacing: AppSpacing.sm,
                children: acciones,
              ),
            ],
          ],
        );
      },
    );
  }
}
