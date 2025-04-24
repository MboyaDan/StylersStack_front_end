import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Image.network(cartItem.product.images[0], height: 60, width: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("\$${cartItem.totalPrice.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => cartProvider.decreaseQuantity(cartItem.product),
                      ),
                      Text(cartItem.quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => cartProvider.increaseQuantity(cartItem.product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => cartProvider.removeFromCart(cartItem.product),
            ),
          ],
        ),
      ),
    );
  }
}
