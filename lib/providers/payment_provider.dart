import 'package:flutter/material.dart';
import 'package:stylerstack/services/payment_service.dart';

import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier{
  final PaymentService _paymentService = PaymentService();

  late final String _userId;
  final List<PaymentModel> _payments = [];
  final bool _isLoading = false;



  //getters
  bool get isLoading => _isLoading;

}