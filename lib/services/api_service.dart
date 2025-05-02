import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  ///consuming our entrypoint
  final String baseUrl = 'our api';

  ///securely storing the token with flutter_secure_storage for security and persistence
  final _storage = const FlutterSecureStorage();

  //get token from secure storage or firebase
  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'id_token');

    ///if no token found,fetch from Firebase and store it
    if(token == null){
      final user = FirebaseAuth.instance.currentUser;
      token = await user?.getIdToken();
      if (token != null){
        await _storage.write(key: 'id_token', value: token);
      }
    }
   return token;
  }

  ///get requests

  Future<http.Response> getRequest(String endpoint) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    ///attaching the header with token to authenticate users on the backend and create their gatepass
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

Future<http.Response> deleteRequest(String endpoint, Map<String,dynamic> data)async{
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    return http.delete(uri,
    body: jsonEncode(data),
      headers: {
      'Authorization':'Bearer $token',
        'Content-Type': 'application/json',
      });
}
///update request
Future<http.Response> putRequest(String endpoint, Map<String, dynamic> data)async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    return http.put(uri,
      body: jsonEncode(data),
      headers: {
      'Authorization':'Bearer $token',
        'Content-Type': 'application/json',

      });
}
  //force refresh token if needed
Future<void> refreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final newToken = await user?.getIdToken(true);//force refresh
  if(newToken!= null){
    await _storage.write(key: 'id_token', value: newToken);
  }
}
}
