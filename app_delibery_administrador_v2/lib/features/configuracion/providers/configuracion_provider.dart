import '../../../core/state/proveedor_async.dart';
import '../data/models/configuracion_operativa.dart';
import '../data/repositories/configuracion_repository.dart';

/// Estado del frame 13.
///
/// Los cambios se acumulan en memoria y solo llegan al repositorio al pulsar
/// «Guardar cambios»; «Descartar» vuelve a la última versión guardada, tal
/// como plantea el diseño.
class ConfiguracionProvider extends ProveedorAsync {
  ConfiguracionProvider(this._repository);

  final ConfiguracionRepository _repository;

  ConfiguracionOperativa? _guardada;
  ConfiguracionOperativa? _borrador;
  bool _cargado = false;

  ConfiguracionOperativa? get configuracion => _borrador;

  /// Hay cambios sin guardar.
  bool get hayCambios {
    if (_guardada == null || _borrador == null) return false;
    return _guardada!.toJson().toString() != _borrador!.toJson().toString();
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _guardada = await _repository.obtener();
      _borrador = _guardada;
      _cargado = true;
    });
  }

  void cambiarTarifa({required String clave, required double valor}) {
    final actual = _borrador;
    if (actual == null) return;
    _borrador = actual.copyWith(
      costosEnvio: [
        for (final p in actual.costosEnvio)
          if (p.clave == clave) p.copyWith(valor: valor) else p,
      ],
      comisiones: [
        for (final p in actual.comisiones)
          if (p.clave == clave) p.copyWith(valor: valor) else p,
      ],
    );
    notifyListeners();
  }

  void alternarAjuste(String clave, bool activo) {
    final actual = _borrador;
    if (actual == null) return;
    _borrador = actual.copyWith(
      ajustes: [
        for (final a in actual.ajustes)
          if (a.clave == clave) a.copyWith(activo: activo) else a,
      ],
    );
    notifyListeners();
  }

  void cambiarRol(String miembroId, RolEquipo rol) {
    final actual = _borrador;
    if (actual == null) return;
    _borrador = actual.copyWith(
      equipo: [
        for (final m in actual.equipo)
          if (m.id == miembroId) m.copyWith(rol: rol) else m,
      ],
    );
    notifyListeners();
  }

  void descartar() {
    if (_guardada == null) return;
    _borrador = _guardada;
    notifyListeners();
  }

  Future<bool> guardar() {
    final actual = _borrador;
    if (actual == null) return Future<bool>.value(false);
    return ejecutarAccion(() async {
      _guardada = await _repository.guardar(actual);
      _borrador = _guardada;
    });
  }

  Future<bool> invitar({
    required String nombre,
    required String correo,
    required RolEquipo rol,
  }) {
    return ejecutarAccion(() async {
      _guardada = await _repository.invitarMiembro(
        nombre: nombre,
        correo: correo,
        rol: rol,
      );
      _borrador = _guardada;
    });
  }
}
