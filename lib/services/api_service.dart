import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  ///consuming our entrypoint
  final String baseUrl = 'our api';

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  ///get requests

  Future<http.Response> getRequest(String endpoint) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    return http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  ///our end points to fetch,post and update the right data

  ///post requests
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    return http.post(uri,
        body: jsonEncode(data),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
  }
///delete request
// Add PUT, DELETE similarly as needed

Future<http.Response> deleteRequest(String endpoint, Map<String,dynamic> data)async{
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    return http.post(uri,
    body: jsonEncode(data),
      headers: {
      'Authorization':'Bearer $token',
        'Content-Type': 'application/json',
      });
}
}
