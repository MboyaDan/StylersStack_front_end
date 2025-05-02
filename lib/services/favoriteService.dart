import 'dart:convert';
import 'package:stylerstack/services/api_service.dart';
import '../models/favorite_item.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  /// Fetch all favorite items for the current user from the API
  Future<List<FavoriteItem>> fetchFavorites(String userId) async {
    final response = await _apiService.getRequest('favorites');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Mapping the API response to FavoriteItem models
      return data.map((item) => FavoriteItem.fromJson(item, userId)).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  /// Add a product to the favorites list
  Future<void> addFavorite(FavoriteItem favoriteItem) async {
    final response = await _apiService.postRequest('favorites', favoriteItem.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to favorites');
    }
  }

  /// Remove a product from the favorites list
  Future<void> removeFavorite(String productId) async {
    final response = await _apiService.deleteRequest('favorites', {
      'productId': productId,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from favorites');
    }
  }
}
