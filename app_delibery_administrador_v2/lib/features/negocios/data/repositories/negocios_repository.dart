import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../../../../core/models/estado_negocio.dart';
import '../models/negocio.dart';

/// Acceso a los negocios afiliados y a su soporte.
abstract interface class NegociosRepository {
  Future<List<Negocio>> obtenerNegocios();

  Future<Negocio?> obtenerNegocio(String id);

  Future<Negocio> actualizarProducto({
    required String negocioId,
    required Producto producto,
  });

  Future<Negocio> actualizarHorario({
    required String negocioId,
    required String horario,
  });

  Future<Negocio> actualizarComision({
    required String negocioId,
    required int comision,
  });

  /// Fuerza la apertura o el cierre cuando el comerciante no puede hacerlo.
  Future<Negocio> forzarEstado({
    required String negocioId,
    required EstadoNegocio estado,
  });

  Future<Negocio> resolverIncidencia({
    required String negocioId,
    required String incidenciaId,
  });

  Future<Negocio> registrar({
    required String nombre,
    required String categoria,
    required String direccion,
    required String horario,
    required int comision,
  });
}

class NegociosRepositoryMock implements NegociosRepository {
  NegociosRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<List<Negocio>> obtenerNegocios() async {
    await LatenciaMock.esperarLectura();
    return List<Negocio>.unmodifiable(_store.negocios);
  }

  @override
  Future<Negocio?> obtenerNegocio(String id) async {
    await LatenciaMock.esperarLectura();
    final indice = _store.negocios.indexWhere((n) => n.id == id);
    return indice == -1 ? null : _store.negocios[indice];
  }

  @override
  Future<Negocio> actualizarProducto({
    required String negocioId,
    required Producto producto,
  }) => _actualizar(negocioId, (negocio) {
    return negocio.copyWith(
      productos: [
        for (final p in negocio.productos)
          if (p.id == producto.id) producto else p,
      ],
    );
  });

  @override
  Future<Negocio> actualizarHorario({
    required String negocioId,
    required String horario,
  }) => _actualizar(negocioId, (negocio) => negocio.copyWith(horario: horario));

  @override
  Future<Negocio> actualizarComision({
    required String negocioId,
    required int comision,
  }) =>
      _actualizar(negocioId, (negocio) => negocio.copyWith(comision: comision));

  @override
  Future<Negocio> forzarEstado({
    required String negocioId,
    required EstadoNegocio estado,
  }) => _actualizar(negocioId, (negocio) => negocio.copyWith(estado: estado));

  @override
  Future<Negocio> resolverIncidencia({
    required String negocioId,
    required String incidenciaId,
  }) => _actualizar(negocioId, (negocio) {
    final incidencias = [
      for (final i in negocio.incidencias)
        if (i.id == incidenciaId)
          Incidencia(
            id: i.id,
            titulo: i.titulo,
            detalle:
                '${i.detalle} · resuelta por ${DelyMockStore.operadorNombre}',
            estado: EstadoIncidencia.resuelta,
            pedidoId: i.pedidoId,
            negocioId: i.negocioId,
            severidad: i.severidad,
          )
        else
          i,
    ];
    final abiertas = incidencias
        .where((i) => i.estado != EstadoIncidencia.resuelta)
        .length;
    return negocio.copyWith(
      incidencias: incidencias,
      incidenciasAbiertas: abiertas,
      estado: abiertas == 0 && negocio.estado == EstadoNegocio.retrasos
          ? EstadoNegocio.abierto
          : negocio.estado,
    );
  });

  @override
  Future<Negocio> registrar({
    required String nombre,
    required String categoria,
    required String direccion,
    required String horario,
    required int comision,
  }) async {
    await LatenciaMock.esperarEscritura();
    final nuevo = Negocio(
      id: 'neg-${_store.negocios.length + 1}'.padLeft(6, '0'),
      nombre: nombre,
      categoria: categoria,
      direccion: direccion,
      estado: EstadoNegocio.cerrado,
      horario: horario,
      comision: comision,
      comisionPreferente: comision < 18,
    );
    _store.negocios.add(nuevo);
    return nuevo;
  }

  Future<Negocio> _actualizar(
    String negocioId,
    Negocio Function(Negocio) cambio,
  ) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.negocios.indexWhere((n) => n.id == negocioId);
    if (indice == -1) {
      throw StateError('El negocio ya no está afiliado a DelyPuno.');
    }
    final actualizado = cambio(_store.negocios[indice]);
    _store.negocios[indice] = actualizado;
    return actualizado;
  }
}
