import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:stylerstack/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final isOutOfStock = product.stock <= 0;
    final hasDiscount = (product.discount ?? 0) > 0;
    final discountedPrice = (product.price * (1 - (product.discount ?? 0) / 100));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- IMAGE ----------
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl != null
                          ? FadeInImage.assetNetwork(
                        placeholder: ' assets/images/placeholder.jpg',
                        image: imageUrl,
                        fit: BoxFit.cover,
                      )
                          : const Center(child: Icon(Icons.image_not_supported, size: 40)),

                      if (isOutOfStock)
                        Container(
                          color: Colors.black.withAlpha((0.45 * 255).round()),
                          alignment: Alignment.center,
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),

                      if (hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discount?.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: onToggleFavorite,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ---------- PRODUCT INFO ----------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Product Name
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        /// Price Row
                        Row(
                          children: [
                            Text(
                              'Ksh${(hasDiscount ? discountedPrice : product.price).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                'Ksh${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),

                        /// Rating
                        RatingBarIndicator(
                          rating: product.rating.toDouble(),
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          itemSize: 14,
                          unratedColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
