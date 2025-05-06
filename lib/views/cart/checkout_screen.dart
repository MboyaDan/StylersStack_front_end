import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';
import '../../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currentAddress = context.watch<AddressProvider>().address;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Details')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          children: [
            const OrderSummaryWidget(),
            const SizedBox(height: 20),

            // Shipping address
            ListTile(
              title: const Text("Shipping Address"),
              subtitle: Text(currentAddress == null ? "Not provided" : currentAddress),
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

            // Proceed to payment button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
              ),
              onPressed: () {
                if (currentAddress == null || cartProvider.paymentMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please complete shipping and payment information.")),
                  );
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

