import 'dart:js' as js;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

// Web-specific implementation using JavaScript interop
class LocationServicePlatform {
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) return [];
    
    try {
      final completer = Completer<List<Map<String, String>>>();
      
      // Call JavaScript function to get autocomplete predictions
      js.context.callMethod('getAutocompletePredictions', [
        query,
        (results) {
          if (results != null) {
            final List<Map<String, String>> places = [];
            for (var i = 0; i < results.length; i++) {
              final prediction = results[i];
              places.add({
                'description': prediction['description'].toString(),
                'place_id': prediction['place_id'].toString(),
              });
            }
            completer.complete(places);
          } else {
            completer.complete([]);
          }
        },
      ]);
      
      return completer.future.timeout(
        Duration(seconds: 5),
        onTimeout: () => [],
      );
    } catch (e) {
      print('Places search error: $e');
      return [];
    }
  }

  static Future<LatLng?> getPlaceDetails(String placeId) async {
    try {
      final completer = Completer<LatLng?>();
      
      // Call JavaScript function to get place details
      js.context.callMethod('getPlaceDetails', [
        placeId,
        (result) {
          if (result != null && result['lat'] != null && result['lng'] != null) {
            completer.complete(LatLng(
              result['lat'].toDouble(),
              result['lng'].toDouble(),
            ));
          } else {
            completer.complete(null);
          }
        },
      ]);
      
      return completer.future.timeout(
        Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      print('Place details error: $e');
      return null;
    }
  }
}
