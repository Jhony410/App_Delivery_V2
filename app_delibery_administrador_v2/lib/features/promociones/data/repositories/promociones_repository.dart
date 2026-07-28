import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../models/promocion.dart';

/// Acceso a las promociones de la app del cliente.
abstract interface class PromocionesRepository {
  Future<List<Promocion>> obtenerPromociones();

  /// Publica la promoción o la deja en borrador.
  Future<Promocion> guardar({
    required String titulo,
    required TipoPromocion tipo,
    required String valor,
    required String desde,
    required String hasta,
    required List<String> negocios,
    required bool publicar,
  });

  Future<void> finalizar(String promocionId);
}

class PromocionesRepositoryMock implements PromocionesRepository {
  PromocionesRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<List<Promocion>> obtenerPromociones() async {
    await LatenciaMock.esperarLectura();
    return List<Promocion>.unmodifiable(_store.promociones);
  }

  @override
  Future<Promocion> guardar({
    required String titulo,
    required TipoPromocion tipo,
    required String valor,
    required String desde,
    required String hasta,
    required List<String> negocios,
    required bool publicar,
  }) async {
    await LatenciaMock.esperarEscritura();
    final nueva = Promocion(
      id: 'promo-${_store.promociones.length + 1}'.padLeft(8, '0'),
      titulo: titulo,
      tipo: tipo,
      valor: valor,
      desde: desde,
      hasta: hasta,
      estado: publicar ? EstadoPromocion.activa : EstadoPromocion.borrador,
      negocios: negocios,
    );
    _store.promociones.insert(0, nueva);
    return nueva;
  }

  @override
  Future<void> finalizar(String promocionId) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.promociones.indexWhere((p) => p.id == promocionId);
    if (indice == -1) return;
    final promocion = _store.promociones[indice];
    _store.promociones[indice] = Promocion(
      id: promocion.id,
      titulo: promocion.titulo,
      tipo: promocion.tipo,
      valor: promocion.valor,
      desde: promocion.desde,
      hasta: promocion.hasta,
      estado: EstadoPromocion.finalizada,
      negocios: promocion.negocios,
      usos: promocion.usos,
      alcanceTexto: promocion.alcanceTexto,
    );
  }
}
