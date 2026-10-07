import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sessions_providers.dart';
import 'create_session_screen.dart';
import 'session_detail_screen.dart';

/// Pantalla de Partidas: lista las partidas en las que participas.
class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSessions = ref.watch(mySessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Partidas')),
      body: asyncSessions.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No tienes partidas todavía.\nPulsa + para organizar una.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];

              final partes = <String>[
                'En la ludoteca de ${session.libraryOwnerName}',
                '${session.players.length} jugadores',
              ];
              if (session.availableMinutes != null) {
                partes.add('${session.availableMinutes} min');
              }

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.casino)),
                title: Text(session.chosenGameName ?? 'Partida sin juego'),
                subtitle: Text(partes.join('  ·  ')),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SessionDetailScreen(session: session),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar partida',
                  onPressed: () async {
                    await ref
                        .read(sessionsRepositoryProvider)
                        .deleteSession(session.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Partida eliminada')),
                      );
                    }
                  },
                ),
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
            MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
