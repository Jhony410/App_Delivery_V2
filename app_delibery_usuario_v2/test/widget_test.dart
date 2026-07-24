// Pruebas de consistencia de navegación de DelyPuno.
//
// Validan que la fuente única de verdad de rutas (AppRoutes) esté completa y
// que los constructores con parámetros generen las rutas esperadas. Son puras
// (sin red ni timers), por lo que corren rápido y de forma estable.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_delibery_usuario_v2/router/app_routes.dart';

void main() {
  test('Las 18 pantallas tienen una ruta declarada', () {
    final paths = <String>{
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.history,
      AppRoutes.profile,
      AppRoutes.category,
      AppRoutes.business,
      AppRoutes.product,
      AppRoutes.checkout,
      AppRoutes.tracking,
      AppRoutes.rating,
      AppRoutes.addresses,
      AppRoutes.addAddress,
      AppRoutes.adjustMap,
      AppRoutes.myTown,
    };
    // 18 rutas únicas, todas absolutas.
    expect(paths.length, 18);
    for (final p in paths) {
      expect(p.startsWith('/'), isTrue, reason: 'Ruta no absoluta: $p');
    }
  });

  test('Los constructores con parámetros generan rutas válidas', () {
    expect(AppRoutes.categoryTo('comida'), '/category/comida');
    expect(AppRoutes.businessTo('polleria-el-cholo'), '/business/polleria-el-cholo');
    expect(AppRoutes.productTo('b1', 'p1'), '/product/b1/p1');
    expect(AppRoutes.trackingTo('4821'), '/tracking/4821');
    expect(AppRoutes.ratingTo('4821'), '/rating/4821');
    expect(AppRoutes.adjustMapFrom(AppRoutes.nAddAddress),
        '/adjust-map?from=addAddress');
  });
}
