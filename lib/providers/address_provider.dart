import 'package:flutter/material.dart';
import '../models/model_address.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier{

  final addressService = AddressService();
  AddressModel? _address;

  AddressModel?get address => _address;

  Future<void> fetchAddress()async {
    _address = await addressService.fetchAddress();
    notifyListeners();
  }
  Future<void> editAddress(String newAddress)async {
    final newModel = AddressModel(address: newAddress);
    final success = await addressService.saveAddress(newModel);
    if (success){
      _address = newModel;
      notifyListeners();
    }

  }
}
