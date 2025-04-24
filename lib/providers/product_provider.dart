import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stylerstack/services/product_service.dart';
import '../models/category_type.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;


  List<ProductModel> _filteredProducts = [];
  CategoryType? _selectedCategory;

  List<ProductModel> get filteredProducts =>
      _selectedCategory == null ? _products : _filteredProducts;

  CategoryType? get selectedCategory => _selectedCategory;

  void filterByCategory(CategoryType category) {
    _selectedCategory = category;
    _filteredProducts = _products
        .where((product) =>
    product.category.toLowerCase() == category.label.toLowerCase())
        .toList();
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    notifyListeners();
  }

  Future<void> loadProducts()async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
    }
    catch (e) {
      print (
        'error in fetching: $e'
      );
    }
    _isLoading = false;
    notifyListeners();
    }
  }
