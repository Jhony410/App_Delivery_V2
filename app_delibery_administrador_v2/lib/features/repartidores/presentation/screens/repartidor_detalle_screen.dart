import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import '../../../../core/widgets/app_charts.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_mapa.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../../../pedidos/providers/pedidos_provider.dart';
import '../../data/models/repartidor.dart';
import '../../providers/repartidores_provider.dart';
import 'repartidores_screen.dart' show tonoDeRepartidor;

/// Frame 05 · Ficha de repartidor.
///
/// Perfil, actividad en vivo, verificación de los cinco documentos de
/// CHASQUI, desempeño, comentarios, heatmap de zonas e historial de pedidos.
class RepartidorDetalleScreen extends StatefulWidget {
  const RepartidorDetalleScreen({super.key, required this.repartidorId});

  final String repartidorId;

  @override
  State<RepartidorDetalleScreen> createState() =>
      _RepartidorDetalleScreenState();
}

class _RepartidorDetalleScreenState extends State<RepartidorDetalleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RepartidoresProvider>().cargar();
      context.read<PedidosProvider>().cargar();
    });
  }

  Future<void> _accion({
    required String titulo,
    required String mensaje,
    required String etiqueta,
    required Future<bool> Function(String motivo) accion,
  }) async {
    final motivo = await mostrarConfirmacion(
      context,
      titulo: titulo,
      mensaje: mensaje,
      etiquetaConfirmar: etiqueta,
      pedirMotivo: true,
    );
    if (motivo == null || !mounted) return;
    final ok = await accion(motivo);
    if (!mounted) return;
    mostrarAviso(
      context,
      ok
          ? '$etiqueta aplicado. Se notificó en CHASQUI.'
          : context.read<RepartidoresProvider>().error ??
                'No se pudo completar la acción.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<RepartidoresProvider>();
    final repartidor = provider.porId(widget.repartidorId);

    if (!provider.cargando && !provider.hayError && repartidor == null) {
      return NoEncontradoScreen(
        ruta: AppRoutes.aFichaRepartidor(widget.repartidorId),
        mensaje:
            'El repartidor ${widget.repartidorId} ya no figura en CHASQUI. '
            'Puede que se haya dado de baja.',
      );
    }

    return AdminScreen(
      titulo: repartidor?.nombre ?? 'Ficha del repartidor',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: VistaAsync(
        cargando: provider.cargando,
        error: provider.error,
        vacio: repartidor == null,
        onReintentar: () => provider.cargar(forzar: true),
        tituloVacio: 'Ficha no disponible',
        mensajeVacio: 'No se pudo cargar la ficha de este repartidor.',
        skeletons: 4,
        builder: (context) =>
            _Contenido(repartidor: repartidor!, onAccion: _accion),
      ),
    );
  }
}

typedef _AccionFicha =
    Future<void> Function({
      required String titulo,
      required String mensaje,
      required String etiqueta,
      required Future<bool> Function(String motivo) accion,
    });

class _Contenido extends StatelessWidget {
  const _Contenido({required this.repartidor, required this.onAccion});

