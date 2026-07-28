import 'package:flutter/foundation.dart';

/// Base de todos los proveedores del panel.
///
/// Centraliza los tres estados que el diseño exige tratar en cada pantalla —
/// carga, error y datos — para que ninguna vista tenga que inventarlos ni
/// pueda leer datos a medio llegar.
abstract class ProveedorAsync extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  bool _desechado = false;

  bool get cargando => _cargando;

  /// Mensaje en español listo para mostrar, o `null` si no hubo fallo.
  String? get error => _error;

  bool get hayError => _error != null;

  /// Envuelve una lectura del repositorio marcando carga y capturando el
  /// fallo. Devuelve `true` si terminó bien.
  @protected
  Future<bool> ejecutar(Future<void> Function() accion) async {
    if (_desechado) return false;
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on Object catch (e) {
      _error = _mensajeDe(e);
      return false;
    } finally {
      _cargando = false;
      if (!_desechado) notifyListeners();
    }
  }

  /// Igual que [ejecutar] pero sin bloquear la pantalla con el estado de
  /// carga: para acciones puntuales (aprobar, reasignar, guardar) que ya
  /// muestran su propio indicador en el control pulsado.
  @protected
  Future<bool> ejecutarAccion(Future<void> Function() accion) async {
    if (_desechado) return false;
    try {
      await accion();
      _error = null;
      if (!_desechado) notifyListeners();
      return true;
    } on Object catch (e) {
      _error = _mensajeDe(e);
      if (!_desechado) notifyListeners();
      return false;
    }
  }

  static String _mensajeDe(Object error) {
    if (error is StateError) return error.message;
    return 'Ocurrió un problema al conectar con la operación. '
        'Vuelve a intentarlo en unos segundos.';
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _desechado = true;
    super.dispose();
  }
}
