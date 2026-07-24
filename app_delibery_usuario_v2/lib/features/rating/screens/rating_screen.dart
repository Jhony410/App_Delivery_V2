import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 14 · Calificación. Califica comercio y repartidor + comentario. Al enviar
/// -> /home. Cerrar (X) -> /home.
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _businessStars = 4;
  int _courierStars = 5;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Gracias por tu calificación!')),
    );
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.close, color: AppColors.textPlaceholder),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                          color: Color(0xFFE8F7EE), shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text('¡Pedido entregado!', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text('Cuéntanos cómo estuvo tu experiencia',
                        style: AppText.bodySecondary, textAlign: TextAlign.center),
                    const SizedBox(height: 26),
                    _ratingCard(
                      icon: Icons.ramen_dining,
                      gradient: const [Color(0xFFF2C98F), Color(0xFFD98324)],
                      title: 'Pollería El Cholo',
                      stars: _businessStars,
                      onChanged: (v) => setState(() => _businessStars = v),
                    ),
                    const SizedBox(height: 16),
                    _ratingCard(
                      icon: Icons.person,
                      gradient: const [Color(0xFFBEE6CE), Color(0xFF5FB98A)],
                      title: 'Miguel Q. · Repartidor',
                      stars: _courierStars,
                      onChanged: (v) => setState(() => _courierStars = v),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 70),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted2,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: TextField(
                        maxLines: 3,
                        style: AppText.bodySecondary,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Escribe un comentario (opcional)…',
                          hintStyle: AppText.bodySecondary
                              .copyWith(color: AppColors.textPlaceholder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Enviar calificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingCard({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required int stars,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppText.cardTitle),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      i <= stars ? Icons.star : Icons.star_border,
                      color: i <= stars ? AppColors.star : const Color(0xFFDEE2DC),
                      size: 34,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
