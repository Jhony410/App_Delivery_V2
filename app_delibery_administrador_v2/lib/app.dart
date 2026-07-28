import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/sesion_provider.dart';
import 'features/clientes/data/repositories/clientes_repository.dart';
import 'features/clientes/providers/clientes_provider.dart';
import 'features/configuracion/data/repositories/configuracion_repository.dart';
import 'features/configuracion/providers/configuracion_provider.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/negocios/data/repositories/negocios_repository.dart';
import 'features/negocios/providers/negocios_provider.dart';
import 'features/pagos/data/repositories/pagos_repository.dart';
import 'features/pagos/providers/pagos_provider.dart';
import 'features/pedidos/data/repositories/pedidos_repository.dart';
import 'features/pedidos/providers/pedidos_provider.dart';
import 'features/promociones/data/repositories/promociones_repository.dart';
import 'features/promociones/providers/promociones_provider.dart';
import 'features/reportes/data/repositories/reportes_repository.dart';
import 'features/reportes/providers/reportes_provider.dart';
import 'features/repartidores/data/repositories/repartidores_repository.dart';
import 'features/repartidores/providers/repartidores_provider.dart';

/// Raíz de DelyPuno Operaciones.
///
/// Aquí se inyectan los repositorios: hoy son las implementaciones mock y
/// mañana serán las de Firebase. Ninguna pantalla los conoce, solo ve la
/// interfaz a través de su proveedor.
class DelyPunoAdminApp extends StatefulWidget {
  const DelyPunoAdminApp({super.key});

  @override
  State<DelyPunoAdminApp> createState() => _DelyPunoAdminAppState();
}

class _DelyPunoAdminAppState extends State<DelyPunoAdminApp> {
  final SesionProvider _sesion = SesionProvider();
  late final GoRouter _router = crearRouter(_sesion);

  // Repositorios. Al conectar Firebase basta con cambiar estas líneas.
  final DashboardRepository _dashboard = DashboardRepositoryMock();
  final PedidosRepository _pedidos = PedidosRepositoryMock();
  final RepartidoresRepository _repartidores = RepartidoresRepositoryMock();
  final NegociosRepository _negocios = NegociosRepositoryMock();
  final ClientesRepository _clientes = ClientesRepositoryMock();
  final PromocionesRepository _promociones = PromocionesRepositoryMock();
  final ReportesRepository _reportes = ReportesRepositoryMock();
  final PagosRepository _pagos = PagosRepositoryMock();
  final ConfiguracionRepository _configuracion = ConfiguracionRepositoryMock();

  @override
  void dispose() {
    _sesion.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SesionProvider>.value(value: _sesion),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(_dashboard),
        ),
        ChangeNotifierProvider<PedidosProvider>(
          create: (_) => PedidosProvider(_pedidos),
        ),
        ChangeNotifierProvider<MapaProvider>(create: (_) => MapaProvider()),
        ChangeNotifierProvider<RepartidoresProvider>(
          create: (_) => RepartidoresProvider(_repartidores),
        ),
        ChangeNotifierProvider<NegociosProvider>(
          create: (_) => NegociosProvider(_negocios),
        ),
        ChangeNotifierProvider<ClientesProvider>(
          create: (_) => ClientesProvider(_clientes),
        ),
        ChangeNotifierProvider<PromocionesProvider>(
          create: (_) => PromocionesProvider(_promociones),
        ),
        ChangeNotifierProvider<ReportesProvider>(
          create: (_) => ReportesProvider(_reportes),
        ),
        ChangeNotifierProvider<PagosProvider>(
          create: (_) => PagosProvider(_pagos),
        ),
        ChangeNotifierProvider<ConfiguracionProvider>(
          create: (_) => ConfiguracionProvider(_configuracion),
        ),
      ],
      child: MaterialApp.router(
        title: 'DelyPuno Operaciones',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
