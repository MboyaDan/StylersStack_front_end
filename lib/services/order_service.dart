import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService;
  OrderService(this._apiService);

  /// Place a new order
  Future<void> placeOrder(OrderModel order) async {
    try {
      final response = await _apiService.postRequest('/orders/', order.toJson());

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to place order: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to place order: ${e.message}');
    }
  }

  /// Fetch orders for the logged-in user
  Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await _apiService.getRequest('/orders/');

      if (response.statusCode == 200) {
        if (response.data is! List) {
          throw Exception("Unexpected response format for orders: ${response.data.runtimeType}");
        }

        final List rawList = response.data;
        return rawList
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch orders: ${e.message}');
    }
  }
  /// Fetch a single order by ID
  Future<OrderModel> fetchOrderById(String orderId) async {
    try {
      final response = await _apiService.getRequest('/orders/$orderId');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw Exception("Unexpected response format for order: ${response.data.runtimeType}");
        }
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch order: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch order: ${e.message}');
    }
  }

}
