import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio de las categorías personales del usuario.
/// Se guardan como un array `categories` dentro del documento users/{uid}.
class CategoriesRepository {
  CategoriesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Escucha las categorías del usuario en vivo (ordenadas alfabéticamente).
  Stream<List<String>> watchCategories(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      final list =
          (data['categories'] as List<dynamic>?)?.cast<String>() ?? const [];
      final sorted = [...list]
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return sorted;
    });
  }

  /// Añade una categoría (arrayUnion evita duplicados).
  Future<void> addCategory(String uid, String name) {
    return _userDoc(uid).set({
      'categories': FieldValue.arrayUnion([name]),
    }, SetOptions(merge: true));
  }

  /// Quita una categoría.
  Future<void> removeCategory(String uid, String name) {
    return _userDoc(uid).set({
      'categories': FieldValue.arrayRemove([name]),
    }, SetOptions(merge: true));
  }
}
