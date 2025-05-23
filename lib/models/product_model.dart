import 'dart:ui';

class ProductModel {
  final String id;
  final String name;
  final List<String> images;
  final double price;
  final String category;
  final int stock;
  final double? discount;
  final int rating;
  final List<String> sizes;
  final List<Color> colors;
  final String description;

  // UI fields — mutable
  String? selectedSize;
  Color? selectedColor;

  ProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.category,
    required this.stock,
    required this.rating,
    required this.sizes,
    required this.colors,
    required this.description,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(num? v) => (v ?? 0).toDouble();

    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      images: List<String>.from(json['images'] ?? const []),
      price: _toDouble(json['price']),
      discount: json['discount'] == null ? null : _toDouble(json['discount']),
      category: json['category'] is Map
          ? (json['category']['name'] ?? '')
          : (json['category'] ?? ''),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      sizes: List<String>.from((json['sizes'] ?? const []).map((e) => e.toString())),
      colors: (json['colors'] as List? ?? const []).map((c) => Color(c as int)).toList(),
      description: json['description'] ?? '',
    );
  }
}
