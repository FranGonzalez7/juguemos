import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/friends_providers.dart';
import 'add_friend_screen.dart';
import 'friend_profile_screen.dart';

/// Pantalla de Amigos: lista de personas a las que sigues.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFollowing = ref.watch(followingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Amigos')),
      body: asyncFollowing.when(
        data: (friends) {
          if (friends.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Todavía no sigues a nadie.\nPulsa + para buscar a un amigo por su email.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: friends.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.photoURL != null
                      ? NetworkImage(friend.photoURL!)
                      : null,
                  child: friend.photoURL == null
                      ? Text(
                          friend.displayName.isNotEmpty
                              ? friend.displayName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                title: Text(friend.displayName),
                subtitle: Text(friend.email),
                // Al tocar la fila, abrimos el perfil del amigo.
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FriendProfileScreen(friend: friend),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  tooltip: 'Dejar de seguir',
                  onPressed: () async {
                    final user = ref.read(authStateProvider).value;
                    if (user == null) return;
                    await ref
                        .read(friendsRepositoryProvider)
                        .unfollow(user.uid, friend.uid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Has dejado de seguir a ${friend.displayName}'),
                        ),
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
            MaterialPageRoute(builder: (_) => const AddFriendScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
