import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// El "repositorio" encapsula TODO lo relacionado con la autenticación.
///
/// La idea (patrón Repository) es que el resto de la app no hable directamente
/// con FirebaseAuth, sino con esta clase. Así, si algún día cambiamos algo del
/// backend, solo tocamos aquí y no en 20 pantallas distintas.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Stream que emite el usuario actual (o null si no hay sesión).
  /// Cada vez que alguien entra o sale, este stream avisa automáticamente.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// El usuario conectado en este preciso momento (o null).
  User? get currentUser => _auth.currentUser;

  /// Iniciar sesión con email y contraseña.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registrar un usuario nuevo y crear su documento de perfil en Firestore.
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    // 1. Creamos la cuenta en Firebase Auth.
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    // 2. Guardamos el nombre visible en el perfil de Auth.
    await user.updateDisplayName(displayName.trim());

    // 3. Creamos su documento en users/{uid}, tal y como definimos en el modelo.
    //    Guardamos el email en minúsculas para que la búsqueda de amigos
    //    por email funcione siempre, sin importar cómo lo escriban.
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName.trim(),
      'email': email.trim().toLowerCase(),
      'photoURL': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cerrar sesión.
  Future<void> signOut() => _auth.signOut();
}
