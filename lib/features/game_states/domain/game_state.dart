import 'package:flutter/material.dart';

/// Los tres estados que un usuario puede dar a un juego.
/// Es "su opinión" sobre ese juego, independiente de quién sea el dueño.
enum GameState {
  play,
  meh,
  veto;

  /// Valor que guardamos en Firestore.
  String get firestoreValue => switch (this) {
        GameState.play => 'play',
        GameState.meh => 'meh',
        GameState.veto => 'veto',
      };

  /// Texto para mostrar al usuario.
  String get label => switch (this) {
        GameState.play => 'Juguemos',
        GameState.meh => 'Meh',
        GameState.veto => 'Vetado',
      };

  /// Color del estado (verde / amarillo / rojo).
  Color get color => switch (this) {
        GameState.play => const Color(0xFF2E7D32),
        GameState.meh => const Color(0xFFF9A825),
        GameState.veto => const Color(0xFFC62828),
      };

  /// Color del texto/icono encima del color de fondo (contraste).
  Color get onColor => this == GameState.meh ? Colors.black87 : Colors.white;

  IconData get icon => switch (this) {
        GameState.play => Icons.check_circle,
        GameState.meh => Icons.sentiment_neutral,
        GameState.veto => Icons.block,
      };

  /// Convierte el valor guardado en Firestore a un GameState (o null).
  static GameState? fromFirestore(String? value) => switch (value) {
        'play' => GameState.play,
        'meh' => GameState.meh,
        'veto' => GameState.veto,
        _ => null,
      };
}
