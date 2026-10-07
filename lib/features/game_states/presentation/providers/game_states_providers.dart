import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/game_states_repository.dart';
import '../../domain/game_state.dart';

/// Una única instancia del repositorio de estados para toda la app.
final gameStatesRepositoryProvider = Provider<GameStatesRepository>((ref) {
  return GameStatesRepository();
});

/// Mapa en vivo con MIS estados: { gameId: GameState }.
/// Cualquier ficha de juego (en mi ludoteca o en la de un amigo) mira aquí
/// cuál es mi opinión sobre ese juego.
final myGameStatesProvider =
    StreamProvider.autoDispose<Map<String, GameState>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const {});
  return ref.watch(gameStatesRepositoryProvider).watchStates(user.uid);
});
