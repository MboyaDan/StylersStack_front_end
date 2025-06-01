import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';
import '../../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  /// Handles the whole pay-and-navigate flow
  Future<void> _handlePayment() async {
    final cartProvider     = context.read<CartProvider>();
    final paymentProvider  = context.read<PaymentProvider>();
    final currentAddress   = context.read<AddressProvider>().address;

    // --- basic validation --
    if (currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a shipping address.')),
      );
      return;
    }
    if (paymentProvider.selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a payment method.')),
      );
      return;
    }

    // --- perform payment ---
    setState(() => _isLoading = true);
    try {
      await paymentProvider.initiatePayment(
        amount   : cartProvider.totalCartPrice,
        currency : 'Ksh',
        orderId  : 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (paymentProvider.payment != null) {
        // Success → clear cart, toast, then navigate
        if (!mounted) return;
        cartProvider.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        await context.push('/payment-success');
      } else {
        // Failure → show reason
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${paymentProvider.error}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during payment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Details')),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.padding),
            child: Column(
              children: [
                // --- order summary -------------------------------------------------
                const OrderSummaryWidget(),
                const SizedBox(height: 20),

                // --- shipping address ---------------------------------------------
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title    : const Text('Shipping Address'),
                    subtitle : Text(addressProvider.displayAddress),
                    trailing : const Icon(Icons.edit, color: AppColors.primary),
                    onTap    : () => context.push('/shipping-address'),
                  ),
                ),
                const SizedBox(height: 12),

                // --- payment method -----------------------------------------------
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title    : const Text('Payment Method'),
                    subtitle : Text(paymentProvider.selectedMethod ?? 'Not selected'),
                    trailing : const Icon(Icons.payment, color: AppColors.primary),
                    onTap    : () => context.push('/payment-method'),
                  ),
                ),

                const Spacer(),

                // --- pay button ----------------------------------------------------
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize    : const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handlePayment,
                  child: const Text('Proceed to Payment',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- loading overlay ---------------------------------------------------
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: (0.3)),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
