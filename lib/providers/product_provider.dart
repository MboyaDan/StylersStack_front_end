import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/models/product_model.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/services/category_service.dart';
import 'package:stylerstack/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final CategoryService _categoryService;
  late final ProductService _productService;

  ProductProvider(this._categoryService);

  List<CategoryType> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _searchedProducts = [];

  bool _isLoading = false;
  String _searchQuery = '';
  CategoryType? _selectedCategory;

  final BehaviorSubject<List<ProductModel>> _searchedProductsSubject =
  BehaviorSubject<List<ProductModel>>.seeded([]);

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryType> get categories => _categories;
  bool get isLoading => _isLoading;
  CategoryType? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ProductModel> get flashSaleProducts =>
      _products.where((p) => p.discount != null && p.discount! > 0).toList();

  List<ProductModel> get filteredProducts =>
      _selectedCategory == null ? _products : _filteredProducts;

  List<ProductModel> get searchedProducts =>
      _searchQuery.isEmpty ? filteredProducts : _searchedProducts;

  Stream<List<ProductModel>> get searchedProductsStream =>
      _searchedProductsSubject.stream;

  // Load API services and fetch categories + products
  Future<void> updateApiService(ApiService apiService) async {
    _productService = ProductService(apiService);
    await Future.wait([
      loadCategories(),
      loadProducts(),
    ]);
  }

  // Load categories from API
  Future<void> loadCategories() async {
    try {
      _categories = await _categoryService.fetchCategories();
    } catch (e) {
      print('Error loading categories: $e');
      _categories = []; // fallback
    }
    notifyListeners();
  }

  // Load products from API
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      print('Error fetching products: $e');
      _products = []; // fallback
    }
    _isLoading = false;
    _applyFilters();
    notifyListeners();
  }

  // Filter by selected category
  void filterByCategory(CategoryType category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Text-based search
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

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

  // Core filter logic for both category + search
  void _applyFilters() {
    _filteredProducts = _selectedCategory == null
        ? _products
        : _products.where((product) =>
    product.category.toLowerCase() ==
        _selectedCategory!.value.toLowerCase()).toList();

    if (_searchQuery.isEmpty) {
      _searchedProducts = [];
      _searchedProductsSubject.add(_filteredProducts);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _searchedProducts = _filteredProducts
          .where((product) =>
          product.name.toLowerCase().contains(lowerQuery))
          .toList();
      _searchedProductsSubject.add(_searchedProducts);
    }
  }
  Future<ProductModel> fetchProductById(String id) async {
    try {
      return await _productService.fetchProductDetails(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product by ID: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _searchedProductsSubject.close();
    super.dispose();
  }

}
