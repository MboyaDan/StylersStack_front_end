import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  LocationModel? _location;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel? get location => _location;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      //  Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      //  Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied. Please enable it from settings.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      //  Ensure permission level is sufficient
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _errorMessage = 'Insufficient location permission.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      //  Fetch the location using service
      _location = await LocationService().getCurrentLocation();
      if (_location == null) {
        _errorMessage = 'Failed to get location.';
      }

      // Optional: log location and permission status
      debugPrint("Permission status: $permission");
      debugPrint("Location: $_location");
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      debugPrint("Location error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
