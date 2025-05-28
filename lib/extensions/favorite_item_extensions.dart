import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/models/product_model.dart';
import 'package:flutter/material.dart';

extension FavoriteItemMapper on FavoriteItem {
  ProductModel toProductModel() {
    return ProductModel(
      id: productId,
      name: productName,
      images: [imageUrl],
      price: price,
      category: '',        // Default or placeholder
      stock: 0,            // Default or placeholder
      rating: 0,           // Default or placeholder
      sizes: [],           // Default
      colors: [],          // Default
      description: '',     // Optional default
    );
  }
}
