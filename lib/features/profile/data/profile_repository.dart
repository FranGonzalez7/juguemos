import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/profile.dart';

/// Repositorio del perfil: lee los datos del usuario, actualiza el nombre
/// y sube la foto de perfil a Firebase Storage.
class ProfileRepository {
  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Escucha el perfil en vivo.
  Stream<Profile> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map(Profile.fromDoc);
  }

  /// Actualiza el nombre visible (en Auth y en Firestore).
  Future<void> updateDisplayName(String uid, String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _userDoc(uid).set({'displayName': name}, SetOptions(merge: true));
  }

  /// Sube la foto de perfil a Storage y guarda su URL en el perfil.
  Future<String> uploadAvatar(String uid, Uint8List bytes) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _auth.currentUser?.updatePhotoURL(url);
    await _userDoc(uid).set({'photoURL': url}, SetOptions(merge: true));
    return url;
  }
}
