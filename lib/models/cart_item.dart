import 'package:hive/hive.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 0)
class CartItemModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final double productPrice;

  @HiveField(4)
  final String productImageUrl;

  @HiveField(5)
  int quantity;

  CartItemModel({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.quantity,
  });

  double get totalPrice => productPrice * quantity;


/// Factory constructor: Create CartItemModel from API JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json, {required String userId}) {
    final productJson = json['product'];
    return CartItemModel(
      userId: userId,
      productId: productJson['id'] as String,
      productName: productJson['name'] as String,
      productPrice: (productJson['price'] as num).toDouble(),
      productImageUrl: productJson['imageUrl'] as String,
      quantity: (json['quantity'] ?? 1) as int,
    );
  }

  /// Convert CartItemModel back to API JSON
  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': productId,
        'name': productName,
        'price': productPrice,
        'imageUrl': productImageUrl,
      },
      'quantity': quantity,
    };
  }
}
