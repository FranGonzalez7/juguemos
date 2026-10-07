import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';

/// Repositorio de amigos (sistema de "follow").
///
/// Rutas:
///   users/{uid}/following/{targetUid}
///
/// En cada documento de `following` guardamos una copia (denormalizada) del
/// nombre y el email del amigo, para poder pintar la lista sin tener que leer
/// el perfil de cada uno. (Si un amigo cambia su nombre, se quedaría algo
/// desactualizado; lo afinaremos más adelante si hace falta.)
class FriendsRepository {
  FriendsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _followingRef(String uid) =>
      _users.doc(uid).collection('following');

  /// Busca usuarios por email exacto (excluyendo a uno mismo).
  Future<List<AppUser>> searchByEmail(
    String email, {
    required String excludeUid,
  }) async {
    final snap = await _users
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();

    return snap.docs
        .map(AppUser.fromDoc)
        .where((u) => u.uid != excludeUid)
        .toList();
  }

  /// Escucha en tiempo real la lista de personas a las que sigo.
  Stream<List<AppUser>> watchFollowing(String uid) {
    return _followingRef(uid)
        .orderBy('displayName')
        .snapshots()
        .map((snap) => snap.docs.map(AppUser.fromDoc).toList());
  }

  /// Empezar a seguir a alguien.
  Future<void> follow(String uid, AppUser target) {
    return _followingRef(uid).doc(target.uid).set({
      'displayName': target.displayName,
      'email': target.email,
      'photoURL': target.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Dejar de seguir a alguien.
  Future<void> unfollow(String uid, String targetUid) {
    return _followingRef(uid).doc(targetUid).delete();
  }
}
