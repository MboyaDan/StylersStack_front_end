import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/models/product_model.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/services/share_service.dart';
class ReelsScreen extends StatefulWidget {
  final List<ProductModel> products;

  const ReelsScreen({super.key, required this.products});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final favProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          final isFavorite = favProvider.isProductFavorite(product.id);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ────────── Background (first product image) ──────────
              if (product.images.isNotEmpty)
                Image.network(
                  product.images.first,
                  fit: BoxFit.cover,
                ),

              // ────────── Gradient Overlay for text readability ──────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // ────────── Bottom Info & Right Controls ──────────
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: Product info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: TikTok-style buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Favorite ❤️
                          IconButton(
                            onPressed: () async {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login required to favorite"),
                                  ),
                                );
                                return;
                              }

                              final favItem = FavoriteItem(
                                userId: uid,
                                productId: product.id,
                                productName: product.name,
                                imageUrl: product.images.isNotEmpty
                                    ? product.images.first
                                    : "",
                                price: product.price,
                              );

                              await favProvider.toggleFavorite(favItem);
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Add to Cart 🛒
                          IconButton(
                            onPressed: () async {
                              await cartProvider.addToCart(
                                productId: product.id,
                                productName: product.name,
                                productPrice: product.price,
                                productImageUrl: product.images.isNotEmpty
                                    ? product.images.first
                                    : "",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added to cart"),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Share
                          IconButton(
                            onPressed: () async {
                              await ShareService.shareProduct(
                                text: "Check out this product: ${product.name} for \$${product.price}",
                                imageUrl: product.images.isNotEmpty ? product.images.first : null,
                              );
                            },
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),


                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
