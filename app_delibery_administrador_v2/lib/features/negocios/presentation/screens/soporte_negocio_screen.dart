import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/estado_negocio.dart';
import '../../../../core/models/estado_pedido.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/no_encontrado_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../../../pedidos/providers/pedidos_provider.dart';
import '../../../promociones/providers/promociones_provider.dart';
import '../../data/models/negocio.dart';
import '../../providers/negocios_provider.dart';
import '../widgets/hojas_soporte.dart';

/// Frame 08 · Soporte al negocio.
///
/// Permite operar en nombre del comerciante: editar productos y horario,
/// ajustar la comisión, crear una promoción y asignar o reasignar el
/// repartidor de sus pedidos activos.
class SoporteNegocioScreen extends StatefulWidget {
  const SoporteNegocioScreen({super.key, required this.negocioId});

  final String negocioId;

  @override
  State<SoporteNegocioScreen> createState() => _SoporteNegocioScreenState();
}

class _SoporteNegocioScreenState extends State<SoporteNegocioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NegociosProvider>().cargar();
      context.read<PedidosProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<NegociosProvider>();
    final negocio = provider.porId(widget.negocioId);

    if (!provider.cargando && !provider.hayError && negocio == null) {
      return NoEncontradoScreen(
        ruta: AppRoutes.aSoporteNegocio(widget.negocioId),
        mensaje:
            'El negocio ${widget.negocioId} ya no está afiliado a DelyPuno.',
      );
    }

    return AdminScreen(
      titulo: negocio?.nombre ?? 'Soporte al negocio',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: VistaAsync(
        cargando: provider.cargando,
        error: provider.error,
        vacio: negocio == null,
        onReintentar: () => provider.cargar(forzar: true),
        tituloVacio: 'Soporte no disponible',
        mensajeVacio: 'No se pudo cargar la ficha de soporte de este negocio.',
        skeletons: 4,
        builder: (context) => _Contenido(negocio: negocio!),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.negocio});

  final Negocio negocio;

  Future<void> _forzarCierre(BuildContext context) async {
    final abierto = negocio.estado.atiende;
    final motivo = await mostrarConfirmacion(
      context,
      titulo: abierto
          ? '¿Forzar el cierre de ${negocio.nombre}?'
          : '¿Forzar la apertura de ${negocio.nombre}?',
      mensaje: abierto
          ? 'Dejará de recibir pedidos nuevos hasta que el comerciante lo '
                'reabra o lo reabras tú desde aquí.'
          : 'Volverá a recibir pedidos de inmediato aunque el comerciante no '
                'lo haya abierto.',
      etiquetaConfirmar: abierto ? 'Forzar cierre' : 'Forzar apertura',
      destructiva: abierto,
      pedirMotivo: true,
    );
    if (motivo == null || !context.mounted) return;

    final provider = context.read<NegociosProvider>();
    final ok = await provider.forzarEstado(
      negocioId: negocio.id,
      estado: abierto ? EstadoNegocio.cerrado : EstadoNegocio.abierto,
    );
    if (!context.mounted) return;
    mostrarAviso(
      context,
      ok
          ? '${negocio.nombre} quedó ${abierto ? 'cerrado' : 'abierto'} · '
                '«$motivo».'
          : provider.error ?? 'No se pudo cambiar el estado del negocio.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.watch<PedidosProvider>();
    final activos = [
      for (final p in pedidosProvider.pedidos)
        if (p.negocio == negocio.nombre && p.estado.estaActivo) p,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: IconButton(
                tooltip: 'Volver a negocios',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRoutes.negocios),
              ),
            ),
            Expanded(
              child: AdminPageHeader(
                migaDePan: 'Negocios / ${negocio.nombre}',
                titulo: 'Soporte al negocio',
                acciones: [
                  AppTextActionButton(
                    label: 'Chat con el negocio',
                    onPressed: () => mostrarAviso(
                      context,
                      'Chat abierto con ${negocio.nombre}.',
                    ),
                  ),
                  AppTextActionButton(
                    label: negocio.estado.atiende
                        ? 'Forzar cierre'
                        : 'Forzar apertura',
                    color: AppColors.dangerText,
                    onPressed: () => _forzarCierre(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (negocio.incidenciasAbiertas > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppBadge(
              label: '${negocio.incidenciasAbiertas} INCIDENCIAS ABIERTAS',
              tone: AppBadgeTone.dangerStrong,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AdminTwoColumns(
          flexIzquierda: 11,
          flexDerecha: 10,
          izquierda: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Productos(negocio: negocio),
              const SizedBox(height: AppSpacing.gridGap),
              _HorarioYComision(negocio: negocio),
            ],
          ),
          derecha: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PedidosActivos(negocio: negocio, pedidos: activos),
              const SizedBox(height: AppSpacing.gridGap),
              _HistorialIncidencias(negocio: negocio),
            ],
          ),
        ),
      ],
    );
  }
}

class _Productos extends StatelessWidget {
  const _Productos({required this.negocio});

  final Negocio negocio;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NegociosProvider>();

