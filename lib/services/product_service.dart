import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiService _apiService;
  ProductService(this._apiService);

  /// Fetch all products
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final Response response = await _apiService.getRequest('/products');
      final List<dynamic> data = response.data;

      return data.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${e.message}');
    }
  }

  /// Fetch single product details by ID
  Future<ProductModel> fetchProductDetails(String productId) async {
    try {
      final Response response = await _apiService.getRequest('products/$productId');
      final data = response.data;

      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to load product details: ${e.message}');
    }
  }
}
