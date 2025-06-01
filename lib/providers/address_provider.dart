import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylerstack/models/model_address.dart';
import 'package:stylerstack/services/address_service.dart';
import 'package:stylerstack/services/api_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService;

  AddressProvider(ApiService apiService) : _addressService = AddressService(apiService);

  AddressModel? _address;

  AddressModel? get address => _address;

  String get displayAddress => _address?.address ?? 'Not provided';

  static const _addressKey = 'user_shipping_address';
  static const _uidKey = 'cached_user_uid';

  /// Fetch address, check if local data belongs to current user
  Future<void> fetchAddress(String uid) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedUid = prefs.getString(_uidKey);
    final cachedAddress = prefs.getString(_addressKey);

    if (cachedUid == uid && cachedAddress != null) {
      _address = AddressModel(address: cachedAddress);
      notifyListeners();
    }

    try {
      final remoteAddress = await _addressService.fetchAddress();

      _address = remoteAddress;

      // Update local storage for current user
      await prefs.setString(_addressKey, remoteAddress.address);
      await prefs.setString(_uidKey, uid);

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching address from server: $e');
    }
  }

  /// Save or update the address
  Future<void> editAddress(String newAddress, String uid) async {
    final newModel = AddressModel(address: newAddress);
    final success = await _addressService.upsertAddress(newModel);

    if (success) {
      _address = newModel;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_addressKey, newAddress);
      await prefs.setString(_uidKey, uid);

      notifyListeners();
    } else {
      debugPrint('Failed to update address.');
    }
  }

  /// Clear address from memory and local storage
  Future<void> clearAddress() async {
    _address = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressKey);
    await prefs.remove(_uidKey);

    notifyListeners();
  }
}
