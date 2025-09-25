import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/models/product_model.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/widgets/appsnackwidget.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.product, super.key});
  final ProductModel product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ProductModel product;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    product = widget.product;
    if (product.sizes.isNotEmpty) {
      product.selectedSize = product.sizes.first;
    }
    if (product.colors.isNotEmpty) {
      product.selectedColor = product.colors.first;
    }
  }

  Future<void> _showAddToCartSheet() async {
    final bool? added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///remove const, use runtime theme-based color
              const Icon(Icons.shopping_bag_outlined,
                  size: 36, color: AppColors.brown),

              const SizedBox(height: 12),
              Text(
                'Add this item to your cart?',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cart = sheetContext.read<CartProvider>();
                        CartItemModel? existing;
                        try {
                          existing = cart.cartItems
                              .firstWhere((e) => e.productId == product.id);
                        } catch (_) {
                          existing = null;
                        }

                        if (existing != null) {
                          cart.updateCartItem(
                              product.id, existing.quantity + 1);
                        } else {
                          cart.addToCart(
                            productId: product.id,
                            productName: product.name,
                            productPrice: product.price,
                            productImageUrl: product.images.isNotEmpty
                                ? product.images.first
                                : "",
                          );
                        }

                        Navigator.pop(sheetContext, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Yes, Add to Cart",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel"
                          , style: TextStyle(color: Colors.black),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || added != true) return;

    AppSnackbar.show(
      context,
      message: 'Product added successfully',
      type: SnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background(context), //
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Product Details',
            style: TextStyle(color: Colors.black45)),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.button2, //  fixed
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _showAddToCartSheet,
              icon: Icon(Icons.shopping_bag,
                  color: AppColors.text(context)), //
              label: Text('Add to Cart',
                  style: TextStyle(color: AppColors.text(context)),),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image Carousel or Placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.4,
                        child: product.images.isEmpty
                            ? const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey,),
                        )
                            : PageView.builder(
                          controller: _pageController,
                          itemCount: product.images.length,
                          itemBuilder: (_, index) {
                            return Hero(
                              tag: 'product_${product.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image,
                                      size: 80,),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (product.images.isNotEmpty)
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: product.images.length,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColors.button, //
                            dotColor: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Title, Rating, Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating.toDouble(),
                            itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('${product.rating}',
                              style: TextStyle(color: Colors.grey[700])),
                          const Spacer(),
                          Text(
                            'Ksh${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Size Selection
                if (product.sizes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Size", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: product.sizes.map((size) {
                            return ChoiceChip(
                              label: Text(size),
                              selected: product.selectedSize == size,
                              onSelected: (_) =>
                                  setState(() => product.selectedSize = size),
                              selectedColor: AppColors.button2,
                              labelStyle: TextStyle(
                                color: product.selectedSize == size
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                /// Color Selection
                if (product.colors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Color",
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: product.colors.map((color) {
                            final isSelected =
                                product.selectedColor == color;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => product.selectedColor = color),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 18,
                                child: isSelected
                                    ? Icon(Icons.check,
                                    color: AppColors.text(context),)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
