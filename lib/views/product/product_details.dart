import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({required this.product, Key? key}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late ProductModel product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    product.selectedSize = product.sizes.first;
    product.selectedColor = product.colors.first;
  }

  void _showAddToCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to Cart?', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addToCart(product);
                      Navigator.pop(context);
                    },
                    child: Text("Yes, Add"),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Product Images
              SizedBox(
                height: 250,
                child: PageView(
                  children: product.images.map((img) => Image.network(img, fit: BoxFit.cover)).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Rating
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

              // Select Size
              Text("Select Size", style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: product.sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: product.selectedSize == size,
                    onSelected: (_) {
                      setState(() => product.selectedSize = size);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Select Color
              Text("Select Color", style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: product.colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => product.selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 14,
                      child: product.selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Total Price + Add to Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Price: \$${product.price.toStringAsFixed(2)}",
                      style: theme.textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: () => _showAddToCartSheet(context),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Add to Cart"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
