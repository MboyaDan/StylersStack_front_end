import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stylerstack/providers/auth_provider.dart';
//== API SERVICE ==//
class ApiService {

  /// Base URL for your API
  static const String baseUrl = 'http://10.0.2.2:8000';
  final Dio _dio;
  final GoRouter _router;
  final AuthProvider _authProvider;

  //======= API SERVICE CONSTRUCTOR =========//
  ApiService(this._authProvider, this._router)
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Content-Type': 'application/json'},
  )) {
    _dio.interceptors.addAll([
      _authInterceptor(),
      _retryInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  /// ========== INTERCEPTORS ========== //
  /// Retry on network-related errors or server crashes
  RetryInterceptor _retryInterceptor() {
    return RetryInterceptor(
      dio: _dio,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ],
      retryEvaluator: (error, attempt) =>
      error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown ||
          error.response?.statusCode == 500 ||
          error.response?.statusCode == 503,
    );
  }

  /// Interceptor to attach Authorization headers & refresh tokens if needed
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          String? token = await _authProvider.getValidToken();

          if (token != null && !JwtDecoder.isExpired(token)) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('Token is null or expired before sending request.');
            await _handleLogout();
            return;
          }

          handler.next(options);
        } catch (e, stack) {
          print('Auth Interceptor Error: $e');
          print(stack);
          await _handleLogout();
        }
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          print('Received 401. Trying to refresh token...');
          final newToken = await _authProvider.refreshToken();
          if (newToken != null) {
            final options = e.requestOptions;
            // Save token
            options.headers['Authorization'] = 'Bearer $newToken';
            // Retry original request
            final cloneReq = await _dio.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          } else {
            print('Token refresh failed. Forcing logout.');
            await _handleLogout();
          }
        }

        handler.next(e);
      },
    );
  }

  /// Log out user, clear token, redirect to login
  Future<void> _handleLogout() async {
    await _authProvider.signOut();
    _router.go('/login');
  }

  // ========== API METHODS ========== //

  Future<Response> getRequest(String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  Future<Response> postRequest(String endpoint,
      Map<String, dynamic> data,) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> putRequest(String endpoint,
      Map<String, dynamic> data,) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> deleteRequest(String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    return await _dio.delete(endpoint, data: data);
  }

  Future<Response> patchRequest(String endpoint,
      Map<String, dynamic> data,) async {
    return await _dio.patch(endpoint, data: data);
  }
}
////personal notes retrieving the JWT token, refreshing it if expired,
// intercepting and retrying failed requests (e.g., 401),
///securely storing the token (via flutter_secure_storage)