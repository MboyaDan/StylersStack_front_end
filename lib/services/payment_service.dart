import 'package:dio/dio.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class PaymentService {
  final ApiService _apiService;
  PaymentService(this._apiService);

  /// Initiate payment and return PaymentModel
  Future<PaymentModel> initiatePayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String orderId,
  }) async {
    try {
      final Response response = await _apiService.postRequest(
        'payment/initiate',
        {
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
          'order_id': orderId,
        },
      );

      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to initiate payment: ${e.message}');
    }
  }

  /// Confirm payment
  Future<bool> confirmPayment({required String paymentIntentId}) async {
    try {
      final Response response = await _apiService.postRequest(
        'payment/confirm',
        {
          'payment_intent_id': paymentIntentId,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to confirm payment: ${e.message}');
    }
  }

  /// Fetch payment status
  Future<PaymentModel> fetchPaymentStatus({required String orderId}) async {
    try {
      final Response response = await _apiService.getRequest('payment/status/$orderId');

      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch payment status: ${e.message}');
    }
  }

  /// Refund payment (optional)
  Future<bool> refundPayment({
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      final Response response = await _apiService.postRequest(
        'payment/refund',
        {
          'payment_intent_id': paymentIntentId,
          'amount': amount,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to process refund: ${e.message}');
    }
  }
}
