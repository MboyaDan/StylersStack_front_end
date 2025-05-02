import 'package:isar/isar.dart';

part 'cart_item.g.dart';

@Collection()
class CartItemModel {
  Id id = Isar.autoIncrement; // Auto-incrementing primary key

  late String userId; // 🛡️ Important: Separate each user's cart items

  late String productId;
  late String productName;
  late double productPrice;
  late String productImageUrl;

  int quantity = 1; // Default to 1

  CartItemModel({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    this.quantity = 1,
  });

  /// Total price (computed)
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
