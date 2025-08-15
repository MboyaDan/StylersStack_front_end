import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  late OrderService _orderService;
  bool _isPlacingOrder = false;
  String? _error;
  bool _orderSuccess = false;
  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;

  List<OrderModel> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;

  OrderProvider(ApiService? apiService) {
    if (apiService != null) {
      updateApi(apiService);
    }
  }

  void updateApi(ApiService apiService) {
    _orderService = OrderService(apiService);
  }

  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;
  bool get orderSuccess => _orderSuccess;

  /// Call this to create an order
  Future<void> createOrder(OrderModel order) async {
    _isPlacingOrder = true;
    _orderSuccess = false;
    _error = null;
    notifyListeners();

    try {
      await _orderService.placeOrder(order);
      _orderSuccess = true;
    } catch (e) {
      _error = e.toString();
      _orderSuccess = false;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  /// Optionally reset order state
  void resetOrderStatus() {
    _orderSuccess = false;
    _error = null;
    notifyListeners();
  }



  Future<void> fetchOrders() async {
    _isLoadingOrders = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrders();
    } catch (e) {
      _error = e.toString();
      _orders = [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> fetchOrderById(String orderId) async {
    _isLoadingOrders = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.fetchOrderById(orderId);
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  }


