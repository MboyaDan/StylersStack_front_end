import 'package:dio/dio.dart';
import 'package:stylerstack/services/api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  Future<void> sendTokenToBackend(String token) async {
    print("🔥 Sending token: $token");

    try {
      final response = await _apiService.patchRequest(
        '/user/fcm-token',
        {'fcm_token': token},
        validateStatus: (status) => status != null && status < 500, // allow 400
      );

      if (response.statusCode == 200) {
        print("✅ Token updated successfully.");
      } else if (response.statusCode == 400 &&
          response.data['detail'] == 'FCM token is the same as the current one') {
        print("ℹ️ Token already up-to-date.");
      } else {
        print("⚠️ Unexpected response: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to send FCM token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("❌ Dio error: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception('Failed to send FCM: ${e.message}');
    }
  }
}
