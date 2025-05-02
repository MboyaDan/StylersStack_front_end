import 'dart:convert';
import 'package:stylerstack/services/api_service.dart';
import '../models/model_address.dart';

class AddressService {
  final ApiService _apiService = ApiService();

  Future <AddressModel> fetchAddress() async {
    final response = await _apiService.getRequest('address');

    if (response.statusCode == 200) {
      return AddressModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future <bool> saveAddress(AddressModel addressModel)async {
    final response = await _apiService.postRequest('address',
    addressModel.toJson(),
    );//sending data
    return response.statusCode==200|| response.statusCode == 201;
  }
  Future<bool> updateAddress(AddressModel addressModel)async{
    final response = await _apiService.putRequest(
      'address',//to be considered if backend uses '/address/:id' ,pass ID '
      // 'address/${addressModel.id}'
      addressModel.toJson(),
    );
    return response.statusCode==200;
  }
}