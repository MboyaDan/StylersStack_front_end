import 'dart:convert';
import '../models/cart_item.dart';
import 'api_service.dart';

class CartService {
  final ApiService _apiService = ApiService();

  /// Fetch cart items from API
  Future<List<CartItemModel>> fetchCartItems({required String userId}) async {
    final response = await _apiService.getRequest('cart');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) => CartItemModel.fromJson(item, userId: userId)).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  /// Add item to cart
  Future<void> addItemToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final response = await _apiService.postRequest('cart', {
      'product_id': productId,
      'quantity': quantity,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

  /// Remove item from cart
  Future<void> removeItemFromCart({
    required String productId,
  }) async {
    final response = await _apiService.deleteRequest('cart', {
      'product_id': productId,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from cart');
    }
  }

  /// Update item quantity in cart
  Future<void> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    final response = await _apiService.putRequest('cart', {
      'product_id': productId,
      'quantity': quantity,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item');
    }
  }
}
