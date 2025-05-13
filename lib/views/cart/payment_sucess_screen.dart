import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../utils/constants.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // Delay the clear calls to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<CartProvider>().clearCart();
        context.read<AddressProvider>().clearAddress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 100),

              const SizedBox(height: 20),

              Text(
                "Payment Successful!",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Thank you for your purchase.",
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  ),
                ),
                onPressed: () {
                  context.go('/'); // Navigate back to home
                },
                child: const Text("Continue Shopping"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
