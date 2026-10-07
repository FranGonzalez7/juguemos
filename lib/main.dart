import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  // Nos aseguramos de que Flutter está listo antes de hacer trabajo asíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Arrancamos Firebase con la configuración que generó `flutterfire configure`.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ProviderScope es la "caja" donde viven todos los providers de Riverpod.
  // Tiene que envolver TODA la app, por eso va aquí arriba del todo.
  runApp(
    const ProviderScope(
      child: JuguemosApp(),
    ),
  );
}
