// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/widgets/product_card.dart';
import 'package:stylerstack/extensions/favorite_item_extensions.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();
    final favorites   = favProvider.favorites;

    final screenWidth   = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: favProvider.loadFavorites,   // pull-to-refresh
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: favorites.isEmpty
              ? const Center(child: Text('You haven’t liked anything yet.'))
              : GridView.builder(
            itemCount: favorites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final fav = favorites[index];

              return InkWell(
                onTap: () async {
                  try {
                    final product = await context.read<ProductProvider>().fetchProductById(fav.productId);
                    if (context.mounted) {
                      await context.push('/product-details', extra: product);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to load product details')),
                    );
                  }
                }

                ,
                borderRadius: BorderRadius.circular(12),
                child: ProductCard(
                  product: fav.toProductModel(),
                  isFavorite: true,
                  onToggleFavorite: () async =>
                      favProvider.removeFavorite(fav.productId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
