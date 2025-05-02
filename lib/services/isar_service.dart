import 'package:isar/isar.dart';
import '../models/cart_item.dart';
import '../models/favorite_item.dart';
import 'package:path_provider/path_provider.dart';


class IsarService {
  static late final Isar _isar;

  // Call this when app starts
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [CartItemModelSchema, FavoriteItemSchema],
      directory: dir.path,
    );
  }

  static Isar get instance => _isar;

  // Fetch cart items from Isar
  Future<List<CartItemModel>> fetchCartItems(String userId) async {
    return _isar.collection<CartItemModel>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<void> saveCartItems(List<CartItemModel> cartItems, String userId) async {
    await _isar.writeTxn(() async {
      await _isar.collection<CartItemModel>()
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
      await _isar.collection<CartItemModel>().putAll(cartItems);
    });
  }

  Future<void> clearCartItems(String userId) async {
    await _isar.writeTxn(() async {
      await _isar.collection<CartItemModel>()
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  Future<List<FavoriteItem>> fetchFavorites(String userId) async {
    return _isar.collection<FavoriteItem>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<void> saveFavorites(List<FavoriteItem> favorites, String userId) async {
    await _isar.writeTxn(() async {
      await _isar.collection<FavoriteItem>()
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
      await _isar.collection<FavoriteItem>().putAll(favorites);
    });
  }

  Future<void> removeFavorite(String productId, String userId) async {
    await _isar.writeTxn(() async {
      await _isar.collection<FavoriteItem>()
          .filter()
          .productIdEqualTo(productId)
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  Future<void> clearFavorites(String userId) async {
    await _isar.writeTxn(() async {
      await _isar.collection<FavoriteItem>()
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }
}
