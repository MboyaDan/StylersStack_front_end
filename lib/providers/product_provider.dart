import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      //calling the products end point
      final res = await _apiService.getRequest('products');
      if (res.statusCode == 200) {
        List jsonData = jsonDecode(res.body);
        _products = jsonData.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Failed to fetch products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
