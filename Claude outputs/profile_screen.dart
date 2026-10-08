import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../collection/presentation/providers/collection_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../providers/profile_providers.dart';
import 'settings_screen.dart';

/// Pantalla de Perfil: tarjeta con foto, nombre y contadores.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Acentos cálidos (combinan con el verde del tema).
  static const _green = Color(0xFF4E7C5B);
  static const _amber = Color(0xFFE0A24E);
  static const _terracotta = Color(0xFFC56A4A);

  bool _uploading = false;

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (xfile == null) return;

    setState(() => _uploading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await xfile.readAsBytes();
      await ref.read(profileRepositoryProvider).uploadAvatar(user.uid, bytes);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo subir la foto: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _editName(String current) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    var temp = current;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextFormField(
          initialValue: current,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onChanged: (v) => temp = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, temp),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(user.uid, result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider).value;
    final authUser = ref.watch(authStateProvider).value;

    final collCount = ref.watch(collectionProvider).value?.length ?? 0;
    final wishCount = ref.watch(wishlistProvider).value?.length ?? 0;
    final friendsCount = ref.watch(followingProvider).value?.length ?? 0;

    final displayName = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : (authUser?.displayName ?? 'Sin nombre');
    final email = profile?.email ?? authUser?.email ?? '';
    final photoURL = profile?.photoURL;
    final year = profile?.createdAt?.year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Tarjeta de cabecera ---
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Franja de color degradado arriba.
                Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_green, _amber, _terracotta],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _avatar(photoURL, displayName),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                              ),
                            if (year != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _amber.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium,
                                        size: 16, color: _amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Desde $year',
                                      style: const TextStyle(
                                        color: _terracotta,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar nombre',
                        onPressed: () => _editName(displayName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Contadores ---
          Row(
            children: [
              _stat(Icons.inventory_2_outlined, 'Juegos', collCount, _green),
              const SizedBox(width: 12),
              _stat(Icons.favorite_border, 'Wishlist', wishCount, _amber),
              const SizedBox(width: 12),
              _stat(Icons.people_outline, 'Amigos', friendsCount, _terracotta),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(String? photoURL, String displayName) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
          child: photoURL == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 32),
                )
              : null,
        ),
        if (_uploading)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.black45,
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _uploading ? null : _showPhotoOptions,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  Icons.photo_camera,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String label, int value, Color tint) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tint.withOpacity(0.18),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(height: 10),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
