import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Definición de una columna de [AppDataTable].
class AppTableColumn {
  const AppTableColumn(
    this.label, {
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.hideWhenStacked = false,
  });

  /// Columna de ancho fijo (`grid-template-columns:82px …`).
  const AppTableColumn.fixed(
    this.label, {
    required double this.width,
    this.alignment = Alignment.centerLeft,
    this.hideWhenStacked = false,
  }) : flex = 0;

  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;

  /// En el modo apilado esta columna no se repite (por ejemplo, la que ya
  /// hace de título de la tarjeta).
  final bool hideWhenStacked;
}

/// Una fila de [AppDataTable]. `cells` debe tener tantos elementos como
/// columnas declaradas.
class AppTableRow {
  const AppTableRow({
    required this.cells,
    this.onTap,
    this.selected = false,
    this.accentColor,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;

  /// Fila resaltada en verde claro, como el pedido abierto en el frame 02.
  final bool selected;

  /// Borde izquierdo de color para señalar una fila con incidencia.
  final Color? accentColor;
}

/// Tabla del panel.
///
/// Por encima de [AppSizes.sidebarBreakpoint] se dibuja como la cuadrícula del
/// diseño: cabecera gris, filas separadas por `#F3F5F1` y la fila activa en
/// verde claro. Por debajo, cada fila se apila en una tarjeta etiquetada, que
/// es la única forma de que seis columnas quepan en 360 px sin desbordar.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.stackedTitleIndex = 0,
    this.stackedTrailingIndex,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  /// Celda que hace de título en el modo apilado.
  final int stackedTitleIndex;

  /// Celda que se muestra a la derecha del título en el modo apilado
  /// (normalmente la insignia de estado).
  final int? stackedTrailingIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final apilada = constraints.maxWidth < AppSizes.sidebarBreakpoint;
        if (apilada) return _TablaApilada(table: this);
        return _TablaAmplia(table: this);
      },
    );
  }
}

class _TablaAmplia extends StatelessWidget {
  const _TablaAmplia({required this.table});

  final AppDataTable table;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FilaCabecera(columns: table.columns),
              for (var i = 0; i < table.rows.length; i++)
                _FilaAmplia(
                  columns: table.columns,
                  row: table.rows[i],
                  ultima: i == table.rows.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaCabecera extends StatelessWidget {
  const _FilaCabecera({required this.columns});

  final List<AppTableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPaddingTight,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            _celda(
              columns[i],
              Align(
                alignment: columns[i].alignment,
                child: Text(
                  columns[i].label.toUpperCase(),
                  style: AppTextStyles.tableHeader.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilaAmplia extends StatelessWidget {
  const _FilaAmplia({
    required this.columns,
    required this.row,
    required this.ultima,
  });

  final List<AppTableColumn> columns;
  final AppTableRow row;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    final contenido = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPaddingTight,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: row.selected ? AppColors.primarySoft : AppColors.surface,
        border: Border(
          bottom: ultima
              ? BorderSide.none
              : const BorderSide(color: AppColors.divider),
          left: row.accentColor == null
              ? BorderSide.none
              : BorderSide(color: row.accentColor!, width: 3),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            _celda(
              columns[i],
              Align(alignment: columns[i].alignment, child: row.cells[i]),
            ),
          ],
        ],
      ),
    );

    if (row.onTap == null) return contenido;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: row.onTap, child: contenido),
    );
  }
}

class _TablaApilada extends StatelessWidget {
  const _TablaApilada({required this.table});

  final AppDataTable table;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < table.rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _TarjetaFila(table: table, row: table.rows[i]),
        ],
      ],
    );
  }
}

class _TarjetaFila extends StatelessWidget {
  const _TarjetaFila({required this.table, required this.row});

  final AppDataTable table;
  final AppTableRow row;

  @override
  Widget build(BuildContext context) {
    final titulo = table.stackedTitleIndex;
    final trailing = table.stackedTrailingIndex;

    final contenido = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: row.selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: row.accentColor ?? AppColors.border,
          width: row.accentColor == null ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: row.cells[titulo]),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                row.cells[trailing],
              ],
            ],
          ),
          for (var i = 0; i < table.columns.length; i++)
            if (i != titulo &&
                i != trailing &&
                !table.columns[i].hideWhenStacked) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      table.columns[i].label,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: row.cells[i],
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: AppColors.cardShadow,
      ),
      child: row.onTap == null
          ? contenido
          : Material(
              color: Colors.transparent,
              borderRadius: AppRadius.card,
              child: InkWell(
                onTap: row.onTap,
                borderRadius: AppRadius.card,
                child: contenido,
              ),
            ),
    );
  }
}

Widget _celda(AppTableColumn column, Widget child) {
  if (column.width != null) return SizedBox(width: column.width, child: child);
  return Expanded(flex: column.flex, child: child);
}

/// Texto de celda con truncado seguro. Todas las celdas de texto de las tablas
/// pasan por aquí para que ninguna cadena larga provoque un desbordamiento.
class AppTableText extends StatelessWidget {
  const AppTableText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines = 1,
  });

  /// Celda de nombre (`font:600 13px Inter`).
  const AppTableText.strong(
    this.text, {
    super.key,
    this.color,
    this.maxLines = 1,
  }) : style = null;

  final String text;
  final TextStyle? style;
  final Color? color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTextStyles.bodySmall;
    return Text(
      text,
      style: color == null ? base : base.copyWith(color: color),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Paginación del diseño: «Mostrando 7 de 186» + páginas numeradas.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.mostrando,
    required this.total,
    required this.paginaActual,
    required this.paginas,
    required this.onPagina,
  });

  final int mostrando;
  final int total;
  final int paginaActual;
  final int paginas;
  final ValueChanged<int> onPagina;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Mostrando $mostrando de $total',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        for (var i = 1; i <= paginas; i++) ...[
          if (i > 1) const SizedBox(width: AppSpacing.xs),
          _BotonPagina(
            numero: i,
            activa: i == paginaActual,
            onTap: () => onPagina(i),
          ),
        ],
      ],
    );
  }
}

class _BotonPagina extends StatelessWidget {
  const _BotonPagina({
    required this.numero,
    required this.activa,
    required this.onTap,
  });

  final int numero;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activa ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: activa ? null : Border.all(color: AppColors.borderStrong),
          ),
          child: Text(
            '$numero',
            style:
                (activa ? AppTextStyles.labelBold : AppTextStyles.labelStrong)
                    .copyWith(
                      color: activa
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
          ),
        ),
      ),
    );
  }
}
