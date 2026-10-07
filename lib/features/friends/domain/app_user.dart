import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa a un usuario de la app (para búsqueda y lista de amigos).
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;

  /// Sirve tanto para documentos de `users/{uid}` como para los documentos
  /// de `following/{targetUid}` (en ambos, el id del documento es el uid).
  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      displayName: (data['displayName'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      photoURL: data['photoURL'] as String?,
    );
  }
}
