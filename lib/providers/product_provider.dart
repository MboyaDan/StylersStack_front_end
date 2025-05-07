import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/services/product_service.dart';
import '../models/category_type.dart';
import '../models/product_model.dart';

//combining provider with rxdart for searching and filtering products
class ProductProvider with ChangeNotifier {
  final ProductService _productService;
  ProductProvider(ApiService apiService) : _productService = ProductService(apiService);

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _searchedProducts = [];

  bool _isLoading = false;
  String _searchQuery = '';
  CategoryType? _selectedCategory;

  // 🔹 Expose a BehaviorSubject for reactive search results
  final BehaviorSubject<List<ProductModel>> _searchedProductsSubject =
  BehaviorSubject<List<ProductModel>>.seeded([]);

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  CategoryType? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ProductModel> get flashSaleProducts =>
      _products.where((p) => p.discount != null && p.discount! > 0).toList();

  List<ProductModel> get filteredProducts =>
      _selectedCategory == null ? _products : _filteredProducts;

  List<ProductModel> get searchedProducts =>
      _searchQuery.isEmpty ? filteredProducts : _searchedProducts;

  // 🔹 Rx stream of searched products
  Stream<List<ProductModel>> get searchedProductsStream =>
      _searchedProductsSubject.stream;

  // 🔄 Load products from backend
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      print('Error fetching products: $e');
    }
    _isLoading = false;
    _applyFilters();
    notifyListeners();
  }

  // Set and apply category filter
  void filterByCategory(CategoryType category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  //  Clear the category filter
  void clearCategoryFilter() {
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search query only
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Combined search + category filter
  void searchWithCategory({
    required String query,
    CategoryType? category,
  }) {
    bool didChange = false;

    if (_searchQuery != query) {
      _searchQuery = query;
      didChange = true;
    }

    if (_selectedCategory != category) {
      _selectedCategory = category;
      didChange = true;
    }

    if (didChange) {
      _applyFilters();
      notifyListeners();
    }
  }

  // Core logic for filtering products
  void _applyFilters() {
    // Filter by category first
    _filteredProducts = _selectedCategory == null
        ? _products
        : _products.where((product) =>
    product.category.toLowerCase() ==
        _selectedCategory!.label.toLowerCase()).toList();

    // Then filter by search query
    if (_searchQuery.isEmpty) {
      _searchedProducts = [];
      _searchedProductsSubject.add(_filteredProducts); // Show filtered category results
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _searchedProducts = _filteredProducts
          .where((product) =>
          product.name.toLowerCase().contains(lowerQuery))
          .toList();
      _searchedProductsSubject.add(_searchedProducts); // Update stream
    }
  }

  // Dispose stream when provider is destroyed
  @override
  void dispose() {
    _searchedProductsSubject.close();
    super.dispose();
  }
}
