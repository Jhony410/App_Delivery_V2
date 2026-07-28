import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/estado_negocio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../providers/clientes_provider.dart';

/// Ficha del cliente, abierta desde el botón «Ver» de la tabla.
///
/// El diseño no dibuja una pantalla de detalle de cliente, así que la ficha
/// se resuelve en una hoja con los componentes del frame 14.
class HojaFichaCliente extends StatefulWidget {
  const HojaFichaCliente({super.key, required this.clienteId});

  final String clienteId;

  @override
  State<HojaFichaCliente> createState() => _HojaFichaClienteState();
}

class _HojaFichaClienteState extends State<HojaFichaCliente> {
  bool _enviando = false;

  Future<void> _alternarBloqueo(bool bloqueado, String nombre) async {
    final motivo = await mostrarConfirmacion(
      context,
      titulo: bloqueado ? '¿Desbloquear a $nombre?' : '¿Bloquear a $nombre?',
      mensaje: bloqueado
          ? 'Volverá a poder hacer pedidos en DelyPuno de inmediato.'
          : 'No podrá hacer pedidos hasta que lo desbloquees. Se le '
                'notificará en la app.',
      etiquetaConfirmar: bloqueado ? 'Desbloquear' : 'Bloquear',
      destructiva: !bloqueado,
      pedirMotivo: true,
    );
    if (motivo == null || !mounted) return;

    setState(() => _enviando = true);
    final provider = context.read<ClientesProvider>();
    final ok = await provider.alternarBloqueo(
      clienteId: widget.clienteId,
      motivo: motivo,
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    mostrarAviso(
      context,
      ok
          ? '$nombre ${bloqueado ? 'desbloqueado' : 'bloqueado'} · «$motivo».'
          : provider.error ?? 'No se pudo actualizar el estado del cliente.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = context.watch<ClientesProvider>().porId(widget.clienteId);

    if (cliente == null) {
      return AppBottomSheet(
        titulo: 'Cliente no disponible',
        acciones: [
          AppButton.neutral(
            label: 'Cerrar',
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: Text(
          'Este cliente ya no está registrado en DelyPuno.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final bloqueado = cliente.estado == EstadoCliente.bloqueado;

    return AppBottomSheet(
      titulo: cliente.nombre,
      subtitulo: 'Cliente desde ${cliente.registradoEn ?? '—'}',
      acciones: [
        AppButton.neutral(
          label: 'Cerrar',
          expand: true,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        if (bloqueado)
          AppButton.primary(
            label: _enviando ? 'Aplicando…' : 'Desbloquear',
            expand: true,
            onPressed: _enviando
                ? null
                : () => _alternarBloqueo(true, cliente.nombre),
          )
        else
          AppButton.destructive(
            label: _enviando ? 'Aplicando…' : 'Bloquear',
            expand: true,
            onPressed: _enviando
                ? null
                : () => _alternarBloqueo(false, cliente.nombre),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(nombre: cliente.nombre, size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cliente.celular,
                      style: AppTextStyles.cardTitleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cliente.direccion ?? 'Sin dirección registrada',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: cliente.estado.etiqueta,
                tone: switch (cliente.estado) {
                  EstadoCliente.frecuente => AppBadgeTone.highlight,
                  EstadoCliente.activo => AppBadgeTone.ok,
                  EstadoCliente.bloqueado => AppBadgeTone.danger,
                },
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.md,
            children: [
              _Dato(titulo: 'Pedidos', valor: '${cliente.pedidos}'),
              _Dato(titulo: 'Gasto total', valor: cliente.gastoTexto),
              _Dato(
                titulo: 'Ticket promedio',
                valor: cliente.ticketPromedio == null
                    ? '—'
                    : 'S/ ${cliente.ticketPromedio!.toStringAsFixed(0)}',
              ),
              _Dato(titulo: 'Último pedido', valor: cliente.ultimoPedido),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
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