  final Repartidor repartidor;
  final _AccionFicha onAccion;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RepartidoresProvider>();
    final pedidos = context.watch<PedidosProvider>();
    final historial = [
      for (final p in pedidos.pedidos)
        if (p.repartidorId == repartidor.id) p,
    ];
    final enCurso = [
      for (final p in historial)
        if (p.estado.estaActivo) p,
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
                tooltip: 'Volver al listado',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRoutes.repartidores),
              ),
            ),
            Expanded(
              child: AdminPageHeader(
                migaDePan: 'Repartidores / ${repartidor.nombre}',
                titulo: 'Ficha del repartidor',
                acciones: [
                  AppTextActionButton(
                    label: repartidor.suspendido ? 'Suspendido' : 'Suspender',
                    color: AppColors.warning,
                    onPressed: repartidor.suspendido
                        ? null
                        : () => onAccion(
                            titulo: '¿Suspender a ${repartidor.nombre}?',
                            mensaje:
                                'No recibirá pedidos hasta que lo reactives. '
                                'Se le notificará en CHASQUI.',
                            etiqueta: 'Suspender',
                            accion: (motivo) => provider.suspender(
                              repartidorId: repartidor.id,
                              motivo: motivo,
                            ),
                          ),
                  ),
                  AppTextActionButton(
                    label: repartidor.bloqueado ? 'Bloqueado' : 'Bloquear',
                    color: AppColors.dangerText,
                    onPressed: repartidor.bloqueado
                        ? null
                        : () => onAccion(
                            titulo: '¿Bloquear a ${repartidor.nombre}?',
                            mensaje:
                                'Perderá el acceso a CHASQUI de forma '
                                'indefinida y se cancelarán sus pedidos '
                                'pendientes.',
                            etiqueta: 'Bloquear',
                            accion: (motivo) => provider.bloquear(
                              repartidorId: repartidor.id,
                              motivo: motivo,
                            ),
                          ),
                  ),
                  AppTextActionButton(
                    label: 'Contactar',
                    onPressed: () => mostrarAviso(
                      context,
                      'Llamando a ${repartidor.nombre} · '
                      '${repartidor.celular ?? 'sin celular registrado'}.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AdminTwoColumns(
          flexIzquierda: 11,
          flexDerecha: 10,
          izquierda: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TarjetaPerfil(repartidor: repartidor),
              const SizedBox(height: AppSpacing.gridGap),
              _ActividadEnVivo(repartidor: repartidor, enCurso: enCurso),
              const SizedBox(height: AppSpacing.gridGap),
              _Documentos(repartidor: repartidor),
            ],
          ),
          derecha: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Desempeno(repartidor: repartidor),
              const SizedBox(height: AppSpacing.gridGap),
              _Zonas(repartidor: repartidor),
              const SizedBox(height: AppSpacing.gridGap),
              _HistorialPedidos(pedidos: historial),
              const SizedBox(height: AppSpacing.gridGap),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Llamar',
                      expand: true,
                      height: 44,
                      icon: Icons.call_outlined,
                      onPressed: () => mostrarAviso(
                        context,
                        'Llamando a ${repartidor.celular ?? repartidor.nombre}.',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: AppButton.neutral(
                      label: 'Chat',
                      expand: true,
                      height: 44,
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => mostrarAviso(
                        context,
                        'Chat de CHASQUI abierto con ${repartidor.nombre}.',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaPerfil extends StatelessWidget {
  const _TarjetaPerfil({required this.repartidor});

  final Repartidor repartidor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                nombre: repartidor.nombre,
                size: 72,
                online: repartidor.enLinea,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      repartidor.nombre,
                      style: AppTextStyles.panelTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Repartidor desde ${repartidor.desde ?? '—'}'
                      '${repartidor.dni == null ? '' : ' · DNI ${repartidor.dni}'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AppBadge(
                          label:
                              '${repartidor.calificacion.toStringAsFixed(1)}'
                              '${repartidor.nivel == null ? '' : ' · ${repartidor.nivel}'}',
                          tone: AppBadgeTone.amber,
                          dense: true,
                        ),
                        AppBadge(
                          label: repartidor.etiquetaEstado,
                          tone: repartidor.accesoRestringido
                              ? AppBadgeTone.danger
                              : tonoDeRepartidor(repartidor.estado),
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _DatoPerfil(titulo: 'Celular', valor: repartidor.celular ?? '—'),
              _DatoPerfil(titulo: 'Vehículo', valor: repartidor.vehiculoTexto),
              _DatoPerfil(
                titulo: 'Entregas',
                valor: '${repartidor.entregasTotales}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatoPerfil extends StatelessWidget {
  const _DatoPerfil({required this.titulo, required this.valor});

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
            style: AppTextStyles.bodySmallStrong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActividadEnVivo extends StatelessWidget {
  const _ActividadEnVivo({required this.repartidor, required this.enCurso});

  final Repartidor repartidor;
  final List<Pedido> enCurso;

  @override
  Widget build(BuildContext context) {
    final pedido = enCurso.isEmpty ? null : enCurso.first;

    return AppSectionCard(
      title: 'Actividad en vivo',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLiveDot(),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'En tiempo real',
            style: AppTextStyles.labelStrong.copyWith(
              color: AppColors.successText,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMapaCanvas(
            alto: 148,
            mostrarRuta: pedido != null,
            marcadores: [
              MarcadorMapa(
                x: 0.28,
                y: 0.74,
                tipo: TipoMarcador.repartidor,
                pulsante: repartidor.enLinea,
                etiqueta: repartidor.nombre,
              ),
              if (pedido != null)
                MarcadorMapa(
                  x: 0.71,
                  y: 0.31,
                  tipo: TipoMarcador.cliente,
                  etiqueta: pedido.cliente,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (pedido == null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                repartidor.enLinea
                    ? 'Conectado sin pedido asignado.'
                    : 'Desconectado de CHASQUI.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            InkWell(
              onTap: () => context.go(AppRoutes.aDetallePedido(pedido.id)),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    AppBadge(
                      label: pedido.id,
                      tone: AppBadgeTone.okStrong,
                      dense: true,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '${pedido.negocio} → ${pedido.cliente}',
                        style: AppTextStyles.bodySmallStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      pedido.etaMinutos == null
                          ? '—'
                          : 'ETA ${pedido.etaMinutos} min',
                      style: AppTextStyles.amount.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Documentos extends StatelessWidget {
  const _Documentos({required this.repartidor});

  final Repartidor repartidor;

  Future<void> _resolver(
    BuildContext context,
    DocumentoRepartidor documento,
    bool aprobado,
  ) async {
    final provider = context.read<RepartidoresProvider>();
    final ok = await provider.resolverDocumento(
      repartidorId: repartidor.id,
      tipoDocumento: documento.tipo,
      aprobado: aprobado,
    );
    if (!context.mounted) return;
    mostrarAviso(
      context,
      ok
          ? '${documento.tipo} ${aprobado ? 'aprobado' : 'rechazado'} para '
                '${repartidor.nombre}.'
          : provider.error ?? 'No se pudo actualizar el documento.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Verificación de documentos',
      trailing: Text(
        '${repartidor.documentosAprobados} de '
        '${repartidor.documentos.length} aprobados',
        style: AppTextStyles.labelStrong.copyWith(color: AppColors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final documento in repartidor.documentos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          documento.tipo,
                          style: AppTextStyles.bodySmallStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          documento.detalle,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (documento.estado == EstadoDocumento.enRevision)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppTextActionButton(
                          label: 'Aprobar',
                          height: 34,
                          onPressed: () => _resolver(context, documento, true),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        AppTextActionButton(
                          label: 'Rechazar',
                          height: 34,
                          color: AppColors.dangerText,
                          onPressed: () => _resolver(context, documento, false),
                        ),
                      ],
                    )
                  else
                    AppBadge(
                      label: documento.estado.etiqueta,
                      tone: switch (documento.estado) {
                        EstadoDocumento.aprobado => AppBadgeTone.success,
                        EstadoDocumento.porVencer => AppBadgeTone.amber,
                        EstadoDocumento.rechazado => AppBadgeTone.danger,
                        EstadoDocumento.enRevision => AppBadgeTone.neutral,
                      },
                      dense: true,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Desempeno extends StatelessWidget {
  const _Desempeno({required this.repartidor});

  final Repartidor repartidor;

  @override
  Widget build(BuildContext context) {
    final desempeno = repartidor.desempeno;

    return AppSectionCard(
      title: 'Desempeño',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (desempeno == null)
            Text(
              'Todavía no hay cifras de desempeño para este repartidor.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                _DatoPerfilCompacto(
                  titulo: 'Ganancia semana',
                  valor: 'S/ ${desempeno.gananciaSemana.toStringAsFixed(2)}',
                  color: AppColors.primary,
                ),
                _DatoPerfilCompacto(
                  titulo: 'Pedidos',
                  valor: '${desempeno.pedidos}',
                ),
                _DatoPerfilCompacto(
                  titulo: 'Aceptación',
                  valor: '${desempeno.aceptacion}%',
                ),
                _DatoPerfilCompacto(
                  titulo: 'Entrega prom.',
                  valor: '${desempeno.entregaPromedioMin} min',
                ),
              ],
            ),
          if (repartidor.comentarios.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Comentarios recientes', style: AppTextStyles.cardTitleSmall),
            const SizedBox(height: AppSpacing.md),
            for (final comentario in repartidor.comentarios)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < comentario.estrellas
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '«${comentario.texto}»',
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${comentario.autor} · ${comentario.cuando}',
                      style: AppTextStyles.captionSmall.copyWith(
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
    );
  }
}

class _DatoPerfilCompacto extends StatelessWidget {
  const _DatoPerfilCompacto({
    required this.titulo,
    required this.valor,
    this.color = AppColors.textPrimary,
  });

  final String titulo;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
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
            style: AppTextStyles.cardTitleSmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Zonas extends StatelessWidget {
  const _Zonas({required this.repartidor});

  final Repartidor repartidor;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Zonas donde se conecta',
      subtitle: 'Mini heatmap · últimos 30 días',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (repartidor.zonas.isEmpty)
            Text(
              'Sin registros de conexión en los últimos 30 días.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            for (final zona in repartidor.zonas)
              AppProgressRow(etiqueta: zona.zona, porcentaje: zona.porcentaje),
        ],
      ),
    );
  }
}

class _HistorialPedidos extends StatelessWidget {
  const _HistorialPedidos({required this.pedidos});

  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Historial de pedidos',
      actionLabel: 'Ver todo',
      onAction: () => context.go(AppRoutes.pedidos),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pedidos.isEmpty)
            Text(
              'Este repartidor todavía no tiene pedidos registrados.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            for (final pedido in pedidos)
              InkWell(
                onTap: () => context.go(AppRoutes.aDetallePedido(pedido.id)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 66,
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
                          pedido.negocio,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppBadge.pedido(pedido.estado, corta: true, dense: true),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
