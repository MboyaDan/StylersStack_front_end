import 'package:dio/dio.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/services/api_service.dart';

class CategoryService {
  final ApiService _apiService;

  CategoryService(this._apiService);

  Future<List<CategoryType>> fetchCategories() async {
    try {
      final Response response = await _apiService.getRequest('/categories');
      final List<dynamic> data = response.data;

      return data.map((item) {
        final categoryString = item['value'] ?? item['name']; // use fallback if needed
        final category = CategoryTypeExtension.fromString(categoryString);

        if (category == null) {
          throw Exception('Unknown category type: $categoryString');
        }

        return category;
      }).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${e.message}');
    }
  }
}
