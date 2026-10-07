import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/game_state.dart';

/// Repositorio de los estados (Juguemos / Meh / Vetado) que un usuario pone
/// a los juegos.
///
/// Ruta: users/{uid}/gameStates/{gameId}
/// El estado cuelga del usuario + el juego → es "su opinión", global.
class GameStatesRepository {
  GameStatesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('users').doc(uid).collection('gameStates');

  /// Escucha, en tiempo real, TODOS los estados del usuario como un mapa
  /// { gameId: GameState }. Así cada ficha solo tiene que mirar su id.
  Stream<Map<String, GameState>> watchStates(String uid) {
    return _ref(uid).snapshots().map((snap) {
      final map = <String, GameState>{};
      for (final doc in snap.docs) {
        final state = GameState.fromFirestore(doc.data()['state'] as String?);
        if (state != null) map[doc.id] = state;
      }
      return map;
    });
  }

  /// Fija (o cambia) el estado de un juego.
  Future<void> setState(String uid, String gameId, GameState state) {
    return _ref(uid).doc(gameId).set({
      'state': state.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Quita la marca de un juego (borra el documento).
  Future<void> clearState(String uid, String gameId) {
    return _ref(uid).doc(gameId).delete();
  }
}
