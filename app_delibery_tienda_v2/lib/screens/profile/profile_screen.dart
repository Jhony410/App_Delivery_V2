import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/store_logo.dart';

/// **Pantalla 10 · Perfil.** Quinta pestaña del bottom nav.
///
/// Abrir/cerrar el negocio, dirección, horario y WhatsApp del local.
///
/// Incluye además el **panel de demo**, que es la única forma de alcanzar a
/// mano los estados del sistema mientras no exista backend: sin conexión
/// (frame 10), estado vacío (frame 12), error genérico (frame 13) y la alerta
/// de pedido nuevo (frame 06).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final negocio = state.business;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Cabecera(nombre: negocio.name, rubro: negocio.category),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _TarjetaAbrirCerrar(
              abierto: state.abierto,
              onToggle: state.alternarNegocioAbierto,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                _Fila(
                  icono: Icons.location_on_outlined,
                  titulo: 'Dirección',
                  valor: negocio.address,
                  onTap: () => _pendiente(context, 'Editar dirección'),
                ),
                _Fila(
                  icono: Icons.access_time_rounded,
                  titulo: 'Horario de atención',
                  valor: negocio.schedule,
                  onTap: () => _pendiente(context, 'Editar horario'),
                ),
                _Fila(
                  icono: Icons.chat_bubble_outline_rounded,
                  iconoColor: AppColors.whatsapp,
                  titulo: 'WhatsApp del negocio',
                  valor: negocio.whatsapp,
                  ultimo: true,
                  onTap: () => _pendiente(context, 'Editar WhatsApp'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _PanelDemo(state: state),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: SecondaryButton(
              label: 'Cerrar sesión',
              onPressed: () {
                state.cerrarSesion();
                context.go(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pendiente(BuildContext context, String accion) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$accion · disponible en la siguiente entrega',
            style: AppText.body(
              15,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.nombre, required this.rubro});

  final String nombre;
  final String rubro;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Row(
            children: [
              const StoreLogo(size: 70, radius: AppTheme.rLogo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: AppText.display(21, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rubro,
                      style: AppText.body(
                        15,
                        weight: FontWeight.w500,
                        color: AppColors.textOnBrandStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAbrirCerrar extends StatelessWidget {
  const _TarjetaAbrirCerrar({required this.abierto, required this.onToggle});

  final bool abierto;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = abierto ? AppColors.success : AppColors.neutral;

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      abierto
                          ? 'Tu negocio está abierto'
                          : 'Tu negocio está cerrado',
                      style: AppText.display(18, weight: FontWeight.w700),
                    ),
                    Text(
                      abierto ? 'Recibiendo pedidos' : 'No recibes pedidos',
                      style: AppText.body(15, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SecondaryButton(
            label: abierto ? 'Cerrar negocio' : 'Abrir negocio',
            onPressed: onToggle,
            height: 58,
            fontSize: 19,
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.onTap,
    this.iconoColor = AppColors.primary,
    this.ultimo = false,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final VoidCallback onTap;
  final Color iconoColor;
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
        decoration: BoxDecoration(
          border: ultimo
              ? null
              : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Icon(icono, size: 26, color: iconoColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppText.body(
                      16,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(valor, style: AppText.body(15, weight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.neutral,
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel de demo: hace alcanzables a mano los estados que en producción
/// dispararán la red y el backend.
///
/// No pertenece al canvas de diseño. Existe para poder recorrer el 100 % de
/// los frames sin servidor; al conectar Firebase basta con borrar este widget
/// y su fila en [ProfileScreen].
class _PanelDemo extends StatelessWidget {
  const _PanelDemo({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fillStrong,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppTheme.rCard),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                size: 20,
                color: AppColors.neutral,
              ),
              const SizedBox(width: 8),
              Text('MODO DEMO', style: AppText.sectionLabel()),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dispara a mano los estados que en producción vendrán del servidor.',
            style: AppText.body(14, weight: FontWeight.w500, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AccionDemo(
                etiqueta: 'Simular pedido nuevo',
                icono: Icons.notifications_active_outlined,
                onTap: state.simularPedidoNuevo,
              ),
              _AccionDemo(
                etiqueta: state.enLinea ? 'Cortar conexión' : 'Reconectar',
                icono: state.enLinea
                    ? Icons.wifi_off_rounded
                    : Icons.wifi_rounded,
                onTap: state.alternarConexion,
              ),
              _AccionDemo(
                etiqueta: state.orders.isEmpty
                    ? 'Repoblar pedidos'
                    : 'Vaciar pedidos',
                icono: Icons.inbox_outlined,
                onTap: state.alternarPedidosVacios,
              ),
              _AccionDemo(
                etiqueta: 'Forzar error en Pedidos',
                icono: Icons.warning_amber_rounded,
                onTap: state.forzarErrorPedidos,
              ),
              _AccionDemo(
                etiqueta: 'Ver Sin conexión',
                icono: Icons.signal_wifi_bad_outlined,
                onTap: () => context.push(AppRoutes.offline),
              ),
              _AccionDemo(
                etiqueta: 'Ver Error genérico',
                icono: Icons.report_gmailerrorred_outlined,
                onTap: () => context.push(AppRoutes.error),
              ),
              _AccionDemo(
                etiqueta: 'Probar ruta inexistente',
                icono: Icons.link_off_rounded,
                onTap: () => context.push('/ruta-que-no-existe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccionDemo extends StatelessWidget {
  const _AccionDemo({
    required this.etiqueta,
    required this.icono,
    required this.onTap,
  });

  final String etiqueta;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 18),
      label: Text(etiqueta),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppText.body(14, weight: FontWeight.w600),
      ),
    );
  }
}
