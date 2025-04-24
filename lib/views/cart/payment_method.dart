import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    void _selectPayment(String method) {
      cartProvider.setPaymentMethod(method);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Method")),
      backgroundColor: const Color(0xFFF6F6F6),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentOption(context, "Credit Card", Icons.credit_card, _selectPayment),
          _buildPaymentOption(context, "PayPal", Icons.account_balance_wallet, _selectPayment),
          _buildPaymentOption(context, "Cash on Delivery", Icons.money, _selectPayment),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String method, IconData icon, Function(String) onSelect) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(method),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelect(method),
      ),
    );
  }
}
