import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/isar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final Isar _isar = IsarService.instance;

  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  String? get _userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> loadCartFromLocal() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    _cartItems = await _isar.collection<CartItemModel>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCartFromApi() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.fetchCartItems(userId: userId);

      await _isar.writeTxn(() async {
        await _isar.collection<CartItemModel>()
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
        await _isar.collection<CartItemModel>().putAll(items);
      });

      _cartItems = items;
    } catch (e) {
      debugPrint('Fetch cart error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double productPrice,
    required String productImageUrl,
    int quantity = 1,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _cartService.addItemToCart(
        productId: productId,
        quantity: quantity,
      );

      final newItem = CartItemModel(
        userId: userId,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productImageUrl: productImageUrl,
        quantity: quantity,
      );

      await _isar.writeTxn(() async {
        await _isar.collection<CartItemModel>().put(newItem);
      });

      _cartItems.add(newItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _cartService.removeItemFromCart(
        productId: productId,
      );

      final item = _cartItems.firstWhere((item) => item.productId == productId);

      await _isar.writeTxn(() async {
        await _isar.collection<CartItemModel>().delete(item.id);
      });

      _cartItems.remove(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Remove from cart error: $e');
    }
  }

  Future<void> updateCartItem(String productId, int newQuantity) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _cartService.updateItemQuantity(
        productId: productId,
        quantity: newQuantity,
      );

      final itemIndex = _cartItems.indexWhere((item) => item.productId == productId);

      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity = newQuantity;

        await _isar.writeTxn(() async {
          await _isar.collection<CartItemModel>().put(_cartItems[itemIndex]);
        });

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update cart error: $e');
    }
  }

  double get totalCartPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) return;

    await _isar.writeTxn(() async {
      await _isar.collection<CartItemModel>()
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
    });

    _cartItems.clear();
    notifyListeners();
  }
}
