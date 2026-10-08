import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../collection/data/sample_games.dart';
import '../../../collection/presentation/providers/collection_providers.dart';

/// Pantalla de Ajustes: preferencias y acciones de cuenta.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Mis categorías'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              // Volvemos a la raíz antes de cerrar sesión, para que el AuthGate
              // muestre el login al instante (si no, esta pantalla se queda
              // encima hasta pulsar atrás).
              Navigator.of(context).popUntil((route) => route.isFirst);
              ref.read(authRepositoryProvider).signOut();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Desarrollo',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Cargar juegos de prueba'),
            subtitle: const Text('Añade 10 juegos a tu ludoteca (temporal)'),
            onTap: () async {
              final user = ref.read(authStateProvider).value;
              final messenger = ScaffoldMessenger.of(context);
              if (user == null) return;
              try {
                await ref
                    .read(collectionRepositoryProvider)
                    .seedCollection(user.uid, sampleGames);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${sampleGames.length} juegos de prueba añadidos',
                    ),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('No se pudieron añadir: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
