import '../utils/RequestMethod.dart';
import '../models/Category.dart';

class CategoryService {
  static Future<List<Category>> fetchCategories() async {
    try {
      final res = await privateDio.get('/category/');

      return (res.data as List).map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching expenses: $e');

      throw Exception('Failed to load expenses');
    }
  }
}
