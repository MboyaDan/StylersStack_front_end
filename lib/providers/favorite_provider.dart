import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_item.dart';

class FavoriteProvider with ChangeNotifier {
  // The box is opened in main.dart
  final Box<FavoriteItem> _box = Hive.box<FavoriteItem>('favoriteBox');

  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /* ---------- Load ---------- */
  Future<void> loadFavorites() async {
    final uid = _userId;
    _favorites = uid == null
        ? []
        : _box.values.where((f) => f.userId == uid).toList();
    notifyListeners();
  }

  /* ---------- Add ---------- */
  Future<void> addFavorite(FavoriteItem fav) async {
    final uid = _userId;
    if (uid == null) return;

    // build a new object with the correct userId
    final favWithUid = FavoriteItem(
      productId: fav.productId,
      productName: fav.productName,
      imageUrl: fav.imageUrl,
      price: fav.price,
      userId: uid,
    );

    await _box.put(fav.productId, favWithUid);      // key = productId
    _favorites.add(favWithUid);
    notifyListeners();
  }

  /* ---------- Remove ---------- */
  Future<void> removeFavorite(String productId) async {
    final uid = _userId;
    if (uid == null) return;

    _box.delete(productId);
    _favorites.removeWhere((f) => f.productId == productId);
    notifyListeners();
  }

  /* ---------- Clear on logout ---------- */
  Future<void> clearFavorites() async {
    final uid = _userId;
    if (uid == null) return;

    _box.values
        .where((f) => f.userId == uid)
        .map((f) => f.productId)
        .toList()
        .forEach(_box.delete);

    _favorites.clear();
    notifyListeners();
  }

  /* ---------- Helpers ---------- */
  bool isProductFavorite(String productId) =>
      _favorites.any((f) => f.productId == productId);
}
