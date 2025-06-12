import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';

Future<bool> showMpesaPhoneInputModal(BuildContext context) async {
  final paymentProvider = context.read<PaymentProvider>();
  final TextEditingController controller = TextEditingController(
    text: (paymentProvider.phoneNumber?.length == 9) ? paymentProvider.phoneNumber : '',
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter M-Pesa Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text(
                "We'll send an STK push to this number.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+254 ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Enter phone number';
                  } else if (trimmed.length != 9 || !RegExp(r'^[17]\d{8}$').hasMatch(trimmed)) {
                    return 'Enter a valid Safaricom number (e.g. 712345678)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          paymentProvider.setPhoneNumber(controller.text.trim());
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
