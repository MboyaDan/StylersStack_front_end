import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/main.dart';
import 'package:stylerstack/providers/Notification_provider.dart';
import 'package:stylerstack/widgets/appsnackwidget.dart';
import 'package:stylerstack/widgets/mpesa_input_widget.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/widgets/order_summary_widget.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/services/payment_ui_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Timer? _paymentTimeoutTimer;

  @override
  @override
  void initState() {
    super.initState();
    PaymentUIService.retryAttempts = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationProvider.resetFlag();
    });
  }


  Future<void> _handlePayment() async {

    final notifProvider = context.read<NotificationProvider?>();
    notifProvider?.resetNavigatedToSuccess();

    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final currentAddress = context.read<AddressProvider>().address;

    if (currentAddress == null) {
      AppSnackbar.show(
        context,
        message: 'Please add a shipping address.',
        type: SnackbarType.warning,
      );
      return;
    }

    if (paymentProvider.selectedMethod == null) {
      AppSnackbar.show(
        context,
        message: 'Please choose a payment method.',
        type: SnackbarType.error,
      );
      return;
    }

    if (paymentProvider.selectedMethod == 'mpesa') {
      if (paymentProvider.phoneNumber == null || paymentProvider.phoneNumber!.isEmpty) {
        final result = await showMpesaPhoneInputModal(context);
        if (!result || paymentProvider.phoneNumber == null || paymentProvider.phoneNumber!.isEmpty) {
          AppSnackbar.show(
            context,
            message: 'Mpesa phone number is required.',
            type: SnackbarType.warning,
          );
          return;
        }
      }
    }

    final amount = cartProvider.totalCartPrice;
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    PaymentUIService.showProcessingDialog(context, amount);

    _paymentTimeoutTimer?.cancel();
    _paymentTimeoutTimer = Timer(const Duration(seconds: 30), () async {
      PaymentUIService.closeDialogIfOpen(context);
      await PaymentUIService.showRetryDialog(context, amount, _handlePayment);
    });

    PaymentUIService.paymentTimeoutCallback = () {
      _paymentTimeoutTimer?.cancel();
    };

    try {
      await paymentProvider.initiatePayment(
        amount: amount,
        currency: 'Ksh',
        orderId: orderId,
        paymentMethod: paymentProvider.selectedMethod!.toLowerCase(),
        phoneNumber: paymentProvider.selectedMethod == 'mpesa'
            ? paymentProvider.phoneNumber
            : null,
      );
    }  catch (e, stack) {
      _paymentTimeoutTimer?.cancel();
      PaymentUIService.closeDialogIfOpen(context);

      debugPrint("❌ Caught exception during payment: $e");
      debugPrint("📌 Stacktrace: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during payment: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _paymentTimeoutTimer?.cancel();
    PaymentUIService.resetRetryAttempts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Details'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.padding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const OrderSummaryWidget(),
                      const SizedBox(height: 20),

                      _buildSectionCard(
                        title: 'Shipping Address',
                        subtitle: addressProvider.displayAddress,
                        icon: Icons.edit_location_alt_outlined,
                        onTap: () => context.push('/shipping-address'),
                      ),
                      const SizedBox(height: 12),

                      _buildSectionCard(
                        title: 'Payment Method',
                        subtitle: paymentProvider.selectedMethod ?? 'Not selected',
                        icon: Icons.payment_outlined,
                        additionalInfo: (paymentProvider.selectedMethod == 'mpesa' &&
                            paymentProvider.phoneNumber != null &&
                            paymentProvider.phoneNumber!.isNotEmpty)
                            ? 'Phone: ${paymentProvider.phoneNumber}'
                            : null,
                        onTap: () async {
                          final previousMethod = paymentProvider.selectedMethod;
                          await context.push('/payment-method');
                          if (paymentProvider.selectedMethod != previousMethod) {
                            paymentProvider.setPhoneNumber(null);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_outline),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.text,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                      ),
                    ),
                    onPressed: _handlePayment,
                    label: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? additionalInfo,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    if (additionalInfo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          additionalInfo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
