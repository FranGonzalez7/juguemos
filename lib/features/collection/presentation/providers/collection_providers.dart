import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/collection_repository.dart';
import '../../domain/board_game.dart';

/// Una única instancia del repositorio de ludoteca para toda la app.
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository();
});

/// Stream con la ludoteca del usuario actual, en vivo.
/// Si no hay sesión, devuelve una lista vacía.
final collectionProvider = StreamProvider.autoDispose<List<BoardGame>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(collectionRepositoryProvider).watchCollection(user.uid);
});

/// Stream con la wishlist del usuario actual, en vivo.
final wishlistProvider = StreamProvider.autoDispose<List<BoardGame>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(collectionRepositoryProvider).watchWishlist(user.uid);
});
