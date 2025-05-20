import 'package:dio/dio.dart';
import 'package:stylerstack/services/api_service.dart';
import '../models/model_address.dart';

class AddressService {
  final ApiService _apiService;
  AddressService(this._apiService);


  /// Fetch the current user's address
  Future<AddressModel> fetchAddress() async {
    try {
      final Response response = await _apiService.getRequest('/address');

      return AddressModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load address: ${e.message}');
    }
  }

  /// Save a new address
  Future<bool> saveAddress(AddressModel addressModel) async {
    try {
      final Response response = await _apiService.postRequest(
        'address',
        addressModel.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception('Failed to save address: ${e.message}');
    }
  }

  /// Update an existing address
  Future<bool> updateAddress(AddressModel addressModel) async {
    try {
      final Response response = await _apiService.putRequest(
        'address', // If your backend uses `/address/:id`, change to 'address/${addressModel.id}'
        addressModel.toJson(),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to update address: ${e.message}');
    }
  }
}
