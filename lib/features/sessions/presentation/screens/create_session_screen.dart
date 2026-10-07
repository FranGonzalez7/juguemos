import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../../domain/game_session.dart';
import 'suggestions_screen.dart';

/// Paso 1 de organizar una partida: metemos los datos (ludoteca, jugadores,
/// tiempo y categoría). NO se guarda nada todavía: al continuar vamos a la
/// pantalla de sugerencias, donde se elige el juego y ahí sí se crea la partida.
class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _timeController = TextEditingController();
  final _categoryController = TextEditingController();

  String? _libraryOwnerUid;
  final Set<String> _selectedPlayers = {};

  @override
  void dispose() {
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _goToSuggestions({required Map<String, String> nameByUid}) {
    if (_libraryOwnerUid == null) return;

    final players = _selectedPlayers
        .map((uid) => SessionPlayer(uid: uid, name: nameByUid[uid] ?? '?'))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SuggestionsScreen(
          libraryOwnerUid: _libraryOwnerUid!,
          libraryOwnerName: nameByUid[_libraryOwnerUid!] ?? '?',
          players: players,
          availableMinutes: int.tryParse(_timeController.text.trim()),
          desiredCategory: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authStateProvider).value;
    final friends = ref.watch(followingProvider).value ?? const [];

    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myUid = me.uid;
    final myName = me.displayName?.isNotEmpty == true
        ? me.displayName!
        : (me.email ?? 'Yo');

    final nameByUid = <String, String>{myUid: myName};
    for (final f in friends) {
      nameByUid[f.uid] = f.displayName;
    }

    // Por defecto: mi ludoteca y yo presente.
    _libraryOwnerUid ??= myUid;
    _selectedPlayers.add(myUid);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva partida')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('¿En la ludoteca de quién jugáis?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _libraryOwnerUid,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: myUid, child: Text('$myName (tú)')),
                for (final f in friends)
                  DropdownMenuItem(value: f.uid, child: Text(f.displayName)),
              ],
              onChanged: (value) => setState(() => _libraryOwnerUid = value),
            ),
            const SizedBox(height: 24),
            Text('¿Quién juega?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: true,
              onChanged: null,
              title: Text('$myName (tú)'),
              contentPadding: EdgeInsets.zero,
            ),
            for (final f in friends)
              CheckboxListTile(
                value: _selectedPlayers.contains(f.uid),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedPlayers.add(f.uid);
                    } else {
                      _selectedPlayers.remove(f.uid);
                    }
                  });
                },
                title: Text(f.displayName),
                contentPadding: EdgeInsets.zero,
              ),
            if (friends.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aún no sigues a nadie. Puedes jugar solo tú, o añadir '
                  'amigos desde la pestaña Amigos.',
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tiempo disponible (minutos)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría deseada (opcional)',
                helperText: 'Ej: Eurogame, Party, Filler',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _goToSuggestions(nameByUid: nameByUid),
              icon: const Icon(Icons.search),
              label: const Text('Ver sugerencias'),
            ),
          ],
        ),
      ),
    );
  }
}
