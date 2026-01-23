import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service_platform.dart'
    if (dart.library.html) 'location_service_web.dart'
    if (dart.library.io) 'location_service_mobile.dart';

class LocationService {
  // Check and request location permissions
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      print('Requesting current location...');
      
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        print('Location permission not granted');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      print('Location received: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Reverse geocode coordinates to address - delegates to platform-specific implementation
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    return LocationServicePlatform.getAddressFromCoordinates(lat, lng);
  }

  // Search places - delegates to platform-specific implementation
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    return LocationServicePlatform.searchPlaces(query);
  }

  // Get place details - delegates to platform-specific implementation
  static Future<LatLng?> getPlaceDetails(String placeId) async {
    return LocationServicePlatform.getPlaceDetails(placeId);
  }
}
