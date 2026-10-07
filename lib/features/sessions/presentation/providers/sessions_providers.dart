import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/sessions_repository.dart';
import '../../domain/game_session.dart';

/// Una única instancia del repositorio de partidas.
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository();
});

/// Partidas en vivo donde participa el usuario actual.
final mySessionsProvider = StreamProvider.autoDispose<List<GameSession>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(sessionsRepositoryProvider).watchMySessions(user.uid);
});
