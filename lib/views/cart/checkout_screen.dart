import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const OrderSummaryWidget(),

            const SizedBox(height: 20),

            // Shipping address
            ListTile(
              title: const Text("Shipping Address"),
              subtitle: Text(cartProvider.shippingAddress ?? "Not provided"),
              trailing: TextButton(
                onPressed: () => context.push('/shipping-address'),
                child: const Text("Edit"),
              ),
            ),

            // Payment method
            ListTile(
              title: const Text("Payment Method"),
              subtitle: Text(cartProvider.paymentMethod ?? "Not selected"),
              trailing: TextButton(
                onPressed: () => context.push('/payment-method'),
                child: const Text("Change"),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDCC6B0),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (cartProvider.shippingAddress == null || cartProvider.paymentMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please complete shipping and payment information."),
                  ));
                } else {
                  context.push('/payment-success');
                }
              },
              child: const Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
