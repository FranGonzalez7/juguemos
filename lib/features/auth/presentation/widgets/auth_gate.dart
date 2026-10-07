import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_shell.dart';
import '../providers/auth_providers.dart';
import '../screens/login_screen.dart';

/// El "portero" de la app: decide qué pantalla mostrar según el estado de sesión.
///  - Mientras carga   -> un spinner
///  - Si hay usuario    -> el shell principal (barra inferior + pestañas)
///  - Si no hay usuario -> la pantalla de Login
///
/// Lo bueno de esto: cuando el usuario entra o sale, el stream avisa y
/// esta pantalla se reconstruye sola. No tenemos que navegar a mano.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeShell();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
