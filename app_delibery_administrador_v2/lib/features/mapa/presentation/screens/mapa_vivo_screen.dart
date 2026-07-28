import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/estado_pedido.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_mapa.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../../../pedidos/providers/pedidos_provider.dart';
import '../../../repartidores/providers/repartidores_provider.dart';

/// Frame 03 · Mapa en vivo.
///
/// Centro de monitoreo: mapa a pantalla completa con marcadores por color y
/// panel lateral con el pedido seleccionado y los otros pedidos de la zona.
class MapaVivoScreen extends StatefulWidget {
  const MapaVivoScreen({super.key});

  @override
  State<MapaVivoScreen> createState() => _MapaVivoScreenState();
}

class _MapaVivoScreenState extends State<MapaVivoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PedidosProvider>().cargar();
      context.read<RepartidoresProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final pedidos = context.watch<PedidosProvider>();
    final repartidores = context.watch<RepartidoresProvider>();
    final mapa = context.watch<MapaProvider>();
    final compacta = AdminScreen.esCompacta(context);

    final activos = pedidos.pedidosActivos;
    final seleccionado = mapa.resolverSeleccionado(activos);
    final enLinea = repartidores.conectados;

    return AdminScreen(
      titulo: 'Mapa en vivo',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      desplazable: false,
      child: VistaAsync(
        cargando: pedidos.cargando,
        error: pedidos.error,
        vacio: activos.isEmpty,
        onReintentar: () => pedidos.cargar(forzar: true),
        tituloVacio: 'No hay pedidos en curso',
        mensajeVacio:
            'Cuando entre un pedido aparecerá aquí con su ruta en vivo.',
        iconoVacio: Icons.map_outlined,
        builder: (context) {
          final panel = _PanelPedido(
            pedido: seleccionado,
            otros: [
              for (final p in activos)
                if (p.id != seleccionado?.id) p,
            ],
            onSeleccionar: mapa.seleccionar,
          );

          final lienzo = _Lienzo(
            pedidos: activos,
            seleccionado: seleccionado,
            enLinea: enLinea,
            filtro: mapa.filtro,
            onFiltro: mapa.cambiarFiltro,
            onSeleccionar: mapa.seleccionar,
          );

          if (compacta) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 340, child: lienzo),
                  const SizedBox(height: AppSpacing.gridGap),
                  panel,
                ],
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: lienzo,
                ),
              ),
              SizedBox(
                width: AppSizes.mapPanelWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      left: BorderSide(color: AppColors.borderStrong),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: panel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Lienzo extends StatelessWidget {
  const _Lienzo({
    required this.pedidos,
    required this.seleccionado,
    required this.enLinea,
    required this.filtro,
    required this.onFiltro,
    required this.onSeleccionar,
  });

  final List<Pedido> pedidos;
  final Pedido? seleccionado;
  final int enLinea;
  final FiltroMapa filtro;
  final ValueChanged<FiltroMapa> onFiltro;
  final ValueChanged<String> onSeleccionar;

  /// Reparte los pedidos por el lienzo de forma estable: el mismo pedido cae
  /// siempre en el mismo punto, sin depender de datos de geolocalización que
  /// el diseño no define.
  List<MarcadorMapa> _marcadores() {
    const posiciones = [
      Offset(0.22, 0.62),
      Offset(0.55, 0.3),
      Offset(0.74, 0.52),
      Offset(0.36, 0.82),
      Offset(0.63, 0.72),
      Offset(0.44, 0.44),
      Offset(0.83, 0.28),
      Offset(0.16, 0.36),
    ];

    return [
      for (var i = 0; i < pedidos.length; i++)
        if (filtro.aceptar(pedidos[i]))
          MarcadorMapa(
            x: posiciones[i % posiciones.length].dx,
            y: posiciones[i % posiciones.length].dy,
            tipo: _tipo(pedidos[i]),
            pulsante: pedidos[i].id == seleccionado?.id,
            etiqueta:
                '${pedidos[i].id} · ${pedidos[i].negocio} '
                '(${pedidos[i].estado.etiquetaCorta})',
            onTap: () => onSeleccionar(pedidos[i].id),
          ),
    ];
  }

  static TipoMarcador _tipo(Pedido pedido) {
    if (pedido.estado == EstadoPedido.problema) return TipoMarcador.problema;
    if (pedido.tieneRepartidor) return TipoMarcador.repartidor;
    if (pedido.estado == EstadoPedido.buscandoRepartidor) {
      return TipoMarcador.cliente;
    }
    return TipoMarcador.negocio;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AppMapaCanvas(
            alto: 0,
            expandido: true,
            marcadores: _marcadores(),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.control,
                  boxShadow: AppColors.floatingShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Mapa en vivo',
                        style: AppTextStyles.screenTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const AppLiveDot(),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        '$enLinea repartidores en línea',
                        style: AppTextStyles.labelStrong.copyWith(
                          color: AppColors.successText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final f in FiltroMapa.values)
                    AppFilterChip(
                      label: f.etiqueta,
                      selected: filtro == f,
                      onTap: () => onFiltro(f),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.control,
              boxShadow: AppColors.floatingShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Marcadores',
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final tipo in TipoMarcador.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: tipo.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(_leyenda(tipo), style: AppTextStyles.labelStrong),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _leyenda(TipoMarcador tipo) => switch (tipo) {
    TipoMarcador.repartidor => 'Repartidor en ruta',
    TipoMarcador.negocio => 'Negocio abierto',
    TipoMarcador.cliente => 'Cliente esperando',
    TipoMarcador.problema => 'Pedido con problema',
  };
}

class _PanelPedido extends StatelessWidget {
  const _PanelPedido({
    required this.pedido,
    required this.otros,
    required this.onSeleccionar,
  });

  final Pedido? pedido;
  final List<Pedido> otros;
  final ValueChanged<String> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final seleccionado = pedido;
    if (seleccionado == null) {
      return AppCard(
        child: Text(
          'Selecciona un marcador del mapa para ver el pedido.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pedido seleccionado',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppBadge.pedido(seleccionado.estado, dense: true),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                seleccionado.id,
                style: AppTextStyles.screenTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              seleccionado.montoTexto,
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${seleccionado.negocio} → ${seleccionado.cliente}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _Metrica(
              titulo: 'Tiempo',
              valor: seleccionado.tiempoMinutos == null
                  ? '—'
                  : '${seleccionado.tiempoMinutos} min',
            ),
            _Metrica(
              titulo: 'Distancia',
              valor: seleccionado.distanciaKm == null
                  ? '—'
                  : '${seleccionado.distanciaKm!.toStringAsFixed(1)} km',
            ),
            _Metrica(
              titulo: 'ETA',
              valor: seleccionado.etaMinutos == null
                  ? '—'
                  : '${seleccionado.etaMinutos} min',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              if (seleccionado.tieneRepartidor)
                AppAvatar(nombre: seleccionado.repartidor!, online: true)
              else
                const AppIconTile(
                  icon: Icons.person_search_outlined,
                  color: AppColors.textMuted,
                  background: AppColors.surfaceNeutral,
                  size: AppSizes.avatarMd,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seleccionado.repartidor ?? 'Sin asignar',
                      style: AppTextStyles.bodySmallStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _detalleRepartidor(context, seleccionado),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
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
        const SizedBox(height: AppSpacing.md),
        AppButton.primary(
          label: seleccionado.tieneRepartidor ? 'Reasignar' : 'Asignar',
          expand: true,
          height: 44,
          onPressed: seleccionado.estado.admiteReasignacion
              ? () => context.push(AppRoutes.aReasignar(seleccionado.id))
              : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Otros pedidos en la zona', style: AppTextStyles.cardTitle),
        const SizedBox(height: AppSpacing.md),
        if (otros.isEmpty)
          Text(
            'No hay más pedidos en curso ahora mismo.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        else
          for (final otro in otros)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => onSeleccionar(otro.id),
                borderRadius: AppRadius.control,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: otro.estado == EstadoPedido.problema
                          ? AppColors.dangerSoftBorder
                          : AppColors.border,
                    ),
                    borderRadius: AppRadius.control,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${otro.id} · ${otro.negocio}',
                              style: AppTextStyles.bodySmallStrong,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _resumen(otro),
                              style: AppTextStyles.captionSmall.copyWith(
                                color: otro.estado == EstadoPedido.problema
                                    ? AppColors.dangerText
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(otro.montoTexto, style: AppTextStyles.amount),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  static String _resumen(Pedido pedido) {
    if (pedido.estado == EstadoPedido.problema) return 'Problema reportado';
    final minutos = pedido.tiempoMinutos;
    final estado = pedido.estado.etiqueta.toLowerCase();
    final capitalizado = '${estado[0].toUpperCase()}${estado.substring(1)}';
    return minutos == null ? capitalizado : '$capitalizado · $minutos min';
  }

  static String _detalleRepartidor(BuildContext context, Pedido pedido) {
    if (!pedido.tieneRepartidor) return 'Buscando repartidor en la zona';
    final repartidor = context.read<RepartidoresProvider>().porId(
      pedido.repartidorId ?? '',
    );
    final calificacion =
        repartidor?.calificacion ?? pedido.repartidorCalificacion;
    final activos = repartidor?.pedidosActivos;
    final partes = <String>[
      if (calificacion != null) '★ ${calificacion.toStringAsFixed(1)}',
      if (activos != null)
        activos == 1 ? '1 pedido activo' : '$activos pedidos activos',
    ];
    return partes.isEmpty ? 'Asignado' : partes.join(' · ');
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            valor,
            style: AppTextStyles.cardTitleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
