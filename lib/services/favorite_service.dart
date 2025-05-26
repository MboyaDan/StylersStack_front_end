import 'package:dio/dio.dart';
import 'package:stylerstack/services/api_service.dart';
import '../models/favorite_item.dart';

class FavoriteService {
  final ApiService _apiService;
  FavoriteService(this._apiService);

  /// Fetch all favorite items for the current user from the API
  Future<List<FavoriteItem>> fetchFavorites(String userId) async {
    try {
      final Response response = await _apiService.getRequest('/favorites');

      final List<dynamic> data = response.data;
      return data.map((item) => FavoriteItem.fromJson(item, userId)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load favorites: ${e.message}');
    }
  }

  /// Add a product to the favorites list
  Future<void> addFavorite(FavoriteItem favoriteItem) async {
    try {
      final Response response = await _apiService.postRequest('favorites', favoriteItem.toJson());

      if (response.statusCode != 200) {
        throw Exception('Failed to add item to favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to add item to favorites: ${e.message}');
    }
  }

  /// Remove a product from the favorites list
  Future<void> removeFavorite(String productId) async {
    try {
      final Response response = await _apiService.deleteRequest('favorites', data: {
        'productId': productId,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to remove item from favorites: ${e.message}');
    }
  }
}
