import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 30),
            Text("Payment Successful!",
                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.brown, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text("Your order has been placed successfully. We'll send you updates soon.",
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).clearCart();
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDCC6B0),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Back to Home"),
            )
          ],
        ),
      ),
    );
  }
}
