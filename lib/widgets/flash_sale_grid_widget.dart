import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/product_provider.dart';

class FlashSaleGridWidget extends StatelessWidget {
  const FlashSaleGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final flashSaleItems = context.watch<ProductProvider>().flashSaleProducts;

    return GridView.builder(
      itemCount: flashSaleItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final product = flashSaleItems[index];
        final discountedPrice = product.price - (product.price * (product.discount ?? 0) / 100);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.images.isNotEmpty
                      ? Image.network(
                    product.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 80),
                  ),
                ),
              ),

              // Product name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Prices and discount
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      "KES ${discountedPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if ((product.discount ?? 0) > 0)
                      Text(
                        "KES ${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Optional: Discount badge
              if ((product.discount ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "-${product.discount!.toInt()}%",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
