import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/board_game.dart';

/// Repositorio que gestiona la ludoteca y la wishlist en Firestore.
///
/// Rutas (de nuestro modelo de datos):
///   users/{uid}/collection/{gameId}
///   users/{uid}/wishlist/{gameId}
class CollectionRepository {
  CollectionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Referencias a las dos subcolecciones del usuario.
  CollectionReference<Map<String, dynamic>> _collectionRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('collection');

  CollectionReference<Map<String, dynamic>> _wishlistRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('wishlist');

  /// Escucha la ludoteca en tiempo real (ordenada por nombre).
  /// `snapshots()` emite una lista nueva cada vez que algo cambia en Firestore.
  Stream<List<BoardGame>> watchCollection(String uid) {
    return _collectionRef(uid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(BoardGame.fromDoc).toList());
  }

  /// Lee la ludoteca una sola vez (sin escuchar cambios).
  /// Útil para cálculos puntuales como el sugeridor de partidas.
  Future<List<BoardGame>> getCollection(String uid) async {
    final snap = await _collectionRef(uid).orderBy('name').get();
    return snap.docs.map(BoardGame.fromDoc).toList();
  }

  /// Escucha la wishlist en tiempo real.
  Stream<List<BoardGame>> watchWishlist(String uid) {
    return _wishlistRef(uid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(BoardGame.fromDoc).toList());
  }

  Future<void> addToCollection(String uid, BoardGame game) =>
      _add(_collectionRef(uid), game);

  Future<void> addToWishlist(String uid, BoardGame game) =>
      _add(_wishlistRef(uid), game);

  Future<void> removeFromCollection(String uid, String gameId) =>
      _collectionRef(uid).doc(gameId).delete();

  Future<void> removeFromWishlist(String uid, String gameId) =>
      _wishlistRef(uid).doc(gameId).delete();

  // Helper interno: si el juego no trae id, Firestore genera uno automático.
  Future<void> _add(
    CollectionReference<Map<String, dynamic>> ref,
    BoardGame game,
  ) {
    final docRef = game.id.isEmpty ? ref.doc() : ref.doc(game.id);
    return docRef.set({
      ...game.toMap(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// [TEMPORAL] Añade una lista de juegos a la ludoteca de golpe.
  ///
  /// Usamos un WriteBatch: en lugar de hacer N escrituras sueltas, agrupamos
  /// todas en una sola operación (más rápido y atómico: o entran todas, o
  /// ninguna). Útil para sembrar datos de prueba hasta tener BGG.
  Future<void> seedCollection(String uid, List<BoardGame> games) async {
    final batch = _firestore.batch();
    for (final game in games) {
      final docRef = _collectionRef(uid).doc(); // id automático
      batch.set(docRef, {
        ...game.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
