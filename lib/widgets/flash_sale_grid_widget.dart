import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'flash_sale_banner.dart';
import 'product_card.dart';

class FlashSaleGridWidget extends StatelessWidget {
  const FlashSaleGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> flashSaleItems =
        context.watch<ProductProvider>().flashSaleProducts;

    if (flashSaleItems.isEmpty) {
      return const Center(
        child: Text(
          "🚀 No flash sale products right now",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flash Sale Countdown Banner
        FlashSaleBanner(endTime: DateTime.now().add(const Duration(hours: 5))),

        const SizedBox(height: 12),

        //  Grid of clickable ProductCards
        GridView.builder(
          itemCount: flashSaleItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = flashSaleItems[index];

            return Stack(
              children: [
                // Reuse ProductCard for consistency
              ProductCard(
              product: product,
              onTap: () async {
                await context.push('/product-details', extra: product);
              },
            ),

                //Discount badge overlay (only for flash sale)
                if ((product.discount ?? 0) > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "-${product.discount!.toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
