import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final Box<FavoriteItem> _box;
  FavoriteService _favoriteService;

  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  StreamSubscription? _watchSubscription;

  FavoriteProvider(this._favoriteService, this._box) {
    _watchSubscription = _box.watch().listen((_) => _loadFromCache());
    _loadFromCache(); // Load initially
  }

  int get favoriteCount => _favorites.length;

  void updateService(FavoriteService service) {
    _favoriteService = service;
  }

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('User is not logged in');
    return uid;
  }

  Future<void> loadFavorites() async {
    _loadFromCache();
    unawaited(_refreshFromBackend());
  }

  Future<void> addFavorite(FavoriteItem fav) async {
    try {
      final uid = _uid;
      final favWithUid = fav.copyWith(userId: uid);
      final key = _key(uid, fav.productId);

      await _box.put(key, favWithUid);

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
      final key = _key(uid, productId);

      await _box.delete(key);
      _favorites.removeWhere((f) => f.productId == productId);
      notifyListeners();

      unawaited(_favoriteService.removeFavorite(productId));
    } catch (e, st) {
      debugPrint('Error removing favorite: $e\n$st');
    }
  }

  Future<void> toggleFavorite(FavoriteItem item) async {
    if (isProductFavorite(item.productId)) {
      await removeFavorite(item.productId);
    } else {
      await addFavorite(item);
    }
  }

  Future<void> clearFavoritesOnLogout() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

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

  @override
  void dispose() {
    _watchSubscription?.cancel();
    super.dispose();
  }
}
