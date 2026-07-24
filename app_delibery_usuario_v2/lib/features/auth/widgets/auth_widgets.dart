import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Toggle Ingresar / Registrarme (segmented) usado en Login y Registro.
class AuthTabs extends StatelessWidget {
  const AuthTabs({super.key, required this.activeIndex, required this.onTap});

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1EE),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          _tab('Ingresar', 0),
          _tab('Registrarme', 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = index == activeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? AppTheme.cardShadow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.buttonSm.copyWith(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de formulario con etiqueta e ícono, al estilo del diseño.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.trailing,
    this.obscure = false,
    this.keyboardType,
    this.prefixText,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? trailing;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textMuted, size: 20)
                : null,
            prefixText: prefixText,
            suffixIcon: trailing,
          ),
        ),
      ],
    );
  }
}

/// Divisor "o continúa con".
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: AppText.caption),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Botón "Continuar con Google" (borde, fondo blanco).
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 1.5),
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFF4285F4)),
      label: Text(label,
          style: AppText.buttonSm.copyWith(color: AppColors.textPrimary)),
    );
  }
}
