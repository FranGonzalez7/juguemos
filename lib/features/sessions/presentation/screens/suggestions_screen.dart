import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../collection/domain/board_game.dart';
import '../../../collection/presentation/providers/collection_providers.dart';
import '../../../game_states/domain/game_state.dart';
import '../../../game_states/presentation/providers/game_states_providers.dart';
import '../../domain/game_session.dart';
import '../providers/sessions_providers.dart';

/// Resultado del sugeridor para un juego concreto.
class _Suggestion {
  _Suggestion({required this.game, required this.mehBy});
  final BoardGame game;
  final List<String> mehBy; // nombres de quienes lo marcaron "Meh"
}

/// Paso 2: muestra los juegos que ENCAJAN con los datos de la partida y deja
/// elegir uno. Al elegir, se crea la partida con ese juego decidido.
class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({
    super.key,
    required this.libraryOwnerUid,
    required this.libraryOwnerName,
    required this.players,
    required this.availableMinutes,
    required this.desiredCategory,
  });

  final String libraryOwnerUid;
  final String libraryOwnerName;
  final List<SessionPlayer> players;
  final int? availableMinutes;
  final String? desiredCategory;

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  late Future<List<_Suggestion>> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _computeSuggestions();
  }

  /// El sugeridor (versión en la app): filtra la ludoteca por jugadores,
  /// tiempo y categoría, y descarta los juegos vetados por algún presente.
  Future<List<_Suggestion>> _computeSuggestions() async {
    final collectionRepo = ref.read(collectionRepositoryProvider);
    final statesRepo = ref.read(gameStatesRepositoryProvider);

    // Juegos de la ludoteca donde se juega.
    final games = await collectionRepo.getCollection(widget.libraryOwnerUid);

    // Estados (opiniones) de cada jugador presente.
    final statesByPlayer = <String, Map<String, GameState>>{};
    for (final p in widget.players) {
      statesByPlayer[p.uid] = await statesRepo.getStates(p.uid);
    }

    final numPlayers = widget.players.length;
    final category = widget.desiredCategory?.toLowerCase();

    final result = <_Suggestion>[];
    for (final game in games) {
      // Nº de jugadores.
      if (game.minPlayers != null && numPlayers < game.minPlayers!) continue;
      if (game.maxPlayers != null && numPlayers > game.maxPlayers!) continue;

      // Tiempo disponible.
      if (widget.availableMinutes != null &&
          game.playingTime != null &&
          game.playingTime! > widget.availableMinutes!) {
        continue;
      }

      // Categoría deseada (si se indicó).
      if (category != null && category.isNotEmpty) {
        final tagsLower = game.customTags.map((t) => t.toLowerCase());
        if (!tagsLower.contains(category)) continue;
      }

      // Vetos y "meh" de los presentes.
      final vetoedBy = <String>[];
      final mehBy = <String>[];
      for (final p in widget.players) {
        final state = statesByPlayer[p.uid]?[game.id];
        if (state == GameState.veto) {
          vetoedBy.add(p.name);
        } else if (state == GameState.meh) {
          mehBy.add(p.name);
        }
      }
      if (vetoedBy.isNotEmpty) continue; // descartado por veto

      result.add(_Suggestion(game: game, mehBy: mehBy));
    }

    // Orden: primero los que no tienen ningún "meh", luego por nombre.
    result.sort((a, b) {
      if (a.mehBy.isEmpty != b.mehBy.isEmpty) {
        return a.mehBy.isEmpty ? -1 : 1;
      }
      return a.game.name.compareTo(b.game.name);
    });

    return result;
  }

  Future<void> _choose(BoardGame game) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final session = GameSession(
      hostUid: me.uid,
      libraryOwnerUid: widget.libraryOwnerUid,
      libraryOwnerName: widget.libraryOwnerName,
      players: widget.players,
      availableMinutes: widget.availableMinutes,
      desiredCategory: widget.desiredCategory,
      chosenGameId: game.id,
      chosenGameName: game.name,
    );

    try {
      await ref.read(sessionsRepositoryProvider).createSession(session);
      // Volvemos a la lista de partidas (raíz del shell).
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        SnackBar(content: Text('¡Partida creada: ${game.name}!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          SnackBar(content: Text('No se pudo crear la partida: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige el juego')),
      body: Stack(
        children: [
          FutureBuilder<List<_Suggestion>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final suggestions = snapshot.data ?? const [];
              if (suggestions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Ningún juego de la ludoteca de ${widget.libraryOwnerName} '
                      'encaja con esos jugadores, tiempo y categoría.\n\n'
                      'Vuelve atrás y prueba a ajustar los filtros.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              return ListView.separated(
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = suggestions[index];
                  final game = s.game;
                  final info = [
                    if (game.playersLabel != null)
                      '${game.playersLabel} jugadores',
                    if (game.playingTime != null) '${game.playingTime} min',
                    if (game.customTags.isNotEmpty) game.customTags.join(', '),
                  ].join('  ·  ');

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.casino)),
                    title: Text(game.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.isNotEmpty) Text(info),
                        if (s.mehBy.isNotEmpty)
                          Text(
                            'Meh para: ${s.mehBy.join(', ')}',
                            style: const TextStyle(color: Color(0xFFF9A825)),
                          ),
                      ],
                    ),
                    isThreeLine: s.mehBy.isNotEmpty,
                    trailing: FilledButton(
                      onPressed: _saving ? null : () => _choose(game),
                      child: const Text('Elegir'),
                    ),
                  );
                },
              );
            },
          ),
          if (_saving)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
