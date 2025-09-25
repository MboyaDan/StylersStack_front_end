import 'package:flutter/material.dart';

class PaymentMethod {
  final String name;
  final IconData icon;

  const PaymentMethod({required this.name, required this.icon});
}

const List<PaymentMethod> availablePaymentMethods = [
  PaymentMethod(name: 'Credit Card',
      icon: Icons.credit_card

  ),
  PaymentMethod(name: 'Mpesa', icon: Icons.account_balance_wallet,

  ),
  PaymentMethod(name: 'Cash on Delivery', icon: Icons.money),
];
