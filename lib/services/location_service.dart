import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  Future<LocationModel> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled");
      }

      final hasPermission = await _handlePermission();
      if (!hasPermission) {
        throw Exception("Location permission not granted");
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, // Highest possible accuracy
        ),
      );

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final place = placemarks.first;

      final address = "${place.locality ?? ''}, ${place.country ?? ''}".trim().replaceAll(RegExp(r',$'), '');

      return LocationModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: address,
      );
    } catch (e) {
      throw Exception("Failed to retrieve location: $e");
    }
  }

  Future<bool> _handlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) return false;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        return false;
      }
    }

    return true;
  }
}
