class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final int stock;
  final double? discount;
  final int rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.stock,
    required this.rating,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['image_url'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      rating: json['rating'],
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }
}
