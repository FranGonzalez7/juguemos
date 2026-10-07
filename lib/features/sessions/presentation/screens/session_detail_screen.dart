import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collection/presentation/providers/collection_providers.dart';
import '../../../game_states/presentation/widgets/game_state_chip.dart';
import '../../domain/game_session.dart';

/// Detalle de una partida: datos de la partida y los juegos disponibles
/// en la ludoteca donde se juega. (El sugeridor automático llegará pronto.)
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGames = ref.watch(userCollectionProvider(session.libraryOwnerUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Juego decidido ---
          if (session.chosenGameName != null)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.casino),
                title: const Text('Vais a jugar a'),
                subtitle: Text(
                  session.chosenGameName!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // --- Cabecera con los datos de la partida ---
          Text(
            'En la ludoteca de ${session.libraryOwnerName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (session.availableMinutes != null)
                Chip(
                  avatar: const Icon(Icons.timer, size: 18),
                  label: Text('${session.availableMinutes} min'),
                ),
              if (session.desiredCategory != null)
                Chip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: Text(session.desiredCategory!),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Jugadores', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final player in session.players)
                Chip(
                  avatar: CircleAvatar(
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  label: Text(player.name),
                ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Otros juegos de esta ludoteca',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // --- Juegos de la ludoteca donde se juega ---
          asyncGames.when(
            data: (games) {
              if (games.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Esta ludoteca no tiene juegos.'),
                );
              }
              return Column(
                children: [
                  for (final game in games)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.casino),
                      title: Text(game.name),
                      subtitle: Text(
                        [
                          if (game.playersLabel != null)
                            '${game.playersLabel} jugadores',
                          if (game.playingTime != null)
                            '${game.playingTime} min',
                        ].join('  ·  '),
                      ),
                      trailing: GameStateChip(gameId: game.id),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}
