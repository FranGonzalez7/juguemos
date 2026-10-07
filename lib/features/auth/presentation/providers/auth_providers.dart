import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

/// Provider que nos da UNA única instancia del repositorio de auth,
/// disponible para toda la app. Cualquier pantalla puede pedírselo con `ref`.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider que "escucha" el estado de sesión en tiempo real.
/// La UI observa esto para saber al instante si hay usuario o no.
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});
