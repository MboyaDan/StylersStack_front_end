import 'package:dio/dio.dart';
import 'package:stylerstack/services/api_service.dart';

class NotificationService{

  final ApiService _apiService;
  NotificationService(this._apiService);

  Future<void> sendTokenToBackend(String token) async {
    print("🔥 Sending token: $token");
    try {
      final response = await _apiService.patchRequest('/user/fcm-token/', {'fcm_token': token});
      print("✅ Response: ${response.statusCode} - ${response.data}");
    } on DioException catch (e) {
      print("❌ Dio error: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception('Failed to send FCM: ${e.message}');
    }
  }

}