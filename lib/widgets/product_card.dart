import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(product.images as String, height: 120),
        Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text("\$${product.price}"),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 14),
            Text(product.rating.toString()),
          ],
        )
      ],
    );
  }
}
