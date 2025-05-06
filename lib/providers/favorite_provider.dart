import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../services/isar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteProvider with ChangeNotifier {
  final IsarService _isarService = IsarService();
  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;
  String? _userId; // Store the current user's ID

  // Load favorites from Isar for the current user
  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _favorites.clear();
      notifyListeners(); // Notify UI when no user is logged in
      return;
    }

    _userId = user.uid;
    try {
      // Fetch favorites from Isar using userId
      _favorites = await _isarService.fetchFavorites(_userId!);
      notifyListeners(); // Notify UI updates
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  // Add a favorite item for the current user
  Future<void> addFavorite(FavoriteItem favoriteItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userId = user.uid; // Set userId from current user
    favoriteItem.userId = _userId!; // Ensure correct userId is added

    try {
      // Add favorite to Isar
      await _isarService.fetchFavorites(_userId!);
      _favorites.add(favoriteItem); // Add to in-memory list
      notifyListeners(); // Notify UI updates
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  // Remove a favorite item for the current user
  Future<void> removeFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userId = user.uid; // Set userId from current user
    try {
      // Remove from Isar based on productId and userId
      await _isarService.removeFavorite(productId, _userId!);
      _favorites.removeWhere((item) => item.productId == productId);
      notifyListeners(); // Notify UI updates
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  // Sync favorites with Isar (load on startup)
  Future<void> syncFavorites() async {
    await loadFavorites(); // Load favorites from Isar for the current user
  }

  // Clear all favorites when the user logs out
  Future<void> clearFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userId = user.uid; // Set userId from current user
    try {
      // Clear favorites from Isar
      await _isarService.clearFavorites(_userId!);
      _favorites.clear(); // Clear in-memory list
      notifyListeners(); // Notify UI updates
    } catch (e) {
      print("Error clearing favorites: $e");
    }
  }

  // Check if a product is already in the favorites list
  bool isProductFavorite(String productId) {
    return _favorites.any((item) => item.productId == productId);
  }
}
