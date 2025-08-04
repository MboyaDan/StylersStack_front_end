import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService;
  OrderService(this._apiService);

  Future<void> placeOrder(OrderModel order) async {
    try {
      await _apiService.postRequest('/orders/',  order.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to place order: ${e.message}');
    }
  }
}
