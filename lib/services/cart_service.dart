import  'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:dio/dio.dart';

class CartService {
  final ApiService _apiService;
  CartService(this._apiService);

  /// Fetch cart items from API
  Future<List<CartItemModel>> fetchCartItems({required String userId}) async {
    try {
      final Response response = await _apiService.getRequest('/cart');

      // Dio decodes JSON automatically into a List/Map
      final List<dynamic> data = response.data;

      return data.map((item) => CartItemModel.fromJson(item, userId: userId)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load cart items: ${e.message}');
    }
  }

  /// Add item to cart
  Future<void> addItemToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final Response response = await _apiService.postRequest('cart', {
        'product_id': productId,
        'quantity': quantity,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to add item to cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to add item to cart: ${e.message}');
    }
  }

  /// Remove item from cart
  Future<void> removeItemFromCart({
    required String productId,
  }) async {
    try {
      final Response response = await _apiService.deleteRequest('cart', data: {
        'product_id': productId,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to remove item from cart: ${e.message}');
    }
  }

  /// Update item quantity in cart
  Future<void> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final Response response = await _apiService.putRequest('cart', {
        'product_id': productId,
        'quantity': quantity,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to update cart item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update cart item: ${e.message}');
    }
  }
}
