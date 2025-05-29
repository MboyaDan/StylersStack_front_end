import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  // ────────── Hive ──────────
  final Box<FavoriteItem> _box;

  // ────────── Services ──────────
  FavoriteService _favoriteService;

  // ────────── State ──────────
  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  /// Safely gets UID or throws
  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('User is not logged in');
    return uid;
  }

  /* ---------- Constructor ---------- */
  FavoriteProvider(this._favoriteService, this._box) {
    _box.watch().listen((_) => _loadFromCache());
  }

  int get favoriteCount => _favorites.length;

  /// Optional: allows swapping service if needed (used in Provider `update`)
  void updateService(FavoriteService service) {
    _favoriteService = service;
  }

  /* ---------- PUBLIC API ---------- */

  /// Load from local cache, then refresh from backend
  Future<void> loadFavorites() async {
    _loadFromCache();                  // Instant load
    unawaited(_refreshFromBackend()); // Silent refresh
  }

  Future<void> addFavorite(FavoriteItem fav) async {
    try {
      final uid = _uid;
      final favWithUid = fav.copyWith(userId: uid);

      await _box.put(_key(uid, fav.productId), favWithUid);

      if (!_favorites.any((f) => f.productId == fav.productId)) {
        _favorites.add(favWithUid);
        notifyListeners();
      }

      unawaited(_favoriteService.addFavorite(favWithUid));
    } catch (e, st) {
      debugPrint('Error adding favorite: $e\n$st');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final uid = _uid;

      await _box.delete(_key(uid, productId));
      _favorites.removeWhere((f) => f.productId == productId);
      notifyListeners();

      unawaited(_favoriteService.removeFavorite(productId));
    } catch (e, st) {
      debugPrint('Error removing favorite: $e\n$st');
    }
  }

  Future<void> clearFavoritesOnLogout() async {
    try {
      final uid = _uid;

      final ids = _box.keys
          .where((k) => k.toString().startsWith('${uid}_'))
          .toList();
      await _box.deleteAll(ids);
      _favorites.clear();
      notifyListeners();
    } catch (e, st) {
      debugPrint('Error clearing favorites: $e\n$st');
    }
  }

  bool isProductFavorite(String productId) =>
      _favorites.any((f) => f.productId == productId);

  /* ---------- INTERNAL Helpers ---------- */

  void _loadFromCache() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      _favorites = uid == null
          ? []
          : _box.values
          .where((f) => f.userId == uid)
          .toList(growable: false);
      notifyListeners();
    } catch (e, st) {
      debugPrint('Cache load error: $e\n$st');
    }
  }

  Future<void> _refreshFromBackend() async {
    try {
      final uid = _uid;

      final remoteFavs = await _favoriteService.fetchFavorites(uid);

      final entries = {
        for (var f in remoteFavs) _key(uid, f.productId): f,
      };
      await _box.putAll(entries);

      _favorites = remoteFavs;
      notifyListeners();
    } catch (e, st) {
      debugPrint('Favorite sync failed: $e\n$st');
    }
  }

  String _key(String uid, String productId) => '${uid}_$productId';
}
