import 'package:flutter/material.dart';
import 'package:stylerstack/services/payment_service.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class PaymentProvider extends ChangeNotifier {
  late PaymentService _paymentService;

  PaymentProvider(ApiService apiService) {
    updateApi(apiService);
  }

  void updateApi(ApiService apiService) {
    _paymentService = PaymentService(apiService);
  }

  String? _selectedMethod;
  bool _isLoading = false;
  PaymentModel? _payment;
  String? _error;

  // Getters
  String? get selectedMethod => _selectedMethod;
  bool get isLoading => _isLoading;
  PaymentModel? get payment => _payment;
  String? get error => _error;

  // Set payment method
  void setPaymentMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  // Initiate payment
  Future<void> initiatePayment({
    required double amount,
    required String currency,
    required String orderId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.initiatePayment(
        amount: amount,
        currency: currency,
        paymentMethod: _selectedMethod!,
        orderId: orderId,
      );
      _payment = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
