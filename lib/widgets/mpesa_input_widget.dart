import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/utils/constants.dart'; // For consistent colors & spacing

Future<bool> showMpesaPhoneInputModal(BuildContext context) async {
  final paymentProvider = context.read<PaymentProvider>();
  final TextEditingController controller = TextEditingController(
    text: (paymentProvider.phoneNumber?.length == 9) ? paymentProvider.phoneNumber : '',
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mobile_friendly, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  "Enter M-Pesa Number",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We'll send an STK push to this number for payment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                /// Phone Input
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: const TextStyle(letterSpacing: 1.0),
                  decoration: InputDecoration(
                    labelText: 'Safaricom Phone Number',
                    labelStyle: const TextStyle(color: AppColors.text),
                    prefixText: '+254 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background.withAlpha(13),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Phone number is required';
                    } else if (trimmed.length != 9 || !RegExp(r'^[17]\d{8}$').hasMatch(trimmed)) {
                      return 'Enter a valid Safaricom number (e.g. 712345678)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                /// Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            paymentProvider.setPhoneNumber(controller.text.trim());
                            Navigator.pop(ctx, true);
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}
