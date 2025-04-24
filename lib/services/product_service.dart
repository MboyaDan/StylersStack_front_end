import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/product_model.dart'; // your product model

class ProductService {
  final ApiService _apiService = ApiService();

  Future<void>fetchProductsDetails() async{

  }
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _apiService.getRequest('products');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
