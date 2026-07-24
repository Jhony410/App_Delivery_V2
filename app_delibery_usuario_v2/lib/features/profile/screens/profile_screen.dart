import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/session.dart';
import '../../../core/widgets/andean_pattern.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 08 · Perfil (pestaña). Datos del usuario, ayuda por WhatsApp, opciones,
/// acceso a /addresses y cerrar sesión -> /login.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(context),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoCard(),
                  const SizedBox(height: 16),
                  _whatsappCard(context),
                  const SizedBox(height: 16),
                  _optionsCard(context),
                  const SizedBox(height: 16),
                  _dangerCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 40, 20, 62),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Stack(
        children: [
          const AndeanPattern(),
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Text('AC',
                      style: AppText.h1.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 12),
                Text('Ana Condori',
                    style: AppText.h3.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _infoRow(Icons.phone_outlined, AppColors.greenLight, AppColors.primary,
              'Celular', '+51 987 654 321'),
          const Divider(height: 1),
          _infoRow(Icons.mail_outline, const Color(0xFFEDEBFB), AppColors.yape,
              'Correo', 'ana.condori@gmail.com'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color bg, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.small),
              Text(value, style: AppText.cardTitle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whatsappCard(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abriendo WhatsApp de soporte…')),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          border: Border.all(color: AppColors.greenBorder),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.whatsapp, shape: BoxShape.circle),
              child: const Icon(Icons.chat, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ayuda y soporte', style: AppText.cardTitle),
                  Text('¿Algún problema? Escríbenos por WhatsApp',
                      style: AppText.caption
                          .copyWith(color: const Color(0xFF4E7A62))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.whatsapp),
          ],
        ),
      ),
    );
  }

  Widget _optionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      // Material transparente: da un ancestro Material a los ListTile (evita el
      // warning de "ink splashes invisibles") sin pintar sobre la tarjeta.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            _optionRow(Icons.edit_outlined, AppColors.greenLight, AppColors.primary,
                'Editar mis datos', 'Nombre, celular, correo',
                onTap: () => _todo(context)),
            const Divider(height: 1),
            _optionRow(Icons.location_on_outlined, const Color(0xFFEDEBFB),
                AppColors.yape, 'Mis direcciones', 'Lugares guardados',
                onTap: () => context.push(AppRoutes.addresses)),
            const Divider(height: 1),
            _optionRow(Icons.confirmation_num_outlined, const Color(0xFFFEF3E2),
                const Color(0xFFD98324), 'Mis cupones', 'Disponibles y usados',
                onTap: () => _todo(context)),
            const Divider(height: 1),
            _optionRow(Icons.lock_outline, const Color(0xFFE9F0FB),
                const Color(0xFF2F6FD0), 'Cambiar contraseña',
                'Actualiza tu contraseña',
                onTap: () => _todo(context)),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(IconData icon, Color bg, Color color, String title,
      String subtitle,
      {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: AppText.cardTitle.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppText.small),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFC4C7C0)),
    );
  }

  Widget _dangerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            ListTile(
              onTap: () => _todo(context),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFFDECEC), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.danger, size: 18),
              ),
              title: Text('Eliminar cuenta',
                  style: AppText.cardTitle.copyWith(color: AppColors.danger)),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFEBB0B0)),
            ),
            const Divider(height: 1),
            ListTile(
              onTap: () => _logout(context),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted, shape: BoxShape.circle),
                child: const Icon(Icons.logout,
                    color: AppColors.textSecondary, size: 18),
              ),
              title: Text('Cerrar sesión', style: AppText.cardTitle),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await Session.instance.signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  void _todo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponible próximamente')),
    );
  }
}
