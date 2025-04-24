import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/category_type.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  List<ProductModel> _filteredProducts = [];
  CategoryType? _selectedCategory;

  List<ProductModel> get filteredProducts =>
      _selectedCategory == null ? _products : _filteredProducts;

  CategoryType? get selectedCategory => _selectedCategory;

  void filterByCategory(CategoryType category) {
    _selectedCategory = category;
    _filteredProducts = _products
        .where((product) => product.category.toLowerCase() == category.label.toLowerCase())
        .toList();
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    notifyListeners();
  }
  Future<void>fetchProductsDetails() async{

  }


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
