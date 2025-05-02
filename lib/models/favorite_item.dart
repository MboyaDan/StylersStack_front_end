import 'package:isar/isar.dart';

part 'favorite_item.g.dart';

@Collection()
class FavoriteItem {
  Id id = Isar.autoIncrement;

  late String productId;
  late String productName;
  late String imageUrl;
  late double price;
  late String userId; // for separation

  FavoriteItem();

  // Constructor for creating FavoriteItem from JSON
  factory FavoriteItem.fromJson(Map<String, dynamic> json, String userId) {
    return FavoriteItem()
      ..productId = json['productId']
      ..productName = json['productName']
      ..imageUrl = json['imageUrl']
      ..price = (json['price'] as num).toDouble()
      ..userId = userId;
  }

  // Convert FavoriteItem to JSON for API interaction or other purposes
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}
