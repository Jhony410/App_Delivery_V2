import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../data/demo_data.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// Frame 03 — Verificación SMS.
///
/// Código de 4 dígitos con reenvío a los 60 s. Al verificar avanza a los
/// permisos de ubicación.
class SmsVerificationScreen extends StatefulWidget {
  const SmsVerificationScreen({super.key});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  static const int _codeLength = 4;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 60;

  bool get _complete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  String get _countdownLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    onTap: () => context.go(AppRoutes.login),
                    borderRadius: BorderRadius.circular(13),
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.sms_outlined, size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 22),

              Text('Verifica tu celular', style: AppText.display(24, letterSpacing: -0.3)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: AppText.body(14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Enviamos un código de 4 dígitos al\n'),
                    TextSpan(
                      text: DemoData.riderPhone,
                      style: AppText.body(14, weight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),

              Row(
                children: [
                  for (var i = 0; i < _codeLength; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _CodeBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (value) => _onDigitChanged(i, value),
                    )),
                  ],
                ],
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Verificar',
                // Deshabilitado hasta completar el código: el diseño muestra
                // el estado gris del frame 27 en esta situación.
                onPressed: _complete ? () => context.go(AppRoutes.locationPermission) : null,
              ),
              const SizedBox(height: 22),

              Center(
                child: _secondsLeft > 0
                    ? Text.rich(
                        TextSpan(
                          style: AppText.body(13),
                          children: [
                            const TextSpan(text: 'Reenviar código en '),
                            TextSpan(
                              text: _countdownLabel,
                              style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: _startResendCountdown,
                        child: Text(
                          'Reenviar código',
                          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Casilla de un dígito, con el resaltado verde del diseño cuando tiene foco.
class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.controller, required this.focusNode, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final active = focusNode.hasFocus || controller.text.isNotEmpty;
        return Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: active
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), spreadRadius: 4)]
                : null,
          ),
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppText.display(26),
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isCollapsed: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
