import 'package:flutter/material.dart';

import '../../../collection/presentation/screens/collection_screen.dart';
import '../../../friends/presentation/screens/friends_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../sessions/presentation/screens/sessions_screen.dart';

/// Contenedor principal cuando hay sesión iniciada.
/// Tiene la barra de navegación inferior y va mostrando cada pestaña.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Pestaña activa (0 = Ludoteca, 1 = Amigos, 2 = Partidas, 3 = Perfil).
  int _currentIndex = 0;

  // Las pantallas de cada pestaña, en el mismo orden que la barra.
  // Usamos IndexedStack: mantiene vivas TODAS las pantallas y solo enseña
  // la activa, así no se recargan cada vez que cambias de pestaña.
  static const _screens = [
    CollectionScreen(),
    FriendsScreen(),
    SessionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // NavigationBar es la barra inferior de Material 3 (la versión moderna
      // del clásico BottomNavigationBar).
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'Ludoteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Amigos',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Partidas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
