import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Avatar circular con iniciales sobre degradado, como en el diseño.
///
/// No hay fotografías en el diseño: siempre son iniciales, así que no existe
/// riesgo de `Image.network` sin `errorBuilder`.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.nombre,
    this.size = AppSizes.avatarMd,
    this.gradient = AppColors.brandGradient,
    this.online,
  });

  /// Avatar cuadrado con emoji, usado en las tarjetas de negocio.
  const AppAvatar.emoji({
    super.key,
    required String emoji,
    this.size = AppSizes.avatarXl,
    this.gradient = AppColors.brandGradient,
  }) : nombre = emoji,
       online = null;

  final String nombre;
  final double size;
  final Gradient gradient;

  /// Punto de conexión en la esquina inferior derecha. `null` lo oculta.
  final bool? online;

  /// Dos primeras iniciales del nombre («Rubén Mamani» → «RM»).
  static String iniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.characters.take(2).toString().toUpperCase();
    }
    return '${partes[0].characters.first}${partes[1].characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final texto = iniciales(nombre);
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      child: Text(
        texto,
        style: AppTextStyles.amountSmall.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: size * 0.35,
        ),
        maxLines: 1,
      ),
    );

    if (online == null) return avatar;

    final punto = size * 0.27;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: punto,
              height: punto,
              decoration: BoxDecoration(
                color: online! ? AppColors.success : AppColors.textMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuadro redondeado con un emoji dentro, para representar un negocio.
class AppEmojiTile extends StatelessWidget {
  const AppEmojiTile({
    super.key,
    required this.emoji,
    this.size = AppSizes.avatarXl,
    this.background = AppColors.surfaceSoft,
  });

  final String emoji;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Cuadro de icono coloreado que acompaña a un ítem de lista (incidencias,
/// tarjetas de acción).
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = AppSizes.avatarSm,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
