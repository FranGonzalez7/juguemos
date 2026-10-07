import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/game_session.dart';

/// Repositorio de partidas. Ruta: sessions/{sessionId}
class SessionsRepository {
  SessionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('sessions');

  /// Partidas en las que participo (soy uno de los jugadores).
  /// Ordenamos por fecha en el cliente para no necesitar un índice compuesto.
  Stream<List<GameSession>> watchMySessions(String uid) {
    return _ref.where('playerUids', arrayContains: uid).snapshots().map((snap) {
      final list = snap.docs.map(GameSession.fromDoc).toList();
      list.sort((a, b) =>
          (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return list;
    });
  }

  Future<void> createSession(GameSession session) {
    return _ref.add({
      ...session.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String id) => _ref.doc(id).delete();
}
