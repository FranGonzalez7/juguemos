import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/app_user.dart';
import '../providers/friends_providers.dart';

/// Pantalla para buscar a un usuario por su email y empezar a seguirlo.
class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _emailController = TextEditingController();

  bool _loading = false;
  bool _searched = false; // true una vez hemos buscado al menos una vez
  List<AppUser> _results = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() {
      _loading = true;
      _searched = true;
    });

    try {
      final results = await ref
          .read(friendsRepositoryProvider)
          .searchByEmail(email, excludeUid: user.uid);
      setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos a quién seguimos ya, para marcar los resultados.
    final following = ref.watch(followingProvider).value ?? const [];
    bool yaSigo(String uid) => following.any((u) => u.uid == uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar amigo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  labelText: 'Email de tu amigo',
                  helperText: 'Escribe el email exacto con el que se registró',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _loading ? null : _search,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildResults(yaSigo)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(bool Function(String uid) yaSigo) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searched) {
      return const Center(
        child: Text('Busca a alguien por su email para añadirlo.'),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('No se ha encontrado a nadie con ese email.'),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final persona = _results[index];
        final following = yaSigo(persona.uid);
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              persona.displayName.isNotEmpty
                  ? persona.displayName[0].toUpperCase()
                  : '?',
            ),
          ),
          title: Text(persona.displayName),
          subtitle: Text(persona.email),
          trailing: following
              ? const Chip(label: Text('Siguiendo'))
              : FilledButton(
                  onPressed: () async {
                    final user = ref.read(authStateProvider).value;
                    if (user == null) return;
                    await ref
                        .read(friendsRepositoryProvider)
                        .follow(user.uid, persona);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ahora sigues a ${persona.displayName}'),
                        ),
                      );
                    }
                  },
                  child: const Text('Seguir'),
                ),
        );
      },
    );
  }
}
