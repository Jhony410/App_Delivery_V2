import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../models/configuracion_operativa.dart';

/// Acceso a la configuración operativa del panel.
abstract interface class ConfiguracionRepository {
  Future<ConfiguracionOperativa> obtener();

  Future<ConfiguracionOperativa> guardar(ConfiguracionOperativa configuracion);

  Future<ConfiguracionOperativa> invitarMiembro({
    required String nombre,
    required String correo,
    required RolEquipo rol,
  });
}

class ConfiguracionRepositoryMock implements ConfiguracionRepository {
  ConfiguracionRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<ConfiguracionOperativa> obtener() async {
    await LatenciaMock.esperarLectura();
    return _store.configuracion;
  }

  @override
  Future<ConfiguracionOperativa> guardar(
    ConfiguracionOperativa configuracion,
  ) async {
    await LatenciaMock.esperarEscritura();
    _store.configuracion = configuracion;
    return configuracion;
  }

  @override
  Future<ConfiguracionOperativa> invitarMiembro({
    required String nombre,
    required String correo,
    required RolEquipo rol,
  }) async {
    await LatenciaMock.esperarEscritura();
    final actualizada = _store.configuracion.copyWith(
      equipo: [
        ..._store.configuracion.equipo,
        MiembroEquipo(
          id: 'eq-${_store.configuracion.equipo.length + 1}'.padLeft(5, '0'),
          nombre: nombre,
          correo: correo,
          rol: rol,
        ),
      ],
    );
    _store.configuracion = actualizada;
    return actualizada;
  }
}
