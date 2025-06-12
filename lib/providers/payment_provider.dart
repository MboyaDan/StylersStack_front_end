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

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

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
    required String paymentMethod,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.initiatePayment(
        amount: amount,
        currency: currency,
        paymentMethod:paymentMethod,
        orderId: orderId,
        phoneNumber: phoneNumber,
      );
      _payment = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void setPhoneNumber(String? number) {
    _phoneNumber = number;
    notifyListeners();
  }

  Future<void> checkPaymentStatus(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  Future<void> refundPayment(String paymentIntentId, double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
  Future<void> confirmPayment(String paymentIntentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
  void updatePaymentStatusFromFCM(String orderId, String status) {
    if (_payment?.orderId == orderId) {
      _payment = _payment?.copyWith(status: status);
      notifyListeners();
    }
  }
}
