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
}
