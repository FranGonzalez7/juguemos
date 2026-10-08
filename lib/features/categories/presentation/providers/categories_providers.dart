import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/categories_repository.dart';

/// Categorías sugeridas por defecto (el usuario las añade si quiere).
const List<String> defaultCategorySuggestions = [
  'Eurogame',
  'Filler',
  'Ameritrash',
  'Party',
  'Familiar',
  'Cooperativo',
];

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository();
});

/// Categorías del usuario actual, en vivo.
final myCategoriesProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(categoriesRepositoryProvider).watchCategories(user.uid);
});
