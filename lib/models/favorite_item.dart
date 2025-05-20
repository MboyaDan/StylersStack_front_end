import 'package:hive/hive.dart';

part 'favorite_item.g.dart';

@HiveType(typeId: 1)   // ← give this typeId a unique number in your app
class FavoriteItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String userId;   // still keep it for multi-user devices

  FavoriteItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.userId,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json, String userId) {
    return FavoriteItem(
      productId: json['productId'],
      productName: json['productName'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'imageUrl': imageUrl,
    'price': price,
  };
}
