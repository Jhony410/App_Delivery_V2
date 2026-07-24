# DelyPuno — Mapa de rutas

Paquete de routing: **go_router 17.3.0**.
Fuente única de verdad: `lib/router/app_routes.dart` (constantes) y
`lib/router/app_router.dart` (configuración de `GoRouter`).

- Las 4 pestañas (`/home`, `/search`, `/history`, `/profile`) viven en un
  `StatefulShellRoute.indexedStack` que **preserva el estado** de cada tab.
- Todo lo demás son rutas de pantalla completa que se apilan **sobre** el shell
  (cubren la barra inferior) usando el navigator raíz.
- `errorBuilder` + `onException` globales redirigen cualquier ruta inexistente o
  fallo de navegación a **`/not-found`** (pantalla amigable con botón a Inicio).
  Nunca aparece la pantalla roja de Flutter ni una pantalla en blanco.

| # | Pantalla | Ruta | Entra desde | Sale hacia |
|---|----------|------|-------------|------------|
| 1 | Splash | `/splash` | Arranque (`initialLocation`) | `/onboarding`, `/login` o `/home` (según sesión) |
| 2 | Onboarding | `/onboarding` | `/splash` (primera vez) | `/login` ("Empezar" / "Saltar") |
| 3 | Login | `/login` | `/splash`, `/register` (toggle/enlace/cerrar), `/profile` (cerrar sesión) | `/home` (login/Google), `/register` |
| 4 | Registro | `/register` | `/login` (toggle/enlace) | `/home` (crear cuenta/Google), `/login` (volver/toggle) |
| 5 | Home (tab) | `/home` | `/splash`, login/registro OK, tab Inicio, `/rating` (enviar), `/tracking` (volver), `/not-found` | `/search`, `/history`, `/my-town`, `/category/:id`, `/business/:id` |
| 6 | Búsqueda (tab) | `/search` | tab Búsqueda, `/home` (buscador), `/category` (buscar) | `/business/:businessId` (resultado) |
| 7 | Historial (tab) | `/history` | tab Pedidos, `/home` (campana) | `/tracking/:orderId` (activo), `/rating/:orderId` (completado) |
| 8 | Perfil (tab) | `/profile` | tab Perfil | `/addresses`, `/login` (cerrar sesión) |
| 9 | Categoría | `/category/:categoryId` | `/home` (categorías, promo, "Ver todo") | `/business/:businessId`, `/search`, volver → `/home` |
| 10 | Detalle de Negocio | `/business/:businessId` | `/home` (carruseles), `/search`, `/category` | `/product/:businessId/:productId`, `/checkout` (barra flotante), volver |
| 11 | Detalle de Producto | `/product/:businessId/:productId` | `/business/:businessId` | Hoja checkout **modal** (→ `/tracking` al confirmar), volver → negocio |
| 12 | Confirmar Pedido | `/checkout` | Barra flotante de carrito (Home, Categoría, Negocio) | `/tracking/:orderId` (confirmar), `/addresses` ("Cambiar"), cerrar (tocar fuera) |
| 13 | Seguimiento | `/tracking/:orderId` | `/history` (seguir), `/checkout` (confirmar), hoja de producto | `/rating/:orderId` (entrega), `/home` (volver) |
| 14 | Calificación | `/rating/:orderId` | `/history` (calificar), `/tracking` (confirmar entrega) | `/home` (enviar / cerrar) |
| 15 | Mis Direcciones | `/addresses` | `/profile`, `/checkout` ("Cambiar"), `/adjust-map` (confirmar), `/add-address` (guardar) | `/add-address` (FAB / editar), `/adjust-map` (indirecto), volver |
| 16 | Agregar Dirección | `/add-address` | `/addresses` (FAB "+" / editar) | `/adjust-map` (ajustar / guardar), volver → `/addresses` |
| 17 | Ajustar en Mapa | `/adjust-map` | `/add-address` (`from=addAddress` ajustar · `from=addresses` guardar) | `/addresses` (confirmar) o volver a `/add-address` según origen |
| 18 | Mi Pueblo | `/my-town` | `/home` (header de dirección) | `/home` (volver) |
| — | No encontrado | `/not-found` | `errorBuilder` / `onException` (ruta inválida) | `/home` ("Volver al inicio") |

## Estados que NO son rutas (widgets condicionales)

- **Error sin conexión / carga de catálogo / no disponible**: `RetryableError`
  (`lib/core/widgets/states.dart`). Reintentar recarga el estado normal de la
  **misma** pantalla — nunca navega. Usados en Home, Categoría y Detalle de
  Negocio.
- **Estado vacío** (`EmptyState`): Búsqueda sin resultados / listas vacías.
- **Barra flotante de carrito** (`FloatingCartBar`): widget superpuesto en Home,
  Categoría, Detalle de Negocio y Detalle de Producto mientras el carrito tenga
  ítems; al tocarla abre `/checkout`.

## Verificación

- Cada ruta tiene **al menos una entrada y una salida** (tabla anterior).
- Todo `context.go/push` del código usa constantes de `AppRoutes` (sin strings a
  mano) y apunta a una de las rutas declaradas — verificado 1:1.
- `flutter analyze`: **sin issues**. `flutter test`: **2/2 en verde**.

## Flujos simulados (sin rupturas)

1. Splash → Login → Home → Categoría → Negocio → Producto → Checkout →
   Seguimiento → Calificación → Home. ✅
2. Perfil → Direcciones → Agregar dirección → Ajustar mapa → Direcciones. ✅
