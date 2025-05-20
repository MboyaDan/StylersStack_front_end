import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:stylerstack/services/api_service.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  CartProvider(ApiService apiService) : _cartService = CartService(apiService);

  final Box<CartItemModel> _cartBox = Hive.box<CartItemModel>('cartBox');
  String? _appliedPromoCode;
  double _discountPercentage = 0.0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CartItemModel> get cartItems => _cartBox.values.toList();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  void applyPromoCode(String code) {
    if (code.trim().toLowerCase() == 'styler10') {
      _appliedPromoCode = code;
      _discountPercentage = 0.1;
    } else {
      _appliedPromoCode = null;
      _discountPercentage = 0.0;
    }
    notifyListeners();
  }

  Future<void> fetchCartFromApi() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.fetchCartItems(userId: userId);
      await _cartBox.clear();
      for (var item in items) {
        _cartBox.put(item.productId, item);
      }
    } catch (e) {
      debugPrint('Fetch cart error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart({required String productId, required String productName, required double productPrice, required String productImageUrl, int quantity = 1}) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _cartService.addItemToCart(productId: productId, quantity: quantity);

      final item = CartItemModel(
        userId: userId,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productImageUrl: productImageUrl,
        quantity: quantity,
      );

      _cartBox.put(productId, item);
      notifyListeners();
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _cartService.removeItemFromCart(productId: productId);
      _cartBox.delete(productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Remove from cart error: $e');
    }
  }

  Future<void> updateCartItem(String productId, int newQuantity) async {
    try {
      await _cartService.updateItemQuantity(productId: productId, quantity: newQuantity);

      final item = _cartBox.get(productId);
      if (item != null) {
        item.quantity = newQuantity;
        await _cartBox.put(productId, item);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update cart error: $e');
    }
  }

  double get totalCartPrice {
    final total = _cartBox.values.fold(0.0, (sum, item) => sum + item.totalPrice);
    return total - (total * _discountPercentage);
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
    notifyListeners();
  }
}

