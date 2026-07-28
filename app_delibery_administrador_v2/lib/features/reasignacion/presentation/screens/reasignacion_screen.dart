import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../../../pedidos/providers/pedidos_provider.dart';
import '../../../repartidores/data/models/repartidor.dart';
import '../../../repartidores/providers/repartidores_provider.dart';

/// Criterios de ordenación de los candidatos (frame 06).
enum CriterioCandidato {
  masCercanos('Más cercanos'),
  mejorCalificados('Mejor calificados'),
  sinCarga('Sin carga');

  const CriterioCandidato(this.etiqueta);

  final String etiqueta;
}

/// Frame 06 · Centro de reasignación.
///
/// Es un componente compartido: se abre igual desde Pedidos, desde el Mapa en
/// vivo y desde Soporte al negocio. Se monta como ruta modal sobre la
/// pantalla que la invoca, de modo que al cerrarla el operador vuelve
/// exactamente donde estaba.
class ReasignacionScreen extends StatefulWidget {
  const ReasignacionScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  State<ReasignacionScreen> createState() => _ReasignacionScreenState();
}

class _ReasignacionScreenState extends State<ReasignacionScreen> {
  CriterioCandidato _criterio = CriterioCandidato.masCercanos;
  String? _motivo;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PedidosProvider>().cargar();
      context.read<RepartidoresProvider>().cargar();
    });
  }

  void _cerrar() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.pedidos);
    }
  }

  Future<void> _asignar(Pedido pedido, Repartidor candidato) async {
    final motivo = _motivo;
    if (motivo == null) return;

    setState(() => _enviando = true);
    final pedidos = context.read<PedidosProvider>();
    final ok = await pedidos.reasignar(
      pedidoId: pedido.id,
      repartidorId: candidato.id,
      motivo: motivo,
    );
    if (!mounted) return;
    // La carga de trabajo de los repartidores cambió con la reasignación.
    await context.read<RepartidoresProvider>().refrescar();
    if (!mounted) return;

    setState(() => _enviando = false);
    _cerrar();
    mostrarAviso(
      context,
      ok
          ? '${pedido.id} reasignado a ${candidato.nombre} · «$motivo».'
          : pedidos.error ?? 'No se pudo reasignar el pedido.',
      exito: ok,
    );
  }

  List<Repartidor> _ordenar(List<Repartidor> candidatos) {
    final lista = [...candidatos];
    switch (_criterio) {
      case CriterioCandidato.masCercanos:
        lista.sort((a, b) => _distancia(a).km.compareTo(_distancia(b).km));
      case CriterioCandidato.mejorCalificados:
        lista.sort((a, b) => b.calificacion.compareTo(a.calificacion));
      case CriterioCandidato.sinCarga:
        lista.sort((a, b) => a.pedidosActivos.compareTo(b.pedidosActivos));
    }
    return lista;
  }

  static ({double km, int minutos, int aceptacion}) _distancia(
    Repartidor repartidor,
  ) =>
      DelyMockStore.distanciasReasignacion[repartidor.id] ??
      (km: 3.5, minutos: 18, aceptacion: 90);

  @override
  Widget build(BuildContext context) {
    final pedidos = context.watch<PedidosProvider>();
    final repartidores = context.watch<RepartidoresProvider>();
    final pedido = pedidos.porId(widget.pedidoId);
    final cargando = pedidos.cargando || repartidores.cargando;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 560,
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                clipBehavior: Clip.antiAlias,
                child: cargando
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: AppLoadingState(count: 2),
                      )
                    : pedido == null
                    ? _PedidoNoDisponible(
                        pedidoId: widget.pedidoId,
                        onCerrar: _cerrar,
                      )
                    : _Contenido(
                        pedido: pedido,
                        candidatos: _ordenar(
                          repartidores.candidatos(
                            excluirId: pedido.repartidorId,
                          ),
                        ),
                        criterio: _criterio,
                        motivo: _motivo,
                        enviando: _enviando,
                        distancia: _distancia,
                        onCriterio: (c) => setState(() => _criterio = c),
                        onMotivo: (m) => setState(() => _motivo = m),
                        onAsignar: (candidato) => _asignar(pedido, candidato),
                        onCerrar: _cerrar,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PedidoNoDisponible extends StatelessWidget {
  const _PedidoNoDisponible({required this.pedidoId, required this.onCerrar});

  final String pedidoId;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: AppColors.dangerText,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'El pedido $pedidoId ya no está en la operación',
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Puede haberse entregado o cancelado mientras abrías esta ventana.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.neutral(label: 'Cerrar', expand: true, onPressed: onCerrar),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.pedido,
    required this.candidatos,
    required this.criterio,
    required this.motivo,
    required this.enviando,
    required this.distancia,
    required this.onCriterio,
    required this.onMotivo,
    required this.onAsignar,
    required this.onCerrar,
  });

  final Pedido pedido;
  final List<Repartidor> candidatos;
  final CriterioCandidato criterio;
  final String? motivo;
  final bool enviando;
  final ({double km, int minutos, int aceptacion}) Function(Repartidor)
  distancia;
  final ValueChanged<CriterioCandidato> onCriterio;
  final ValueChanged<String?> onMotivo;
  final ValueChanged<Repartidor> onAsignar;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reasignar repartidor',
                      style: AppTextStyles.panelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Pedido ${pedido.id} · ${pedido.negocio} → '
                      '${pedido.cliente}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close),
                onPressed: onCerrar,
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: AppRadius.control,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: pedido.tieneRepartidor
                          ? 'Actualmente asignado a '
                          : 'Este pedido ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: pedido.repartidor ?? 'sigue sin repartidor',
                          style: AppTextStyles.bodySmallStrong,
                        ),
                        TextSpan(text: _carga(context)),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final c in CriterioCandidato.values)
                      AppFilterChip(
                        label: c.etiqueta,
                        selected: criterio == c,
                        onTap: () => onCriterio(c),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (candidatos.isEmpty)
                  AppEmptyState(
                    title: 'No hay repartidores disponibles',
                    message:
                        'Ninguno cumple las condiciones para tomar este '
                        'pedido ahora mismo.',
                    icon: Icons.person_search_outlined,
                  )
                else
                  for (var i = 0; i < candidatos.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    _TarjetaCandidato(
                      repartidor: candidatos[i],
                      destacado: i == 0,
                      metricas: distancia(candidatos[i]),
                      habilitado: motivo != null && !enviando,
                      onAsignar: () => onAsignar(candidatos[i]),
                    ),
                  ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Historial de reasignaciones',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final linea
                    in DelyMockStore.instance.historialReasignaciones.take(4))
                  _FilaHistorial(linea: linea),
                const SizedBox(height: AppSpacing.xl),
                AppDropdownField<String>(
                  label: 'Motivo de la reasignación',
                  required: true,
                  value: motivo,
                  hint: 'Selecciona un motivo…',
                  items: DelyMockStore.motivosReasignacion,
                  itemLabel: (m) => m,
                  onChanged: onMotivo,
                  errorText: motivo == null
                      ? 'Elige un motivo para poder asignar'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _carga(BuildContext context) {
    if (!pedido.tieneRepartidor) return ' desde que se creó.';
    final repartidor = context.read<RepartidoresProvider>().porId(
      pedido.repartidorId ?? '',
    );
    final activos = repartidor?.pedidosActivos ?? 0;
    if (activos == 0) return ' · sin pedidos activos';
    return activos == 1
        ? ' · lleva 1 pedido activo'
        : ' · lleva $activos pedidos activos';
  }
}

class _TarjetaCandidato extends StatelessWidget {
  const _TarjetaCandidato({
    required this.repartidor,
    required this.destacado,
    required this.metricas,
    required this.habilitado,
    required this.onAsignar,
  });

  final Repartidor repartidor;

  /// El primero de la lista se resalta con el borde verde del frame 14.
  final bool destacado;

  final ({double km, int minutos, int aceptacion}) metricas;
  final bool habilitado;
  final VoidCallback onAsignar;

  @override
  Widget build(BuildContext context) {
    final disponible = repartidor.estado.puedeRecibirPedido;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: destacado && disponible
              ? AppColors.primary
              : AppColors.borderStrong,
          width: destacado && disponible ? 1.5 : 1,
        ),
        boxShadow: destacado && disponible
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(
                nombre: repartidor.nombre,
                size: 48,
                online: repartidor.enLinea,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      repartidor.nombre,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '★ ${repartidor.calificacion.toStringAsFixed(1)} · '
                      '${_carga(repartidor)}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Distancia',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${metricas.km.toStringAsFixed(1)} km',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
          if (destacado && disponible) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _MetricaCandidato(
                  valor: '${metricas.minutos} min',
                  titulo: 'al negocio',
                ),
                const SizedBox(width: AppSpacing.xl),
                _MetricaCandidato(
                  valor: '${metricas.aceptacion}%',
                  titulo: 'aceptación',
                ),
              ],
            ),
          ],
          const SizedBox(height: 13),
          // Desconectados y sobrecargados comparten el botón deshabilitado
          // «No disponible» del diseño.
          if (!disponible)
            const AppButton(
              label: 'No disponible',
              expand: true,
              height: 44,
              onPressed: null,
            )
          else
            AppButton.primary(
              label: 'Asignar a ${repartidor.nombre.split(' ').first}',
              expand: true,
              height: 44,
              onPressed: habilitado ? onAsignar : null,
            ),
        ],
      ),
    );
  }

  static String _carga(Repartidor repartidor) {
    if (!repartidor.estado.estaEnLinea) return 'Desconectado';
    return switch (repartidor.pedidosActivos) {
      0 => 'Sin pedidos activos',
      1 => '1 pedido activo',
      final n => '$n pedidos activos',
    };
  }
}

class _MetricaCandidato extends StatelessWidget {
  const _MetricaCandidato({required this.valor, required this.titulo});

  final String valor;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor, style: AppTextStyles.cardTitleSmall),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              titulo,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaHistorial extends StatelessWidget {
  const _FilaHistorial({required this.linea});

  /// Formato `titulo|detalle`, tal como lo guarda el almacén.
  final String linea;

  @override
  Widget build(BuildContext context) {
    final partes = linea.split('|');
    final titulo = partes.isEmpty ? linea : partes.first;
    final detalle = partes.length > 1 ? partes[1] : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.swap_horiz, size: 16, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: AppTextStyles.bodySmallStrong,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  detalle,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
