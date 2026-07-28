/// Latencia simulada de los repositorios mock.
///
/// Existe para que los estados de carga de las pantallas sean reales y no
/// decorativos: al cambiar a Firebase, la espera pasa a ser la de la red y
/// las pantallas no cambian.
abstract final class LatenciaMock {
  static const Duration lectura = Duration(milliseconds: 450);
  static const Duration escritura = Duration(milliseconds: 300);

  static Future<void> esperarLectura() => Future<void>.delayed(lectura);

  static Future<void> esperarEscritura() => Future<void>.delayed(escritura);
}
