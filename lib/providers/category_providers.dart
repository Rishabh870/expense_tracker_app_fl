import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Category.dart';
import '../services/category_service.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoryNotifier() : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await CategoryService.fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryProvider =
StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
        (ref) => CategoryNotifier());
