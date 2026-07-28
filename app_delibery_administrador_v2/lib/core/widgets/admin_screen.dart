import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'admin_shell.dart';
import 'app_dialogs.dart';

/// Envoltura común de las pantallas del shell.
///
/// Aporta la barra superior del diseño y el área de contenido. El contenido
/// desplazable siempre va en un scroll, así que ninguna pantalla puede
/// desbordar en vertical por muy estrecha que sea la ventana.
class AdminScreen extends StatelessWidget {
  const AdminScreen({
    super.key,
    required this.titulo,
    required this.child,
    required this.nombreOperador,
    required this.rolOperador,
    this.hintBusqueda,
    this.onBuscar,
    this.desplazable = true,
    this.padding,
  });

  /// Título que la barra superior muestra en pantallas estrechas.
  final String titulo;

  final Widget child;
  final String nombreOperador;
  final String rolOperador;

  /// Si es `null`, la barra superior muestra el título en lugar del buscador,
  /// como hacen los frames 03 y 10–13.
  final String? hintBusqueda;

  final ValueChanged<String>? onBuscar;

  /// `false` cuando la pantalla gestiona su propio desplazamiento (frames 02
  /// y 03, que reparten el alto entre columnas).
  final bool desplazable;

  final EdgeInsetsGeometry? padding;

  /// La ventana es demasiado estrecha para la barra lateral fija.
  static bool esCompacta(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppSizes.sidebarBreakpoint;

  @override
  Widget build(BuildContext context) {
    final compacta = esCompacta(context);
    final relleno =
        padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.xxl - 4,
          AppSpacing.pageVertical,
          AppSpacing.xxl - 4,
          30,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminTopBar(
          titulo: titulo,
          hintBusqueda: hintBusqueda ?? titulo,
          onBuscar: onBuscar ?? (_) {},
          nombreOperador: nombreOperador,
          rolOperador: rolOperador,
          onMenu: compacta ? () => Scaffold.of(context).openDrawer() : null,
          onNotificaciones: () => mostrarAviso(
            context,
            'No hay notificaciones nuevas para $nombreOperador.',
          ),
          onPerfil: () => mostrarAviso(
            context,
            'Sesión iniciada como $nombreOperador · $rolOperador.',
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.background,
            child: desplazable
                ? SingleChildScrollView(padding: relleno, child: child)
                : child,
          ),
        ),
      ],
    );
  }
}

/// Cuadrícula que reparte tarjetas en 4, 2 o 1 columna según el ancho, con la
/// separación de 16 px del diseño.
class AdminGrid extends StatelessWidget {
  const AdminGrid({
    super.key,
    required this.children,
    this.columnasMaximas = 4,
    this.anchoMinimo = 240,
  });

  final List<Widget> children;
  final int columnasMaximas;

  /// Ancho mínimo por celda antes de reducir el número de columnas.
  final double anchoMinimo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var columnas = (constraints.maxWidth / anchoMinimo).floor();
        columnas = columnas.clamp(1, columnasMaximas);
        final ancho =
            (constraints.maxWidth - AppSpacing.gridGap * (columnas - 1)) /
            columnas;

        return Wrap(
          spacing: AppSpacing.gridGap,
          runSpacing: AppSpacing.gridGap,
          children: [
            for (final child in children)
              SizedBox(
                width: ancho > 0 ? ancho : constraints.maxWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

/// Dos columnas con proporciones del diseño que se apilan al estrecharse.
class AdminTwoColumns extends StatelessWidget {
  const AdminTwoColumns({
    super.key,
    required this.izquierda,
    required this.derecha,
    this.flexIzquierda = 1,
    this.flexDerecha = 1,
    this.puntoDeCorte = AppSizes.sidebarBreakpoint,
  });

  final Widget izquierda;
  final Widget derecha;
  final int flexIzquierda;
  final int flexDerecha;
  final double puntoDeCorte;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < puntoDeCorte) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              izquierda,
              const SizedBox(height: AppSpacing.gridGap),
              derecha,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: flexIzquierda, child: izquierda),
            const SizedBox(width: AppSpacing.gridGap),
            Expanded(flex: flexDerecha, child: derecha),
          ],
        );
      },
    );
  }
}
