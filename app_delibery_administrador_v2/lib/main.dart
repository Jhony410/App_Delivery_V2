import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase queda para una fase posterior: los repositorios ya están detrás
  // de interfaces, así que conectarlo no toca la interfaz.
  runApp(const DelyPunoAdminApp());
}
