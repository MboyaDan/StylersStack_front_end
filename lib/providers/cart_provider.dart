import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  // ────────── Services ──────────
  final CartService _cartService;
  CartProvider(ApiService api) : _cartService = CartService(api) {
    // listen for background changes to the Hive box
    _cartBox.watch().listen((_) => notifyListeners());
  }

  // ────────── Hive ──────────
  final Box<CartItemModel> _cartBox = Hive.box<CartItemModel>('cartBox');

  // ────────── PromoCode ──────────
  String? _appliedPromoCode;
  double  _discountPercentage = 0.0;

  // ────────── Loading flag ──────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ────────── Auth helper ──────────
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ────────── Public getters ──────────
  List<CartItemModel> get cartItems =>
      _uid == null
          ? []
          : _cartBox.values.where((e) => e.userId == _uid).toList();

  double get totalCartPrice {
    final total =
    cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    return total - (total * _discountPercentage);
  }
int get cartCount => cartItems.fold(0,(sum,item)=> sum + item.quantity);

  //int get cartUniqueCount => cartItems.length;
  // ────────── Composite key helper ──────────
  String _key(String uid, String productId) => '${uid}_$productId';

  /*──────────────────── Promo Code ────────────────────*/

  void applyPromoCode(String code) {
    if (code.trim().toLowerCase() == 'styler10') {
      _appliedPromoCode = code;
      _discountPercentage = 0.10;
    } else {
      _appliedPromoCode = null;
      _discountPercentage = 0.0;
    }
    notifyListeners();
  }

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  /*──────────────────── API ↔ Hive sync ────────────────────*/

  Future<void> fetchCartFromApi() async {
    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.fetchCartItems(userId: uid);
      await _cartBox.clear();                 // wipe local cache
      for (final item in items) {
        await _cartBox.put(_key(uid, item.productId), item);
      }
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
    final uid = _uid;
    if (uid == null) return;

    final hiveKey = _key(uid, productId);

    try {
      // optimistic UI: update local first
      final existing = _cartBox.get(hiveKey);
      final newQty   = existing == null ? quantity : existing.quantity + quantity;

      await _cartBox.put(
        hiveKey,
        CartItemModel(
          userId: uid,
          productId: productId,
          productName: productName,
          productPrice: productPrice,
          productImageUrl: productImageUrl,
          quantity: newQty,
        ),
      );
      notifyListeners();

      // fire-&-forget API call
      await _cartService.addItemToCart(productId: productId, quantity: quantity);
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    final uid = _uid;
    if (uid == null) return;

    final hiveKey = _key(uid, productId);

    try {
      await _cartBox.delete(hiveKey);
      notifyListeners();
      await _cartService.removeItemFromCart(productId: productId);
    } catch (e) {
      debugPrint('Remove from cart error: $e');
    }
  }

  Future<void> updateCartItem(String productId, int newQty) async {
    final uid = _uid;
    if (uid == null) return;

    final hiveKey = _key(uid, productId);

    try {
      final item = _cartBox.get(hiveKey);
      if (item == null) return;

      item.quantity = newQty;
      await _cartBox.put(hiveKey, item);
      notifyListeners();

      await _cartService.updateItemQuantity(productId: productId, quantity: newQty);
    } catch (e) {
      debugPrint('Update cart error: $e');
    }
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;

    final keys = _cartBox.keys.where((k) => k.toString().startsWith('${uid}_'));
    await _cartBox.deleteAll(keys);
    notifyListeners();
    // Optionally call backend endpoint to clear entire cart
  }
}