    return AppSectionCard(
      title: 'Productos y precios',
      subtitle: 'Editando en nombre del negocio',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (negocio.productos.isEmpty)
            Text(
              'Este negocio todavía no cargó su catálogo.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            for (final producto in negocio.productos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    AppEmojiTile(emoji: producto.emoji, size: 36),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            producto.nombre,
                            style: AppTextStyles.bodySmallStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            producto.disponibilidadTexto,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: producto.disponible
                                  ? AppColors.successText
                                  : AppColors.dangerText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(producto.precioTexto, style: AppTextStyles.amount),
                    const SizedBox(width: AppSpacing.md),
                    AppTextActionButton(
                      label: 'Editar',
                      height: 34,
                      onPressed: () => mostrarHoja<void>(
                        context,
                        builder: (_) =>
                            ChangeNotifierProvider<NegociosProvider>.value(
                              value: provider,
                              child: HojaEditarProducto(
                                negocioId: negocio.id,
                                producto: producto,
                              ),
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

class _HorarioYComision extends StatelessWidget {
  const _HorarioYComision({required this.negocio});

  final Negocio negocio;

  @override
  Widget build(BuildContext context) {
    final negociosProvider = context.read<NegociosProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionCard(
          title: 'Horario y disponibilidad',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSettingRow(
                title: 'Atención',
                subtitle: 'Horario visible en la app del cliente',
                value: negocio.horario,
                onEdit: () => mostrarHoja<void>(
                  context,
                  builder: (_) =>
                      ChangeNotifierProvider<NegociosProvider>.value(
                        value: negociosProvider,
                        child: HojaAjustarHorario(negocio: negocio),
                      ),
                ),
              ),
              const Divider(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Forzar apertura / cierre',
                          style: AppTextStyles.bodySmallStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Si el comerciante no puede hacerlo',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  AppBadge(
                    label: negocio.estado.etiqueta,
                    tone: negocio.estado.atiende
                        ? AppBadgeTone.ok
                        : AppBadgeTone.neutral,
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AppSectionCard(
          title: 'Comisión y promociones',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSettingRow(
                title: 'Comisión actual',
                subtitle: negocio.comisionPreferente
                    ? 'Categoría con margen bajo'
                    : 'Acuerdo estándar',
                value: '${negocio.comision}%',
                onEdit: () => mostrarHoja<void>(
                  context,
                  builder: (_) =>
                      ChangeNotifierProvider<NegociosProvider>.value(
                        value: negociosProvider,
                        child: HojaAjustarComision(negocio: negocio),
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.secondary(
                label: 'Crear promoción para este negocio',
                expand: true,
                height: 44,
                onPressed: () {
                  context.read<PromocionesProvider>()
                    ..cargar()
                    ..agregarNegocio(negocio.nombre);
                  context.go(AppRoutes.promociones);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PedidosActivos extends StatelessWidget {
  const _PedidosActivos({required this.negocio, required this.pedidos});

  final Negocio negocio;
  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Pedidos activos y repartidor',
      trailing: Text(
        '${negocio.pedidosPendientes} pendientes',
        style: AppTextStyles.labelStrong.copyWith(color: AppColors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pedidos.isEmpty)
            Text(
              'Este negocio no tiene pedidos en curso ahora mismo.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            for (final pedido in pedidos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    SizedBox(
                      width: 68,
                      child: Text(
                        pedido.id,
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        pedido.tieneRepartidor
                            ? '${pedido.repartidor} lleva'
                            : pedido.cliente,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBadge.pedido(pedido.estado, corta: true, dense: true),
                    const SizedBox(width: AppSpacing.sm),
                    AppTextActionButton(
                      label: pedido.tieneRepartidor ? 'Reasignar' : 'Asignar',
                      height: 34,
                      color: pedido.estado == EstadoPedido.problema
                          ? AppColors.dangerText
                          : AppColors.primary,
                      onPressed: pedido.estado.admiteReasignacion
                          ? () => context.push(AppRoutes.aReasignar(pedido.id))
                          : null,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _HistorialIncidencias extends StatelessWidget {
  const _HistorialIncidencias({required this.negocio});

  final Negocio negocio;

  Future<void> _resolver(BuildContext context, Incidencia incidencia) async {
    final provider = context.read<NegociosProvider>();
    final ok = await provider.resolverIncidencia(
      negocioId: negocio.id,
      incidenciaId: incidencia.id,
    );
    if (!context.mounted) return;
    mostrarAviso(
      context,
      ok
          ? 'Incidencia «${incidencia.titulo}» marcada como resuelta.'
          : provider.error ?? 'No se pudo resolver la incidencia.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Historial de incidencias',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (negocio.incidencias.isEmpty)
            Text(
              'Este negocio no tiene incidencias registradas.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            for (final incidencia in negocio.incidencias)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            incidencia.titulo,
                            style: AppTextStyles.bodySmallStrong,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${incidencia.detalle} · '
                            '${incidencia.estado.etiqueta}',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (incidencia.estado == EstadoIncidencia.resuelta)
                      AppBadge(
                        label: 'RESUELTA',
                        tone: AppBadgeTone.success,
                        dense: true,
                      )
                    else
                      AppTextActionButton(
                        label: 'Resolver',
                        height: 34,
                        onPressed: () => _resolver(context, incidencia),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
