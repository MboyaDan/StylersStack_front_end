import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/category_type.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: CategoryType.values.map((category) {
        return GestureDetector(
          onTap: () {
            context.read<ProductProvider>().filterByCategory(category);
            context.push('/category-products', extra: category);
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD5C1B1),
                child: Icon(category.icon, color: const Color(0xFF8C4C2F)),
              ),
              const SizedBox(height: 4),
              Text(category.label,
                  style: const TextStyle(color: Color(0xFF4E2A1E))),
            ],
          ),
        );
      }).toList(),
    );
  }
}
