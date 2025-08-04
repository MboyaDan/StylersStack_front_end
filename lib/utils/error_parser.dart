import 'package:dio/dio.dart';

class ErrorUtils {
  static String parseDioError(dynamic error) {
    if (error is DioException && error.response?.data != null) {
      final data = error.response!.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        // Handle additional fields if needed
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      } else if (data is String) {
        return data;
      }
    }

    return error.toString();
  }
}

