import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../collection/domain/board_game.dart';
import '../../../collection/presentation/providers/collection_providers.dart';
import '../../../game_states/presentation/widgets/game_state_chip.dart';
import '../../domain/app_user.dart';

/// Perfil de un amigo: muestra su ludoteca y su wishlist en SOLO LECTURA.
/// Reutiliza los providers `userCollectionProvider` / `userWishlistProvider`
/// pasándoles el uid del amigo.
class FriendProfileScreen extends ConsumerStatefulWidget {
  const FriendProfileScreen({super.key, required this.friend});

  final AppUser friend;

  @override
  ConsumerState<FriendProfileScreen> createState() =>
      _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  int _segment = 0;
  bool get _isWishlist => _segment == 1;

  @override
  Widget build(BuildContext context) {
    final uid = widget.friend.uid;
    // Según el segmento, observamos la colección o la wishlist del amigo.
    final asyncGames = ref.watch(
      _isWishlist ? userWishlistProvider(uid) : userCollectionProvider(uid),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.friend.displayName)),
      body: Column(
        children: [
          // Cabecera con los datos del amigo.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: widget.friend.photoURL != null
                      ? NetworkImage(widget.friend.photoURL!)
                      : null,
                  child: widget.friend.photoURL == null
                      ? Text(
                          widget.friend.displayName.isNotEmpty
                              ? widget.friend.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 22),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.friend.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.friend.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Colección'),
                  icon: Icon(Icons.casino),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Wishlist'),
                  icon: Icon(Icons.favorite),
                ),
              ],
              selected: {_segment},
              onSelectionChanged: (selection) {
                setState(() => _segment = selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncGames.when(
              data: (games) {
                if (games.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _isWishlist
                            ? '${widget.friend.displayName} no tiene juegos en su wishlist.'
                            : '${widget.friend.displayName} no tiene juegos en su ludoteca.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _ReadOnlyGameTile(game: games[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de juego en solo lectura (sin borrar ni editar).
class _ReadOnlyGameTile extends StatelessWidget {
  const _ReadOnlyGameTile({required this.game});

  final BoardGame game;

  @override
  Widget build(BuildContext context) {
    final partes = <String>[];
    if (game.playersLabel != null) partes.add('${game.playersLabel} jugadores');
    if (game.playingTime != null) partes.add('${game.playingTime} min');
    final subtitulo = partes.join('  ·  ');

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            game.thumbnail != null ? NetworkImage(game.thumbnail!) : null,
        child: game.thumbnail == null ? const Icon(Icons.casino) : null,
      ),
      title: Text(game.name),
      subtitle: subtitulo.isEmpty
          ? (game.customTags.isNotEmpty ? Text(game.customTags.join(', ')) : null)
          : Text(
              game.customTags.isEmpty
                  ? subtitulo
                  : '$subtitulo\n${game.customTags.join(', ')}',
            ),
      isThreeLine: subtitulo.isNotEmpty && game.customTags.isNotEmpty,
      // Aunque la ludoteca del amigo es de solo lectura, el chip de estado
      // sí es interactivo: refleja y fija TU opinión sobre ese juego.
      trailing: GameStateChip(gameId: game.id),
    );
  }
}
