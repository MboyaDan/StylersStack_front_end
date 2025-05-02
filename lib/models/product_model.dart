import 'dart:ui';

class ProductModel {
  final String id;
  final String name;
  final List <String> images;
  final double price;
  final String category;
  final int stock;
  final double? discount;
  final int rating;
  final List <String> sizes;
  final List<Color> colors;
  final String description;

  //for the UI
  String?selectedSize;
  Color?selectedColor;

  ProductModel({
    required this.description,
    required this.colors,
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.category,
    required this.stock,
    required this.rating,
    this.discount,
    required this.sizes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      images: List<String>.from(json['image_url']),
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      rating: json['rating'] ?? 0,
      discount: (json['discount'] ?? 0).toDouble(),
      sizes: List<String>.from(json['size']),
      colors: List<int>.from(json['color']).map((c) => Color(c)).toList(),
      description: json['description'] ?? '',
    );
  }

}
