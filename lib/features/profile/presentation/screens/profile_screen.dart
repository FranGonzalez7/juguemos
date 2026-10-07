import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../collection/data/sample_games.dart';
import '../../../collection/presentation/providers/collection_providers.dart';

/// Pantalla de Perfil: muestra los datos del usuario y el botón de cerrar sesión.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Sin nombre',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? ''),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 48),
            // ---------------------------------------------------------------
            // [TEMPORAL] Botón para sembrar juegos de prueba mientras llega
            // la aprobación de BGG. Se puede borrar más adelante.
            // ---------------------------------------------------------------
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Desarrollo',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                if (user == null) return;
                try {
                  await ref
                      .read(collectionRepositoryProvider)
                      .seedCollection(user.uid, sampleGames);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        '${sampleGames.length} juegos de prueba añadidos a tu ludoteca',
                      ),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('No se pudieron añadir: $e')),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Cargar juegos de prueba'),
            ),
          ],
        ),
      ),
    );
  }
}
