import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_sheet_shell.dart';
import '../../widgets/badges.dart';
import '../../widgets/buttons.dart';
import '../../widgets/circular_timer.dart';
import '../../widgets/multi_order_card.dart';
import '../../widgets/system_states.dart';

/// Selector de la hoja inferior según la fase.
///
/// Todo el contenido operativo del diseño vive aquí: cada `case` es un frame.
class OperationSheet extends StatelessWidget {
  const OperationSheet({super.key, required this.phase});

  final OperationPhase phase;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      OperationPhase.desconectado => const _OfflineSheet(),
      OperationPhase.buscando => const _SearchingSheet(),
      OperationPhase.sinPedidos => const _NoOrdersSheet(),
      OperationPhase.pedidoEntrante => const _IncomingOfferSheet(),
      OperationPhase.rutaAlRestaurante => const _RouteToRestaurantSheet(),
      OperationPhase.esperandoEnRestaurante => const _WaitingAtRestaurantSheet(),
      OperationPhase.rutaAlCliente => const _RouteToCustomerSheet(),
      OperationPhase.confirmarEntrega => const _ConfirmDeliverySheet(),
      OperationPhase.pedidosMultiples => const _MultiOrderSheet(),
    };
  }
}

// ---------------------------------------------------------------- frame 21

