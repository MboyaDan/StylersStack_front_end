import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/widgets/mpesa_input_widget.dart';

import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';
import 'package:stylerstack/utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final currentAddress = context.read<AddressProvider>().address;

    // --- Validations ---
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

    // --- M-Pesa phone number input ---
    if (paymentProvider.selectedMethod == 'mpesa') {
      if (paymentProvider.phoneNumber == null || paymentProvider.phoneNumber!.isEmpty) {
        final result = await showMpesaPhoneInputModal(context);
        if (!result || paymentProvider.phoneNumber == null || paymentProvider.phoneNumber!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mpesa phone number is required.')),
          );
          return;
        }
      }
    }

    // --- Payment Logic ---
    setState(() => _isLoading = true);
    try {
      await paymentProvider.initiatePayment(
        amount: cartProvider.totalCartPrice,
        currency: 'Ksh',
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        paymentMethod: paymentProvider.selectedMethod!.toLowerCase(),
        phoneNumber: paymentProvider.selectedMethod == 'mpesa'
            ? paymentProvider.phoneNumber
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment initated,awaiting confirmation')),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during payment:  ${paymentProvider.error}')),
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
                const OrderSummaryWidget(),
                const SizedBox(height: 20),

                // --- Shipping Address ---
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text('Shipping Address'),
                    subtitle: Text(addressProvider.displayAddress),
                    trailing: const Icon(Icons.edit, color: AppColors.primary),
                    onTap: () => context.push('/shipping-address'),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Payment Method ---
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text('Payment Method'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(paymentProvider.selectedMethod ?? 'Not selected'),
                        if (paymentProvider.selectedMethod == 'mpesa' &&
                            paymentProvider.phoneNumber != null &&
                            paymentProvider.phoneNumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Phone: ${paymentProvider.phoneNumber}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.payment, color: AppColors.primary),
                    onTap: () async {
                      final previousMethod = paymentProvider.selectedMethod;
                      await context.push('/payment-method');
                      if (paymentProvider.selectedMethod != previousMethod) {
                        paymentProvider.setPhoneNumber(null); // 🔁 Reset M-Pesa number
                      }
                    },
                  ),
                ),

                const Spacer(),

                // --- Pay Button ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handlePayment,
                  child: const Text(
                    'Proceed to Payment',
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

          // --- Loading Overlay ---
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
