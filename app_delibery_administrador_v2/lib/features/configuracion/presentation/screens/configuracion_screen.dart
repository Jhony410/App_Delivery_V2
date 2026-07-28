import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../data/models/configuracion_operativa.dart';
import '../../providers/configuracion_provider.dart';
import '../widgets/hojas_configuracion.dart';

/// Frame 13 · Configuración.
///
/// Costos de envío, comisiones, roles del equipo y operación general. Los
/// cambios se acumulan y solo se aplican al pulsar «Guardar cambios».
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ConfiguracionProvider>().cargar();
    });
  }

  Future<void> _guardar() async {
    final provider = context.read<ConfiguracionProvider>();
    final ok = await provider.guardar();
    if (!mounted) return;
    mostrarAviso(
      context,
      ok
          ? 'Configuración guardada. Los cambios ya rigen para toda la '
                'operación.'
          : provider.error ?? 'No se pudo guardar la configuración.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<ConfiguracionProvider>();
    final configuracion = provider.configuracion;

    return AdminScreen(
      titulo: 'Configuración',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            titulo: 'Configuración',
            subtitulo: provider.hayCambios
                ? 'Tienes cambios sin guardar'
                : null,
            acciones: [
              AppTextActionButton(
                label: 'Descartar',
                color: AppColors.textPrimary,
                height: AppSizes.controlHeight,
                onPressed: provider.hayCambios
                    ? () {
                        provider.descartar();
                        mostrarAviso(context, 'Cambios descartados.');
                      }
                    : null,
              ),
              AppButton.primary(
                label: 'Guardar cambios',
                height: AppSizes.controlHeight,
                onPressed: provider.hayCambios ? _guardar : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: configuracion == null,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Sin configuración',
            mensajeVacio: 'No se pudo leer la configuración del panel.',
            iconoVacio: Icons.settings_outlined,
            skeletons: 3,
            builder: (context) => _Contenido(configuracion: configuracion!),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.configuracion});

  final ConfiguracionOperativa configuracion;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ConfiguracionProvider>();

    Future<void> editarTarifa(ParametroTarifa parametro) async {
      final valor = await mostrarHoja<double>(
        context,
        builder: (_) => HojaEditarTarifa(parametro: parametro),
      );
      if (valor == null || !context.mounted) return;
      provider.cambiarTarifa(clave: parametro.clave, valor: valor);
      mostrarAviso(
        context,
        '${parametro.titulo} pendiente de guardar. Pulsa «Guardar cambios».',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminTwoColumns(
          izquierda: AppSectionCard(
            title: 'Costos de envío',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final parametro in configuracion.costosEnvio)
                  AppSettingRow(
                    title: parametro.titulo,
                    subtitle: parametro.descripcion,
                    value: parametro.clave == 'recargo_pico'
                        ? '+ ${parametro.valorTexto}'
                        : parametro.valorTexto,
                    onEdit: () => editarTarifa(parametro),
                  ),
              ],
            ),
          ),
          derecha: AppSectionCard(
            title: 'Comisiones',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final parametro in configuracion.comisiones)
                  AppSettingRow(
                    title: parametro.titulo,
                    subtitle: parametro.descripcion,
                    value: parametro.valorTexto,
                    onEdit: () => editarTarifa(parametro),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AppSectionCard(
          title: 'Roles del equipo',
          trailing: AppTextActionButton(
            label: '+ Invitar',
            height: 34,
            onPressed: () => mostrarHoja<void>(
              context,
              builder: (_) =>
                  ChangeNotifierProvider<ConfiguracionProvider>.value(
                    value: provider,
                    child: const HojaInvitarMiembro(),
                  ),
            ),
          ),
          child: AppDataTable(
            stackedTitleIndex: 0,
            stackedTrailingIndex: 1,
            columns: const [
              AppTableColumn('Miembro', flex: 12),
              AppTableColumn.fixed('Rol', width: 130),
              AppTableColumn('Permisos', flex: 12),
              AppTableColumn.fixed(
                '',
                width: 78,
                alignment: Alignment.centerRight,
              ),
            ],
            rows: [
              for (final miembro in configuracion.equipo)
                AppTableRow(
                  cells: [
                    Row(
                      children: [
                        AppAvatar(nombre: miembro.nombre),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                miembro.nombre,
                                style: AppTextStyles.bodySmallStrong,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                miembro.correo,
                                style: AppTextStyles.captionSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppBadge(
                      label: miembro.rol.etiqueta,
                      tone: switch (miembro.rol) {
                        RolEquipo.adminTotal => AppBadgeTone.okStrong,
                        RolEquipo.operaciones => AppBadgeTone.ok,
                        RolEquipo.soporte => AppBadgeTone.highlight,
                      },
                      dense: true,
                    ),
                    AppTableText(
                      miembro.rol.permisos,
                      color: AppColors.textSecondary,
                    ),
                    AppTextActionButton(
                      label: 'Editar',
                      height: 34,
                      onPressed: () async {
                        final rol = await mostrarHoja<RolEquipo>(
                          context,
                          builder: (_) => HojaEditarRol(miembro: miembro),
                        );
                        if (rol == null || !context.mounted) return;
                        provider.cambiarRol(miembro.id, rol);
                        mostrarAviso(
                          context,
                          '${miembro.nombre} pasará a ${rol.etiqueta} al '
                          'guardar los cambios.',
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AppSectionCard(
          title: 'Operación general',
          child: AdminGrid(
            columnasMaximas: 2,
            anchoMinimo: 320,
            children: [
              for (final ajuste in configuracion.ajustes)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AppSwitchTile(
                    title: ajuste.titulo,
                    subtitle: ajuste.descripcion,
                    value: ajuste.activo,
                    onChanged: (valor) =>
                        provider.alternarAjuste(ajuste.clave, valor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
