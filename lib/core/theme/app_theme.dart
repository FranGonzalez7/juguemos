import 'package:flutter/material.dart';

/// Tema visual de la app y colores reutilizables en un solo sitio.
class AppTheme {
  AppTheme._(); // Constructor privado: esta clase solo agrupa cosas estáticas.

  /// Color principal de la marca (un verde "mesa de juego").
  static const Color seed = Color(0xFF2E7D32);

  // Colores de los estados de los juegos. Los usaremos más adelante
  // para pintar Juguemos / Meh / Vetado.
  static const Color estadoJuguemos = Color(0xFF2E7D32); // verde
  static const Color estadoMeh = Color(0xFFF9A825); // amarillo
  static const Color estadoVetado = Color(0xFFC62828); // rojo

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
