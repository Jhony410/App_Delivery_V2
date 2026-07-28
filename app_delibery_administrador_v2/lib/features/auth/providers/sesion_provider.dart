import '../../../core/data/dely_mock_store.dart';
import '../../../core/data/latencia_mock.dart';
import '../../../core/state/proveedor_async.dart';

/// Sesión del operador.
///
/// La pantalla de acceso no forma parte del diseño importado: se añadió con
/// los componentes del frame 14 para que el panel tenga una puerta de entrada.
/// La verificación es simulada; al conectar Firebase Auth solo cambia
/// [iniciarSesion].
class SesionProvider extends ProveedorAsync {
  bool _autenticado = false;
  String _nombre = DelyMockStore.operadorNombre;
  String _rol = DelyMockStore.operadorRol;

  bool get autenticado => _autenticado;
  String get nombre => _nombre;
  String get rol => _rol;

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) {
    return ejecutar(() async {
      await LatenciaMock.esperarEscritura();
      if (!correo.contains('@') || contrasena.length < 4) {
        throw StateError(
          'Revisa el correo y la contraseña: la contraseña necesita al '
          'menos 4 caracteres.',
        );
      }
      _autenticado = true;
      // El diseño identifica a la operadora del panel como Julia Torres.
      final esOperadoraDelDiseno =
          correo.trim().toLowerCase() == DelyMockStore.operadorCorreo;
      _nombre = esOperadoraDelDiseno
          ? DelyMockStore.operadorNombre
          : _nombreDesdeCorreo(correo);
      _rol = DelyMockStore.operadorRol;
    });
  }

  void cerrarSesion() {
    _autenticado = false;
    notifyListeners();
  }

  static String _nombreDesdeCorreo(String correo) {
    final usuario = correo.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    if (usuario.trim().isEmpty) return DelyMockStore.operadorNombre;
    return usuario
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}
