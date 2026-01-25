import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import '../config/app_config.dart';

// Mobile-specific implementation using HTTP API calls
class LocationServicePlatform {
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) return [];
    
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:in'
        '&key=$apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) => {
            'description': prediction['description'].toString(),
            'place_id': prediction['place_id'].toString(),
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Places search error: $e');
      return [];
    }
  }

  static Future<LatLng?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return LatLng(
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Place details error: $e');
      return null;
    }
  }

  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Use geocoding package for mobile
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
      return 'Address not found';
    } catch (e) {
      print('Reverse geocode error: $e');
      return 'Address not available';
    }
  }
}
