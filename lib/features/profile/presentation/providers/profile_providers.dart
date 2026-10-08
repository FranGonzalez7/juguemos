import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Perfil del usuario actual, en vivo.
final myProfileProvider = StreamProvider.autoDispose<Profile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid);
});

/// Perfil de CUALQUIER usuario por su uid (para ver la foto de un amigo en vivo).
final userProfileProvider =
    StreamProvider.autoDispose.family<Profile?, String>((ref, uid) {
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});
