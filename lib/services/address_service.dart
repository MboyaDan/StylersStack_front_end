import 'package:dio/dio.dart';
import 'package:stylerstack/services/api_service.dart';
import '../models/model_address.dart';

class AddressService {
  final ApiService _apiService;

  AddressService(this._apiService);

  /// Fetch the current user's address
  Future<AddressModel> fetchAddress() async {
    try {
      final Response response = await _apiService.getRequest('/address/');
      return AddressModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load address: ${e.message}');
    }
  }

  /// Save or update address (Upsert)
  Future<bool> upsertAddress(AddressModel addressModel) async {
    try {
      final Response response = await _apiService.postRequest(
        '/address/',
        addressModel.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception('Failed to save/update address: ${e.message}');
    }
  }
}
