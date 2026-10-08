import 'package:cloud_firestore/cloud_firestore.dart';

/// Datos del perfil del usuario (leídos del documento users/{uid}).
class Profile {
  const Profile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;

  factory Profile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Profile(
      uid: doc.id,
      displayName: (d['displayName'] ?? '') as String,
      email: (d['email'] ?? '') as String,
      photoURL: d['photoURL'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
