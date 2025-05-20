import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';
import '../../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Safe async context usage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CartProvider>().clearCart();
    });
  }

  Future<void> _handlePayment() async {
    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final currentAddress = context.read<AddressProvider>().address;

    if (currentAddress == null || paymentProvider.selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete shipping and payment information.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await paymentProvider.initiatePayment(
        amount: cartProvider.totalCartPrice,
        currency: "Ksh",
        orderId: "ORD-${DateTime.now().millisecondsSinceEpoch}",
      );

      if (paymentProvider.payment != null) {
        if (!mounted) return;
        await context.push('/payment-success');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: ${paymentProvider.error}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during payment: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currentAddress = context.watch<AddressProvider>().address;
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Details')),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.padding),
            child: Column(
              children: [
                const OrderSummaryWidget(),
                const SizedBox(height: 20),

                // Shipping address
                ListTile(
                  title: const Text("Shipping Address"),
                  subtitle: Text(context.watch<AddressProvider>().displayAddress),
                  trailing: TextButton(
                    onPressed: () => context.push('/shipping-address'),
                    child: const Text("Edit"),
                  ),
                ),

                // Payment method
                ListTile(
                  title: const Text("Payment Method"),
                  subtitle: Text(paymentProvider.selectedMethod ?? "Not selected"),
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
                  onPressed: _isLoading ? null : _handlePayment,
                  child: const Text("Proceed to Payment"),
                ),
              ],
            ),
          ),

          // Optional overlay loader
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
