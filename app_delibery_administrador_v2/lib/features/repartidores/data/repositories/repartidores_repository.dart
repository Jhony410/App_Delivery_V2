import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../../../../core/models/estado_repartidor.dart';
import '../models/repartidor.dart';

/// Acceso a los repartidores de CHASQUI.
abstract interface class RepartidoresRepository {
  Future<List<Repartidor>> obtenerRepartidores();

  Future<Repartidor?> obtenerRepartidor(String id);

  /// Candidatos que pueden tomar un pedido ahora, ordenados por cercanía.
  Future<List<Repartidor>> obtenerCandidatos({String? excluirId});

  Future<Repartidor> resolverDocumento({
    required String repartidorId,
    required String tipoDocumento,
    required bool aprobado,
  });

  Future<Repartidor> suspender({
    required String repartidorId,
    required String motivo,
  });

  Future<Repartidor> bloquear({
    required String repartidorId,
    required String motivo,
  });

  Future<Repartidor> registrar({
    required String nombre,
    required String dni,
    required String celular,
    required String vehiculo,
    required String placa,
  });
}

class RepartidoresRepositoryMock implements RepartidoresRepository {
  RepartidoresRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<List<Repartidor>> obtenerRepartidores() async {
    await LatenciaMock.esperarLectura();
    return List<Repartidor>.unmodifiable(_store.repartidores);
  }

  @override
  Future<Repartidor?> obtenerRepartidor(String id) async {
    await LatenciaMock.esperarLectura();
    final indice = _store.repartidores.indexWhere((r) => r.id == id);
    return indice == -1 ? null : _store.repartidores[indice];
  }

  @override
  Future<List<Repartidor>> obtenerCandidatos({String? excluirId}) async {
    await LatenciaMock.esperarLectura();
    final candidatos = _store.repartidores
        .where((r) => r.id != excluirId && !r.suspendido && !r.bloqueado)
        .toList();
    // Disponibles primero, después por menos carga y mejor calificación.
    candidatos.sort((a, b) {
      final disponibleA = a.estado.puedeRecibirPedido ? 0 : 1;
      final disponibleB = b.estado.puedeRecibirPedido ? 0 : 1;
      if (disponibleA != disponibleB) return disponibleA.compareTo(disponibleB);
      if (a.pedidosActivos != b.pedidosActivos) {
        return a.pedidosActivos.compareTo(b.pedidosActivos);
      }
      return b.calificacion.compareTo(a.calificacion);
    });
    return List<Repartidor>.unmodifiable(candidatos);
  }

  @override
  Future<Repartidor> resolverDocumento({
    required String repartidorId,
    required String tipoDocumento,
    required bool aprobado,
  }) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.repartidores.indexWhere((r) => r.id == repartidorId);
    if (indice == -1) {
      throw StateError('El repartidor ya no figura en CHASQUI.');
    }
    final repartidor = _store.repartidores[indice];
    final documentos = [
      for (final doc in repartidor.documentos)
        if (doc.tipo == tipoDocumento)
          doc.copyWith(
            estado: aprobado
                ? EstadoDocumento.aprobado
                : EstadoDocumento.rechazado,
            detalle: aprobado
                ? 'Aprobado hoy por ${DelyMockStore.operadorNombre}'
                : 'Rechazado hoy por ${DelyMockStore.operadorNombre}',
          )
        else
          doc,
    ];

    final quedaPendiente = documentos.any(
      (d) => d.estado == EstadoDocumento.enRevision,
    );
    final actualizado = repartidor.copyWith(
      documentos: documentos,
      estado:
          repartidor.estado == EstadoRepartidor.docsPendientes &&
              !quedaPendiente
          ? EstadoRepartidor.desconectado
          : repartidor.estado,
    );
    _store.repartidores[indice] = actualizado;
    return actualizado;
  }

  @override
  Future<Repartidor> suspender({
    required String repartidorId,
    required String motivo,
  }) => _cambiarAcceso(repartidorId, suspendido: true);

  @override
  Future<Repartidor> bloquear({
    required String repartidorId,
    required String motivo,
  }) => _cambiarAcceso(repartidorId, bloqueado: true);

  Future<Repartidor> _cambiarAcceso(
    String repartidorId, {
    bool? suspendido,
    bool? bloqueado,
  }) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.repartidores.indexWhere((r) => r.id == repartidorId);
    if (indice == -1) {
      throw StateError('El repartidor ya no figura en CHASQUI.');
    }
    final actualizado = _store.repartidores[indice].copyWith(
      suspendido: suspendido,
      bloqueado: bloqueado,
      estado: EstadoRepartidor.desconectado,
      pedidosActivos: 0,
    );
    _store.repartidores[indice] = actualizado;
    return actualizado;
  }

  @override
  Future<Repartidor> registrar({
    required String nombre,
    required String dni,
    required String celular,
    required String vehiculo,
    required String placa,
  }) async {
    await LatenciaMock.esperarEscritura();
    final nuevo = Repartidor(
      id: 'rep-${_store.repartidores.length + 1}'.padLeft(6, '0'),
      nombre: nombre,
      estado: EstadoRepartidor.docsPendientes,
      calificacion: 0,
      vehiculo: vehiculo,
      placa: placa.isEmpty ? null : placa,
      dni: dni,
      celular: celular,
      desde: 'jul. 2026',
      notaEstado: 'Documentos por subir',
      documentos: const [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
      ],
    );
    _store.repartidores.add(nuevo);
    return nuevo;
  }
}
