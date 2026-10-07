import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/board_game.dart';
import '../providers/collection_providers.dart';
import 'add_game_screen.dart';

/// Pantalla de la Ludoteca: muestra tu colección y tu wishlist, en tiempo real.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  // 0 = Mi colección, 1 = Wishlist
  int _segment = 0;

  bool get _isWishlist => _segment == 1;

  @override
  Widget build(BuildContext context) {
    // Según la pestaña seleccionada, observamos un provider u otro.
    final asyncGames =
        ref.watch(_isWishlist ? wishlistProvider : collectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludoteca'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Mi colección'),
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
        ),
      ),
      // `.when` nos deja pintar un estado distinto según el stream esté
      // cargando, con datos o con error.
      body: asyncGames.when(
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _isWishlist
                      ? 'Tu wishlist está vacía.\nPulsa + para añadir un juego que te apetezca.'
                      : 'Tu ludoteca está vacía.\nPulsa + para añadir tu primer juego.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: games.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _GameTile(
                game: games[index],
                isWishlist: _isWishlist,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddGameScreen(targetIsWishlist: _isWishlist),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Una fila de la lista: muestra un juego con sus datos y un botón de borrar.
class _GameTile extends ConsumerWidget {
  const _GameTile({required this.game, required this.isWishlist});

  final BoardGame game;
  final bool isWishlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Construimos el subtítulo con los datos que tengamos.
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
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Eliminar',
        onPressed: () async {
          final user = ref.read(authStateProvider).value;
          if (user == null) return;
          final repo = ref.read(collectionRepositoryProvider);
          if (isWishlist) {
            await repo.removeFromWishlist(user.uid, game.id);
          } else {
            await repo.removeFromCollection(user.uid, game.id);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"${game.name}" eliminado')),
            );
          }
        },
      ),
    );
  }
}
