import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/friends_repository.dart';
import '../../domain/app_user.dart';

/// Una única instancia del repositorio de amigos para toda la app.
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository();
});

/// Stream en vivo con las personas a las que sigue el usuario actual.
final followingProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(friendsRepositoryProvider).watchFollowing(user.uid);
});
