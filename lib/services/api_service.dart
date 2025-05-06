import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {

  final String baseUrl = 'your_api_base_url';
  final _storage = const FlutterSecureStorage();
  // we will assign it later but won't change upon runtime
  late final Dio _dio;

  ApiService() {
    //Api service  wraps Dio + secure storage.
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
// An interceptor injects the JWT token for write requests only.
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Interceptor auto-attaches token
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'id_token');

          // If token doesn't exist, fetch from Firebase
          if (token == null) {
            final user = FirebaseAuth.instance.currentUser;
            token = await user?.getIdToken();
            if (token != null) {
              await _storage.write(key: 'id_token', value: token);
            }
          }

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('Dio Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// GET request
  Future<Response> getRequest(String endpoint, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  /// POST request
  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }

  /// PUT request
  Future<Response> putRequest(String endpoint, Map<String, dynamic> data) async {
    return await _dio.put(endpoint, data: data);
  }

  /// DELETE request
  Future<Response> deleteRequest(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.delete(endpoint, data: data);
  }

  /// Force refresh token manually if needed
  Future<void> refreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final newToken = await user?.getIdToken(true); // force refresh
    if (newToken != null) {
      await _storage.write(key: 'id_token', value: newToken);
    }
  }
}
