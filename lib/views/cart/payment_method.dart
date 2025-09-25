import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/config/payment_methods.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void selectPayment(String method) {
      context.read<PaymentProvider>().setPaymentMethod(method);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Method")),
      backgroundColor: const Color(0xFFF6F6F6),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availablePaymentMethods.length,
        itemBuilder: (context, index) {
          final method = availablePaymentMethods[index];
          return _buildPaymentOption(context, method.name, method.icon, selectPayment);
        },
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String method, IconData icon, Function(String) onSelect) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.text(context)),
        title: Text(method),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelect(method),
      ),
    );
  }
}
