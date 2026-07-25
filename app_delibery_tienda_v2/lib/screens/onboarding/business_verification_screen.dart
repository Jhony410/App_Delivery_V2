import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// **Pantalla 04 · Verificación del negocio** ("Datos de tu negocio").
///
/// Llega desde el enlace "Regístralo" del Login. Al pulsar "Continuar" registra
/// el local en `AppState` y entra a Inicio, ya dentro del shell con bottom nav.
class BusinessVerificationScreen extends StatefulWidget {
  const BusinessVerificationScreen({super.key});

  @override
  State<BusinessVerificationScreen> createState() =>
      _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState
    extends State<BusinessVerificationScreen> {
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _documento = TextEditingController();

  /// Rubros ofrecidos. Arranca con los tres del canvas y crece con los que el
  /// comerciante escriba en "Otro": Puno tiene ferreterías, librerías,
  /// veterinarias y mucho más que no cabe en tres categorías fijas.
  late final List<String> _rubros = [...DemoData.categories];
  int _rubro = 0;

  bool get _completo =>
      _nombre.text.trim().isNotEmpty &&
      _direccion.text.trim().isNotEmpty &&
      _documento.text.trim().length >= 8;

  @override
  void initState() {
    super.initState();
    for (final c in [_nombre, _direccion, _documento]) {
      c.addListener(() => setState(() {}));
    }
  }

  void _continuar() {
    AppStateScope.read(context).registrarNegocio(
      BusinessProfile(
        name: _nombre.text.trim(),
        category: _rubros[_rubro],
        address: _direccion.text.trim(),
        taxId: _documento.text.trim(),
        schedule: DemoData.business.schedule,
        whatsapp: DemoData.business.whatsapp,
      ),
    );
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _documento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Datos de tu negocio'),
        leading: IconButton(
          // Normalmente hay Login debajo; si se entró directo por URL, no.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver al login',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: const LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Paso 2/4',
                  style: AppText.display(
                    14,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        children: [
          Text('Nombre del negocio', style: AppText.fieldLabel()),
          const SizedBox(height: 8),
          _campo(_nombre, hint: 'Pollería El Cholo'),
          const SizedBox(height: 20),

          Text('Rubro', style: AppText.fieldLabel()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _rubros.length; i++)
                _chipRubro(_rubros[i], i),
              _chipOtro(),
            ],
          ),
          const SizedBox(height: 20),

          Text('Dirección', style: AppText.fieldLabel()),
          const SizedBox(height: 8),
          _campo(
            _direccion,
            hint: 'Jr. Puno 214, Puno',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 20),

          Text('RUC o DNI', style: AppText.fieldLabel()),
          const SizedBox(height: 8),
          _campo(
            _documento,
            hint: '20605XXXXXX',
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 28),

          PrimaryButton(
            label: 'Continuar',
            onPressed: _completo ? _continuar : null,
          ),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController controller, {
    required String hint,
    IconData? icon,
    TextInputType? keyboard,
  }) {
    return Container(
      height: AppTheme.hField,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: AppText.display(17, weight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: AppText.body(
                  16,
                  weight: FontWeight.w500,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip de acción "Otro": abre el diálogo para escribir un rubro propio.
  ///
  /// Lleva el ícono `+` y el borde rojo sin relleno para que se lea como una
  /// acción, no como una categoría más ya seleccionable.
  Widget _chipOtro() {
    return GestureDetector(
      onTap: _pedirRubroNuevo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Otro',
              style: AppText.body(
                14,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pide un rubro escrito a mano, lo agrega a la lista y lo deja marcado.
  Future<void> _pedirRubroNuevo() async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogoRubroNuevo(),
    );

    if (nuevo == null || nuevo.isEmpty || !mounted) return;

    // El emoji 🏪 mantiene la consistencia visual con los rubros del canvas,
    // que también llevan uno delante.
    final etiqueta = '🏪 $nuevo';

    // Si ya existe (mismo texto, mayúsculas aparte), solo se selecciona.
    final existente = _rubros.indexWhere(
      (r) => r.toLowerCase() == etiqueta.toLowerCase(),
    );

    setState(() {
      if (existente != -1) {
        _rubro = existente;
      } else {
        _rubros.add(etiqueta);
        _rubro = _rubros.length - 1;
      }
    });
  }

  Widget _chipRubro(String etiqueta, int index) {
    final activo = index == _rubro;

    return GestureDetector(
      onTap: () => setState(() => _rubro = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : AppColors.card,
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          etiqueta,
          style: AppText.body(
            14,
            weight: activo ? FontWeight.w700 : FontWeight.w600,
            color: activo ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Diálogo para escribir un rubro que no está en la lista.
///
/// Es un `StatefulWidget` propio, y no un `AlertDialog` armado en línea, para
/// que sea dueño de su `TextEditingController` y lo libere en su `dispose`.
/// Desecharlo justo después de `showDialog` lo destruía mientras el diálogo
/// todavía se estaba cerrando, y la reconstrucción del `TextField` reventaba.
class _DialogoRubroNuevo extends StatefulWidget {
  const _DialogoRubroNuevo();

  @override
  State<_DialogoRubroNuevo> createState() => _DialogoRubroNuevoState();
}

class _DialogoRubroNuevoState extends State<_DialogoRubroNuevo> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aceptar() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.rCard),
      ),
      title: Text(
        '¿Cuál es tu rubro?',
        style: AppText.display(20, weight: FontWeight.w700),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        style: AppText.display(17, weight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Ferretería, librería, veterinaria…',
          hintStyle: AppText.body(
            16,
            weight: FontWeight.w500,
            color: AppColors.textHint,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.rField),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.rField),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _aceptar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: AppText.body(16, weight: FontWeight.w600),
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _aceptar,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppText.body(16, weight: FontWeight.w700),
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
