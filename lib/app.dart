import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';

/// Widget raíz de la aplicación.
/// Aquí definimos el título, el tema visual y la pantalla inicial.
class JuguemosApp extends StatelessWidget {
  const JuguemosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juguemos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // AuthGate decide qué pantalla mostrar según si hay sesión o no.
      home: const AuthGate(),
    );
  }
}
