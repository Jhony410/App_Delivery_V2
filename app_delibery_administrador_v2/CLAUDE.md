# CLAUDE.md — DelyPuno Operaciones (app de administrador)

Panel de escritorio del equipo de operaciones de DelyPuno. Supervisa las otras
tres apps del monorepo: DelyPuno (cliente), DelyPuno Negocios (comerciante) y
CHASQUI (repartidor).

## Fuente de verdad del diseño

- Proyecto de Claude Design `b499fb8a-9129-4b9b-98bb-13db7d077d43`.
- Archivos: **`DelyPunoAdmin.dc.html`** (los 14 frames) y
  **`AdminSidebar.dc.html`** (componente de navegación con estado activo).
  `support.js` es solo el runtime de Claude Design, no aporta lógica.
- **14 frames**: los 13 primeros son las pantallas; el frame 14
  («Componentes clave») es la hoja de design system y vive en `core/widgets/`.
- El diseño es de **escritorio, 1440×900, con barra lateral de 260 px**.

### Decisiones tomadas fuera del diseño

| Tema | Decisión |
|---|---|
| Navegación | Barra lateral fiel en ≥ 900 px; el mismo widget como `Drawer` por debajo, con las tablas apiladas en tarjetas. |
| Acceso | El diseño no tiene login. Se añadió `/login` usando solo componentes del frame 14. Sesión simulada en `SesionProvider`. |
| Botones sin destino | «+ Registrar repartidor», «+ Registrar negocio» y «Ver» (cliente) abren hojas inferiores construidas con el frame 14, no pantallas nuevas. |

### Incoherencias del propio diseño (respetadas, no corregidas)

- El frame 01 y el frame 02 discrepan sobre `#A-2482` y `#A-2483`. Se tomó
  **el frame 02** como canónico y el dashboard lee de la misma fuente.
- El panel de detalle del frame 02 lista `S/ 55 + S/ 14` pero rotula
  `Total S/ 42`. Se conserva el importe del pedido tal como lo pinta el
  diseño; los productos son ilustrativos.
- La leyenda dice «Reasignación · 3 puntos de entrada» y el frame 06 nombra
  cuatro. Los botones reales están en Pedidos, Mapa y Soporte: **tres**.

## Arquitectura

```
lib/
  main.dart               # arranque
  app.dart                # MaterialApp.router + MultiProvider + repositorios
  core/
    data/                 # dely_mock_store.dart (semilla compartida), latencia
    models/               # enums de dominio compartidos por 3+ features
    router/               # app_routes.dart, app_router.dart, 404
    state/                # ProveedorAsync (carga / error / datos)
    theme/                # app_colors, app_text_styles, app_spacing, app_theme
    widgets/              # design system del frame 14 + shell + gráficos + mapa
  features/<feature>/
    data/models/          # entidades con fromJson / toJson
    data/repositories/    # interfaz + implementación mock
    presentation/screens/ # pantallas
    presentation/widgets/ # widgets propios de la feature
    providers/            # ChangeNotifier sobre ProveedorAsync
```

Features: `auth`, `dashboard`, `pedidos`, `mapa`, `repartidores`,
`reasignacion`, `negocios`, `clientes`, `promociones`, `reportes`, `pagos`,
`configuracion`.

## Convenciones que no se rompen

1. **Cero valores literales de estilo en las pantallas.** Todo color, tamaño,
   radio y espaciado sale de `AppColors`, `AppTextStyles`, `AppSpacing`,
   `AppRadius` o `AppSizes`.
2. **Cero cadenas de ruta literales.** Se navega con las constantes y los
   constructores de `core/router/app_routes.dart`.
3. **Verde = sistema, rojo = solo Negocios y errores.** Ningún otro módulo usa
   el acento rojo.
4. **Toda la interfaz en español**, incluidos los nombres de clases, métodos y
   variables del código propio del dominio.
5. **Las pantallas no conocen los repositorios**, solo su proveedor; y los
   proveedores solo conocen la interfaz, nunca la implementación mock.
6. **Los tres estados siempre resueltos**: cada bloque que depende de datos va
   dentro de `VistaAsync` (carga → error → vacío → contenido).
7. **Reglas anti-desborde**: contenido largo en scroll, `Expanded`/`Flexible`
   en filas y columnas, `maxLines` + `ellipsis` en todo texto, `shrinkWrap`
   en listas anidadas. No hay `Image.network` en la app: el mapa y los
   gráficos son `CustomPaint`, y los avatares son iniciales.
8. **Sin `!` sobre nulos no comprobados y sin `late` sin inicializar.**

## Estado

`provider` (`ChangeNotifier`) como gestor único. Todos los proveedores
extienden `ProveedorAsync`, que centraliza `cargando`, `error` y la captura de
excepciones con mensaje en español.

`DashboardProvider` se crea al arrancar la app porque también alimenta los
contadores de la barra lateral (42 pedidos activos, 4 documentos por
verificar).

## Datos

`core/data/dely_mock_store.dart` es la semilla compartida en memoria con los
datos del diseño (Puno y Melgar: `Jr. Lima 320`, `S/ 42`, Pollería El Cholo,
Chifa Titicaca…). Todos los repositorios mock leen y escriben ahí, así que una
reasignación hecha en Pedidos se ve también en Mapa, en la ficha del
repartidor y en Soporte al negocio.

**Para conectar Firebase** basta con escribir las implementaciones sobre
Firestore y cambiar las nueve líneas de `app.dart` donde se instancian los
repositorios. Ninguna pantalla cambia. `firebase.json` y
`lib/firebase_options.dart` ya están en el proyecto pero **no** se inicializa
Firebase todavía.

## Rutas

Ver `NAVIGATION.md` para el grafo completo, la tabla ruta ↔ widget y la
checklist de alcance. En resumen: diez ramas en
`StatefulShellRoute.indexedStack` (una por ítem de la barra lateral), tres
rutas hijas (`/pedidos/:pedidoId`, `/repartidores/:repartidorId`,
`/negocios/:negocioId/soporte`), una ruta modal (`/reasignar/:pedidoId`) sobre
el navegador raíz, `/login` y `errorBuilder` → `NoEncontradoScreen`.

## Verificación antes de dar por buena una tarea

```powershell
flutter pub get
flutter analyze          # debe salir "No issues found!"
dart format lib test
flutter test             # 6 pruebas
flutter build apk --debug
```

`test/pantallas_test.dart` recorre las 13 pantallas en 1440×900, 360×640 y
430×932 y falla si alguna lanza una excepción o desborda. **Fija
`devicePixelRatio = 1.0`**: el entorno de pruebas usa 3 por defecto y sin eso
un «1440×900» se mediría como 480×300 lógicos.

## Coherencia con las otras tres apps

`app_delibery_usuario_v2`, `app_delibery_tienda_v2` y
`app_delibery_repartidor_v2` usan una estructura más plana
(`lib/screens|router|theme|state|widgets`) y estado con `InheritedWidget`.
Esta app sigue la estructura por features pedida para el panel, pero conserva
los mismos nombres de archivo del design system (`app_colors.dart`,
`app_theme.dart`, `app_routes.dart`, `app_router.dart`) y los mismos tokens,
para poder extraer `packages/dely_core` sin refactor mayor. Los primeros
candidatos a mudarse son `core/theme/`, `core/models/` y `core/widgets/`.
