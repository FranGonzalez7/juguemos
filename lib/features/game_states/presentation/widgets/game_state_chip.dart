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
    // Sin marcar: pastilla discreta con solo un icono.
    if (state == null) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_reaction_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Con estado: pastilla de color con icono + texto.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: state.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.icon, size: 16, color: state.onColor),
          const SizedBox(width: 4),
          Text(
            state.label,
            style: TextStyle(
              color: state.onColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
