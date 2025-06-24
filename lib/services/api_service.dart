import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stylerstack/providers/auth_provider.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  final Dio _dio;
  final GoRouter _router;
  final AuthProvider _authProvider;

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

  /// ───────────────────────────────────────────────
  /// Retry failed network/server requests
  /// ───────────────────────────────────────────────
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

  /// ───────────────────────────────────────────────
  /// Auth Interceptor for attaching tokens & refreshing
  /// ───────────────────────────────────────────────
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _authProvider.getValidToken();

          if (token != null && !JwtDecoder.isExpired(token)) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('⚠️ Token missing or expired. Continuing without auth header.');
          }

          handler.next(options);
        } catch (e, stackTrace) {
          print('⚠️ Auth Interceptor Error: $e');
          print(stackTrace);
          // Don't block request; continue without auth
          handler.next(options);
        }
      },

      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          print('🔁 401 Received. Attempting to refresh token...');

          try {
            final newToken = await _authProvider.refreshToken();

            if (newToken != null && !JwtDecoder.isExpired(newToken)) {
              final options = e.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';

              final clonedResponse = await _dio.fetch(options);
              return handler.resolve(clonedResponse);
            } else {
              print('❌ Token refresh failed or returned null. Aborting retry.');
              return handler.next(e); // Don't log out immediately
            }
          } catch (err) {
            print('❌ Error while refreshing token: $err');
            return handler.next(e);
          }
        }

        handler.next(e); // For all other errors
      },
    );
  }

  /// ───────────────────────────────────────────────
  /// Safe Logout + Navigation (optional, no longer used in interceptor)
  /// ───────────────────────────────────────────────
  Future<void> _handleLogout() async {
    await _authProvider.signOut();
    _router.go('/login');
  }

  /// ───────────────────────────────────────────────
  /// API Methods
  /// ───────────────────────────────────────────────
  Future<Response> getRequest(
      String endpoint, {
        Map<String, dynamic>? queryParams,
      }) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  Future<Response> postRequest(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> putRequest(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> deleteRequest(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    return await _dio.delete(endpoint, data: data);
  }

  Future<Response> patchRequest(
      String endpoint,
      Map<String, dynamic> data, {
        bool Function(int?)? validateStatus,
      }) async {
    return await _dio.patch(
      endpoint,
      data: data,
      options: Options(
        validateStatus: validateStatus ?? (status) => status != null && status < 500,
      ),
    );
  }
}
