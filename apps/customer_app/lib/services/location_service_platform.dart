import 'package:google_maps_flutter/google_maps_flutter.dart';

// Default stub implementation
class LocationServicePlatform {
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    throw UnimplementedError('Platform-specific implementation required');
  }

  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    throw UnimplementedError('Platform-specific implementation required');
  }

  static Future<LatLng?> getPlaceDetails(String placeId) async {
    throw UnimplementedError('Platform-specific implementation required');
  }
}