/// Frame 21 — Desconectado.
class _OfflineSheet extends StatelessWidget {
  const _OfflineSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return BottomSheetShell(
      height: SheetHeight.medio,
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.fillStrong, shape: BoxShape.circle),
              child: const Icon(Icons.do_not_disturb_on_outlined, size: 38, color: AppColors.neutral),
            ),
          ),
          const SizedBox(height: 16),
          Text('Estás desconectado', textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 10),
          Text(
            'No recibirás pedidos hasta que te conectes. Ponte en línea para empezar a repartir.',
            textAlign: TextAlign.center,
            style: AppText.body(14, height: 1.55),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Conectarme',
            height: 58,
            onPressed: () => state.setOnline(true),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 06

/// Frame 06 — Mapa principal, buscando pedidos.
class _SearchingSheet extends StatelessWidget {
  const _SearchingSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return BottomSheetShell(
      height: SheetHeight.peek,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppTheme.rField),
                ),
                child: const Icon(Icons.search_rounded, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buscando pedidos cerca…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(16, weight: FontWeight.w700),
                    ),
                    Text(
                      'Estás en zona de demanda media',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatTiles(
            tiles: [
              StatTileData(
                label: 'Ganancia hoy',
                value: 'S/ ${DemoData.todayEarnings.toStringAsFixed(2)}',
                valueColor: AppColors.primary,
              ),
              const StatTileData(label: 'Pedidos', value: '${DemoData.todayOrders}'),
              const StatTileData(label: 'Conectado', value: DemoData.todayOnline),
            ],
          ),
          const SizedBox(height: 16),

          // Disparadores del flujo: sin ellos, los frames 08 y 13 quedarían
          // inalcanzables hasta que exista el backend real.
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Simular pedido',
                  icon: Icons.notifications_active_outlined,
                  onPressed: state.receiveOffer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: 'Lote de 3',
                  icon: Icons.layers_rounded,
                  onPressed: state.receiveMultiOrders,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 25

/// Frame 25 — Estado vacío: conectado, sin pedidos en el radio.
class _NoOrdersSheet extends StatelessWidget {
  const _NoOrdersSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return BottomSheetShell(
      height: SheetHeight.medio,
      padding: const EdgeInsets.fromLTRB(30, 18, 30, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmptyStateSheet(onSeeHeatmap: state.showHeatmapLayer),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Volver a buscar',
            icon: Icons.refresh_rounded,
            onPressed: state.resumeSearching,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 08

/// Frame 08 — Pedido entrante con temporizador de 20 s.
class _IncomingOfferSheet extends StatelessWidget {
  const _IncomingOfferSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final order = state.currentOrder;

    return BottomSheetShell(
      height: SheetHeight.alto,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('NUEVO PEDIDO', style: AppText.chip(Colors.white)),
              ),
              CircularTimer(
                secondsLeft: state.offerSeconds,
                totalSeconds: DemoData.offerSeconds,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _BusinessAvatar(order: order, size: 56),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(18, weight: FontWeight.w700),
                    ),
                    Text(
                      order.businessCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ganancia', style: AppText.body(11)),
                  Text(
                    'S/ ${order.earnings.toStringAsFixed(2)}',
                    style: AppText.display(24, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: IconStat(
                  icon: Icons.location_on_outlined,
                  value: '${order.distanceKm} km',
                  label: 'distancia total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IconStat(
                  icon: Icons.schedule_rounded,
                  value: '${order.etaMinutes} min',
                  label: 'estimado',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          PickupDropoffRow(
            pickupName: order.businessName,
            pickupAddress: order.pickupAddress,
            dropoffName: 'Cliente',
            dropoffAddress: order.dropoffAddress.split(',').first,
          ),
          const SizedBox(height: 20),

          PrimaryButton(label: 'ACEPTAR PEDIDO', height: 58, onPressed: state.acceptOffer),
          const SizedBox(height: 10),
          NeutralButton(label: 'Rechazar', onPressed: state.rejectOffer),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 09

/// Frame 09 — Aceptado, en ruta al restaurante.
class _RouteToRestaurantSheet extends StatelessWidget {
  const _RouteToRestaurantSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final order = state.currentOrder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EtaBanner(
          icon: Icons.storefront_rounded,
          title: 'Ve a recoger el pedido',
          subtitle: 'Restaurante a 6 min · 1.1 km',
        ),
        BottomSheetShell(
          height: SheetHeight.medio,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('RECOGE EN', style: AppText.body(12, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _BusinessAvatar(order: order, size: 52),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.display(17, weight: FontWeight.w700),
                        ),
                        Text(
                          '${order.pickupAddress} · Puno',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pedido', style: AppText.body(11)),
                      Text(order.id, style: AppText.display(15, weight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _CallNavigateRow(),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Llegué al restaurante',
                height: 58,
                onPressed: state.arrivedAtRestaurant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- frame 10

/// Frame 10 — En el restaurante, esperando que salga el pedido.
class _WaitingAtRestaurantSheet extends StatelessWidget {
  const _WaitingAtRestaurantSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final order = state.currentOrder;

    return BottomSheetShell(
      height: SheetHeight.alto,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(AppTheme.rField),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Preparando tu pedido',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(15, weight: FontWeight.w700, color: AppColors.warning),
                      ),
                      Text(
                        'Espera cerca del mostrador',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12, color: AppColors.warningText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedido ${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(17, weight: FontWeight.w700),
                ),
              ),
              const StatusChip(status: OrderStatus.enCocina),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in order.items) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity} × ${item.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('S/ ${item.price.toStringAsFixed(2)}', style: AppText.body(13, weight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 11),
                ],
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: Text('Total del cliente', style: AppText.display(14, weight: FontWeight.w700)),
                    ),
                    Text(
                      'S/ ${order.customerTotal.toStringAsFixed(2)}',
                      style: AppText.display(14, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          PrimaryButton(label: 'Confirmar recojo', height: 58, onPressed: state.confirmPickup),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 11

/// Frame 11 — Recogido, en ruta al cliente.
class _RouteToCustomerSheet extends StatelessWidget {
  const _RouteToCustomerSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final order = state.currentOrder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EtaBanner(
          icon: Icons.location_on_rounded,
          title: 'Lleva el pedido al cliente',
          subtitle: 'A 8 min · 1.6 km',
        ),
        BottomSheetShell(
          height: SheetHeight.medio,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ENTREGAR A', style: AppText.body(12, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8FB9E8), Color(0xFF5B7FC4)],
                      ),
                    ),
                    child: Text(
                      order.customerInitials,
                      style: AppText.display(18, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.display(17, weight: FontWeight.w700),
                        ),
                        Text(
                          order.dropoffAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _CallNavigateRow(secondLabel: 'Chat', secondIcon: Icons.chat_bubble_outline_rounded),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Llegué con el cliente',
                height: 58,
                onPressed: state.arrivedAtCustomer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- frame 12

/// Frame 12 — Confirmar entrega: código de 4 dígitos, foto y deslizar.
class _ConfirmDeliverySheet extends StatefulWidget {
  const _ConfirmDeliverySheet();

  @override
  State<_ConfirmDeliverySheet> createState() => _ConfirmDeliverySheetState();
}

class _ConfirmDeliverySheetState extends State<_ConfirmDeliverySheet> {
  final List<String> _code = List.filled(4, '');
  bool _photoTaken = false;

  bool get _codeComplete => _code.every((d) => d.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final order = state.currentOrder;

    return BottomSheetShell(
      height: SheetHeight.alto,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.navigation_rounded, size: 32, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text('¡Ya llegaste!', textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              style: AppText.body(13),
              children: [
                const TextSpan(text: 'Confirma la entrega a '),
                TextSpan(
                  text: order.customerName,
                  style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Text('CÓDIGO DE ENTREGA', style: AppText.body(12, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _code.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _DeliveryCodeBox(
                    value: _code[i],
                    onChanged: (value) => setState(() => _code[i] = value),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          _PhotoButton(
            taken: _photoTaken,
            onPressed: () => setState(() => _photoTaken = !_photoTaken),
          ),
          const SizedBox(height: 16),

          _SlideToDeliver(
            enabled: _codeComplete,
            onDelivered: () {
              state.completeDelivery();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Pedido ${order.id} entregado · S/ ${order.earnings.toStringAsFixed(2)}'),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
          if (!_codeComplete) ...[
            const SizedBox(height: 10),
            Text(
              'Pide al cliente su código de 4 dígitos para habilitar la entrega.',
              textAlign: TextAlign.center,
              style: AppText.body(12),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- frame 13

/// Frame 13 — Lote de pedidos múltiples con ruta optimizada.
class _MultiOrderSheet extends StatelessWidget {
  const _MultiOrderSheet();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final orders = DemoData.multiOrders;

    return BottomSheetShell(
      height: SheetHeight.medio,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tienes ${orders.length} pedidos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(18, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip.custom(
                  label: 'Ruta optimizada',
                  foreground: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ],
            ),
          ),

          // Carrusel horizontal de tarjetas de colores.
          SizedBox(
            height: 138,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) => MultiOrderCard(
                order: orders[index],
                index: index,
                badge: DemoData.multiOrderBadges[index],
                onTap: index == 0 ? state.startFirstOfBatch : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Empezar con Pedido 1',
                  onPressed: state.startFirstOfBatch,
                ),
                const SizedBox(height: 10),
                NeutralButton(label: 'Volver al mapa', onPressed: state.backToMap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ compartidos

/// Banner verde de ETA sobre la hoja (frames 09 y 11).
class _EtaBanner extends StatelessWidget {
  const _EtaBanner({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(15, weight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, color: AppColors.textOnBrandSoft),
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

/// Par de botones "Llamar" + "Navegar"/"Chat" (frames 09 y 11).
class _CallNavigateRow extends StatelessWidget {
  const _CallNavigateRow({
    this.secondLabel = 'Navegar',
    this.secondIcon = Icons.navigation_rounded,
  });

  final String secondLabel;
  final IconData secondIcon;

  @override
  Widget build(BuildContext context) {
    void notify(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: 'Llamar',
            icon: Icons.phone_rounded,
            height: 50,
            onPressed: () => notify('Llamando…'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryButton(
            label: secondLabel,
            icon: secondIcon,
            height: 50,
            onPressed: () => notify('$secondLabel…'),
          ),
        ),
      ],
    );
  }
}

/// Miniatura del negocio con su degradado.
class _BusinessAvatar extends StatelessWidget {
  const _BusinessAvatar({required this.order, required this.size});

  final DeliveryOrder order;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: order.gradient,
        ),
      ),
      child: Text(order.businessEmoji, style: TextStyle(fontSize: size * 0.4)),
    );
  }
}

/// Casilla del código de entrega: se toca para rotar el dígito.
class _DeliveryCodeBox extends StatelessWidget {
  const _DeliveryCodeBox({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filled = value.isNotEmpty;

    return GestureDetector(
      onTap: () {
        final next = filled ? (int.parse(value) + 1) % 10 : 0;
        onChanged('$next');
      },
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppTheme.rField),
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: filled
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), spreadRadius: 4)]
              : null,
        ),
        child: Text(
          filled ? value : '·',
          style: AppText.display(24, color: filled ? AppColors.textPrimary : AppColors.textHint),
        ),
      ),
    );
  }
}

/// Botón punteado de "Tomar foto de la entrega" (frame 12).
class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.taken, required this.onPressed});

  final bool taken;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: taken ? AppColors.primarySoft : AppColors.fill,
          borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
          border: Border.all(
            color: taken ? AppColors.primary : const Color(0xFFC7D6CC),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              taken ? Icons.check_circle_rounded : Icons.photo_camera_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                taken ? 'Foto adjuntada' : 'Tomar foto de la entrega',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(14, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Desliza para entregar" del frame 12.
///
/// Arrastrar la pastilla blanca hasta el final confirma la entrega; soltarla
/// antes la devuelve al inicio.
class _SlideToDeliver extends StatefulWidget {
  const _SlideToDeliver({required this.enabled, required this.onDelivered});

  final bool enabled;
  final VoidCallback onDelivered;

  @override
  State<_SlideToDeliver> createState() => _SlideToDeliverState();
}

class _SlideToDeliverState extends State<_SlideToDeliver> {
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    const trackHeight = 60.0;
    const knobSize = 50.0;
    const padding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = (constraints.maxWidth - knobSize - padding * 2).clamp(0.0, double.infinity);
        final progress = maxDrag == 0 ? 0.0 : (_dragX / maxDrag).clamp(0.0, 1.0);

        return Container(
          height: trackHeight,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: widget.enabled
                ? AppColors.primary
                : AppColors.neutral.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppTheme.rButton),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1 - progress,
                child: Text(
                  'Desliza para entregar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(16, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(_dragX, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.enabled
                        ? (details) => setState(
                              () => _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDrag),
                            )
                        : null,
                    onHorizontalDragEnd: widget.enabled
                        ? (_) {
                            if (_dragX >= maxDrag * 0.85) {
                              setState(() => _dragX = maxDrag);
                              widget.onDelivered();
                            } else {
                              setState(() => _dragX = 0);
                            }
                          }
                        : null,
                    child: Container(
                      width: knobSize,
                      height: knobSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 26,
                        color: widget.enabled ? AppColors.primary : AppColors.neutral,
                      ),
                    ),
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
