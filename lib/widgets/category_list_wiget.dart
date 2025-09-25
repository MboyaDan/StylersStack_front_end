import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/utils/constants.dart';
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
          onTap: () async {
            context.read<ProductProvider>().filterByCategory(category);
            await context.push('/category-products', extra: category);
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.background(context),
                child: Icon(category.icon, color: AppColors.brown),
              ),
              const SizedBox(height: 4),
              Text(category.label,
                  style:TextStyle(
                    color: AppColors.text(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),),
            ],
          ),
        );
      }).toList(),
    );
  }
}
