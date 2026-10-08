import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/game_state.dart';
import '../providers/game_states_providers.dart';

/// Chip que muestra MI estado sobre un juego y, al tocarlo, abre un menú
/// para cambiarlo. Siempre refleja la opinión del usuario actual, da igual
/// en qué ludoteca se muestre.
class GameStateChip extends ConsumerWidget {
  const GameStateChip({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(myGameStatesProvider).value ?? const {};
    final current = states[gameId];

    return PopupMenuButton<Object?>(
      tooltip: 'Tu valoración',
      // Usamos un centinela para la opción "quitar", y GameState para el resto.
      onSelected: (selected) async {
        final user = ref.read(authStateProvider).value;
        if (user == null) return;
        final repo = ref.read(gameStatesRepositoryProvider);
        if (selected is GameState) {
          await repo.setState(user.uid, gameId, selected);
        } else {
          await repo.clearState(user.uid, gameId);
        }
      },
      itemBuilder: (context) => [
        for (final s in GameState.values)
          PopupMenuItem<Object?>(
            value: s,
            child: Row(
              children: [
                Icon(s.icon, color: s.color, size: 20),
                const SizedBox(width: 8),
                Text(s.label),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<Object?>(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.remove_circle_outline, size: 20),
              SizedBox(width: 8),
              Text('Quitar marca'),
            ],
          ),
        ),
      ],
      child: _pill(context, current),
    );
  }

  Widget _pill(BuildContext context, GameState? state) {
    // Mostramos SOLO un dado del color del estado (verde / amarillo / rojo).
    // Sin marcar: un dado tenue (contorno) que invita a tocar para valorar.
    final color = state?.color ?? Theme.of(context).colorScheme.outline;
    final icon = state == null ? Icons.casino_outlined : Icons.casino;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
