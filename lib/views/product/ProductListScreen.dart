import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        title: const Text("All Products",
          style: TextStyle(color: Colors.black45),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? const Center(child: Text('No products available.'))
            : Consumer<FavoriteProvider>(
          builder: (context, favProvider, child) {
            return GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final isFavorite = favProvider.isProductFavorite(product.id);

                return InkWell(
                  onTap: () async {
                    await context.push('/product-details', extra: product);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: ProductCard(
                    product: product,
                    isFavorite: isFavorite,
                    onToggleFavorite: () async {
                      if (isFavorite) {
                        await favProvider.removeFavorite(product.id);
                      } else {
                        await favProvider.addFavorite(
                          FavoriteItem(
                            productId: product.id,
                            productName: product.name,
                            imageUrl: product.images.isNotEmpty ? product.images.first : '',
                            price: product.price,
                            userId: '', // userId handled internally in provider
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
