import 'package:flutter/material.dart';
import '../models/model_address.dart';
import '../services/address_service.dart';
import '../services/api_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService;

  AddressProvider(ApiService apiService) : _addressService = AddressService(apiService);

  AddressModel? _address;

  AddressModel? get address => _address;

  Future<void> fetchAddress() async {
    _address = await _addressService.fetchAddress();
    notifyListeners();
  }

  Future<void> editAddress(String newAddress) async {
    final newModel = AddressModel(address: newAddress);
    final success = await _addressService.saveAddress(newModel);
    if (success) {
      _address = newModel;
      notifyListeners();
    }
  }
}
