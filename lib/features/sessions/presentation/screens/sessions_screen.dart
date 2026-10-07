import 'package:flutter/material.dart';

/// Pantalla de Partidas (placeholder).
class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partidas')),
      body: const Center(child: Text('Aquí organizarás tus partidas')),
    );
  }
}
