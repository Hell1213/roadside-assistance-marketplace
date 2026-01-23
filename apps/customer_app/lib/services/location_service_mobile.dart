import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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
}
