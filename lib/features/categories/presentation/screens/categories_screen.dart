import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/categories_providers.dart';

/// Pantalla para gestionar tus categorías personales.
/// Puedes añadir las tuyas, quitar las que no uses y añadir las sugeridas.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(String uid, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    await ref.read(categoriesRepositoryProvider).addCategory(uid, clean);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final cats = ref.watch(myCategoriesProvider).value ?? const [];

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Sugeridas que aún no tiene el usuario.
    final pending = defaultCategorySuggestions
        .where((s) => !cats.any((c) => c.toLowerCase() == s.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis categorías')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tus categorías',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (cats.isEmpty)
              const Text(
                'Todavía no tienes categorías. Añade las tuyas abajo o usa las sugeridas.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final c in cats)
                    Chip(
                      label: Text(c),
                      onDeleted: () => ref
                          .read(categoriesRepositoryProvider)
                          .removeCategory(user.uid, c),
                    ),
                ],
              ),
            const SizedBox(height: 24),
            Text('Añadir nueva',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Deckbuilding',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _add(user.uid, value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () => _add(user.uid, _controller.text),
                ),
              ],
            ),
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Sugeridas',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in pending)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(s),
                      onPressed: () => _add(user.uid, s),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
