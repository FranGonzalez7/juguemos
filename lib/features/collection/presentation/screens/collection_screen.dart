import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../../game_states/domain/game_state.dart';
import '../../../game_states/presentation/providers/game_states_providers.dart';
import '../../../game_states/presentation/widgets/game_state_chip.dart';
import '../../domain/board_game.dart';
import '../providers/collection_providers.dart';
import 'add_game_screen.dart';

/// Pantalla de la Ludoteca: colección y wishlist, con búsqueda y filtros.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  int _segment = 0; // 0 = colección, 1 = wishlist
  bool get _isWishlist => _segment == 1;

  final _searchController = TextEditingController();
  String _search = '';

  // Filtros
  int? _filterPlayers;
  int? _filterMaxTime;
  final Set<String> _filterCategories = {};
  final Set<GameState?> _filterStates = {}; // null = sin marcar

  bool get _filtersActive =>
      _filterPlayers != null ||
      _filterMaxTime != null ||
      _filterCategories.isNotEmpty ||
      _filterStates.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BoardGame> _applyFilters(
    List<BoardGame> games,
    Map<String, GameState> states,
  ) {
    final q = _search.trim().toLowerCase();
    return games.where((g) {
      if (q.isNotEmpty && !g.name.toLowerCase().contains(q)) return false;

      final p = _filterPlayers;
      if (p != null) {
        if (g.minPlayers != null && p < g.minPlayers!) return false;
        if (g.maxPlayers != null && p > g.maxPlayers!) return false;
      }

      final t = _filterMaxTime;
      if (t != null && g.playingTime != null && g.playingTime! > t) {
        return false;
      }

      if (_filterCategories.isNotEmpty) {
        final tags = g.customTags.map((e) => e.toLowerCase()).toSet();
        for (final c in _filterCategories) {
          if (!tags.contains(c.toLowerCase())) return false; // AND
        }
      }

      // Estado (solo en la colección): mostrar si su estado está entre los
      // seleccionados (null = sin marcar). Varios estados = OR.
      if (!_isWishlist && _filterStates.isNotEmpty) {
        if (!_filterStates.contains(states[g.id])) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openFilters(List<String> categories) async {
    // Sin TextEditingController: usamos TextFormField con initialValue + onChanged.
    // Así no hay controladores que destruir al cerrar (evita el error _dependents).
    int? players = _filterPlayers;
    int? maxTime = _filterMaxTime;
    final selected = {..._filterCategories};
    final selectedStates = {..._filterStates};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtros', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: players?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de jugadores',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => players = int.tryParse(v.trim()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: maxTime?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo máximo (minutos)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => maxTime = int.tryParse(v.trim()),
                  ),
                  const SizedBox(height: 16),
                  Text('Categorías',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (categories.isEmpty)
                    const Text(
                      'Añade categorías en tu perfil para filtrar por ellas.',
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final c in categories)
                          FilterChip(
                            label: Text(c),
                            selected: selected.contains(c),
                            onSelected: (sel) {
                              setSheet(() {
                                if (sel) {
                                  selected.add(c);
                                } else {
                                  selected.remove(c);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  if (!_isWishlist) ...[
                    const SizedBox(height: 16),
                    Text('Estado',
                        style: Theme.of(ctx).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final s in GameState.values)
                          FilterChip(
                            avatar:
                                Icon(Icons.casino, color: s.color, size: 18),
                            label: Text(s.label),
                            selected: selectedStates.contains(s),
                            onSelected: (sel) {
                              setSheet(() {
                                if (sel) {
                                  selectedStates.add(s);
                                } else {
                                  selectedStates.remove(s);
                                }
                              });
                            },
                          ),
                        FilterChip(
                          avatar: const Icon(Icons.casino_outlined, size: 18),
                          label: const Text('Sin marcar'),
                          selected: selectedStates.contains(null),
                          onSelected: (sel) {
                            setSheet(() {
                              if (sel) {
                                selectedStates.add(null);
                              } else {
                                selectedStates.remove(null);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _filterPlayers = null;
                              _filterMaxTime = null;
                              _filterCategories.clear();
                              _filterStates.clear();
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _filterPlayers = players;
                              _filterMaxTime = maxTime;
                              _filterCategories
                                ..clear()
                                ..addAll(selected);
                              _filterStates
                                ..clear()
                                ..addAll(selectedStates);
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Observamos ambas listas (para los contadores) y las categorías (para el filtro).
    final collection = ref.watch(collectionProvider);
    final wishlist = ref.watch(wishlistProvider);
    final categories = ref.watch(myCategoriesProvider).value ?? const [];
    final gameStates =
        ref.watch(myGameStatesProvider).value ?? const <String, GameState>{};

    final collCount = collection.value?.length ?? 0;
    final wishCount = wishlist.value?.length ?? 0;
    final asyncGames = _isWishlist ? wishlist : collection;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/dado_solo.svg', height: 32),
            const SizedBox(width: 8),
            const Text('Ludoteca'),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- Pestañas tipo pastilla con contador ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _tab(0, 'Mi colección', collCount),
                  _tab(1, 'Wishlist', wishCount),
                ],
              ),
            ),
          ),
          // --- Búsqueda + botón de filtro ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _search = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _filtersActive
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    tooltip: 'Filtros',
                    onPressed: () => _openFilters(categories),
                    icon: Icon(
                      Icons.tune,
                      color: _filtersActive
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncGames.when(
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
                final filtered = _applyFilters(games, gameStates);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Ningún juego coincide con la búsqueda o los filtros.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _GameTile(
                      game: filtered[index],
                      isWishlist: _isWishlist,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
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

  Widget _tab(int index, String label, int count) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _segment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _segment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Una fila de la lista: muestra un juego con sus datos y acciones.
class _GameTile extends ConsumerWidget {
  const _GameTile({required this.game, required this.isWishlist});

  final BoardGame game;
  final bool isWishlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isWishlist) GameStateChip(gameId: game.id),
          IconButton(
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
        ],
      ),
    );
  }
}
