import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.product, super.key});

  final ProductModel product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ProductModel product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    product
      ..selectedSize  = product.sizes.first
      ..selectedColor = product.colors.first;
  }

  /* ─── Add-/Update-to-Cart Sheet ─── */

  Future<void> _showAddToCartSheet() async {
    final bool? added = await showModalBottomSheet<bool>(
      context: context, // OK: used synchronously
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to Cart?',
                  style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final cart = sheetContext.read<CartProvider>();

                      // does the item already exist?
                      CartItemModel? existing;
                      try {
                        existing = cart.cartItems
                            .firstWhere((e) => e.productId == product.id);
                      } catch (_) {
                        existing = null;
                      }

                      if (existing != null) {
                        cart.updateCartItem(
                          product.id,
                          existing.quantity + 1,
                        );
                      } else {
                        cart.addToCart(
                          productId: product.id,
                          productName: product.name,
                          productPrice: product.price,
                          productImageUrl: product.images.first,
                        );
                      }

                      // Close sheet and tell caller an item was added
                      Navigator.pop(sheetContext, true);
                    },
                    child: const Text('Yes, Add'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || added != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added to cart')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /* Images */
              SizedBox(
                height: 250,
                child: PageView(
                  children: product.images
                      .map((img) => Image.network(img, fit: BoxFit.cover))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              /* Title & Rating */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name, style: theme.textTheme.headlineSmall),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(product.rating.toString()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(product.description),
              const SizedBox(height: 20),

              /* Size */
              Text('Select Size', style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: product.sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: product.selectedSize == size,
                    onSelected: (_) =>
                        setState(() => product.selectedSize = size),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              /* Color */
              Text('Select Color', style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: product.colors.map((color) {
                  return GestureDetector(
                    onTap: () =>
                        setState(() => product.selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 14,
                      child: product.selectedColor == color
                          ? const Icon(Icons.check,
                          color: Colors.white, size: 16,)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              /* Price + Add-to-Cart */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price: \$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: _showAddToCartSheet,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
