import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../domain/board_game.dart';
import '../providers/collection_providers.dart';

/// Formulario para añadir un juego a mano (temporal, hasta tener la búsqueda
/// de BGG). Las categorías se SELECCIONAN de tu lista (no se escriben).
class AddGameScreen extends ConsumerStatefulWidget {
  const AddGameScreen({super.key, required this.targetIsWishlist});

  final bool targetIsWishlist;

  @override
  ConsumerState<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends ConsumerState<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _timeController = TextEditingController();

  final Set<String> _selectedCategories = {};
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _loading = true);

    final game = BoardGame(
      name: _nameController.text.trim(),
      minPlayers: int.tryParse(_minController.text.trim()),
      maxPlayers: int.tryParse(_maxController.text.trim()),
      playingTime: int.tryParse(_timeController.text.trim()),
      customTags: _selectedCategories.toList(),
    );

    final repo = ref.read(collectionRepositoryProvider);

    try {
      if (widget.targetIsWishlist) {
        await repo.addToWishlist(user.uid, game);
      } else {
        await repo.addToCollection(user.uid, game);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destino = widget.targetIsWishlist ? 'wishlist' : 'ludoteca';
    final categories = ref.watch(myCategoriesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text('Añadir juego a tu $destino')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del juego *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce el nombre del juego';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jugadores mín.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jugadores máx.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                if (categories.isEmpty)
                  const Text(
                    'No tienes categorías todavía. Añádelas en tu perfil '
                    '(Perfil → Mis categorías) para poder asignarlas.',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in categories)
                        FilterChip(
                          label: Text(c),
                          selected: _selectedCategories.contains(c),
                          onSelected: (sel) {
                            setState(() {
                              if (sel) {
                                _selectedCategories.add(c);
                              } else {
                                _selectedCategories.remove(c);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
