import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check and request location permissions
  static Future<void> checkPermissions() async {
    // For web, permissions are handled by browser
    // This is a no-op but kept for compatibility
  }

  // Get current location using browser's geolocation API with high accuracy
  static Future<Position?> getCurrentLocation() async {
    final completer = Completer<Position?>();
    
    try {
      // Check if geolocation is available
      if (html.window.navigator.geolocation == null) {
        print('Geolocation not supported');
        return null;
      }

      print('Requesting geolocation with high accuracy...');
      
      // Use watchPosition to get immediate location
      final watchId = html.window.navigator.geolocation.watchPosition(
        enableHighAccuracy: true,
        timeout: Duration(seconds: 15),
        maximumAge: Duration(seconds: 0),
      );
      
      // Listen to the first position
      watchId.listen(
        (html.Geoposition position) {
          if (!completer.isCompleted) {
            print('Location received: ${position.coords!.latitude}, ${position.coords!.longitude}');
            final coords = position.coords!;
            
            completer.complete(Position(
              latitude: coords.latitude!.toDouble(),
              longitude: coords.longitude!.toDouble(),
              timestamp: DateTime.now(),
              accuracy: coords.accuracy!.toDouble(),
              altitude: coords.altitude?.toDouble() ?? 0.0,
              altitudeAccuracy: coords.altitudeAccuracy?.toDouble() ?? 0.0,
              heading: coords.heading?.toDouble() ?? 0.0,
              headingAccuracy: 0.0,
              speed: coords.speed?.toDouble() ?? 0.0,
              speedAccuracy: 0.0,
            ));
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            print('Geolocation error: $error');
            completer.complete(null);
          }
        },
        cancelOnError: true,
      );
      
      // Timeout fallback
      Future.delayed(Duration(seconds: 20), () {
        if (!completer.isCompleted) {
          print('Geolocation timeout');
          completer.complete(null);
        }
      });
      
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
    
    return completer.future;
  }

  // Reverse geocode coordinates to address using Google Maps Geocoder
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final completer = Completer<String>();
    
    try {
      final geocoder = js.JsObject(js.context['google']['maps']['Geocoder']);
      final latLng = js.JsObject(
        js.context['google']['maps']['LatLng'],
        [lat, lng],
      );
      
      geocoder.callMethod('geocode', [
        js.JsObject.jsify({'location': latLng}),
        js.allowInterop((results, status) {
          if (status == 'OK' && results != null && results.length > 0) {
            completer.complete(results[0]['formatted_address']);
          } else {
            completer.complete('$lat, $lng');
          }
        })
      ]);
    } catch (e) {
      print('Geocoding error: $e');
      completer.complete('$lat, $lng');
    }
    
    return completer.future;
  }

  // Search places using Google Maps Places Autocomplete
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) return [];
    
    final completer = Completer<List<Map<String, String>>>();
    
    try {
      final service = js.JsObject(
        js.context['google']['maps']['places']['AutocompleteService'],
      );
      
      service.callMethod('getPlacePredictions', [
        js.JsObject.jsify({
          'input': query,
          'componentRestrictions': {'country': 'in'},
        }),
        js.allowInterop((predictions, status) {
          if (status == 'OK' && predictions != null) {
            final results = <Map<String, String>>[];
            for (var i = 0; i < predictions.length; i++) {
              final prediction = predictions[i];
              results.add({
                'description': prediction['description'].toString(),
                'place_id': prediction['place_id'].toString(),
              });
            }
            completer.complete(results);
          } else {
            completer.complete([]);
          }
        })
      ]);
    } catch (e) {
      print('Places search error: $e');
      completer.complete([]);
    }
    
    return completer.future;
  }

  // Get place details and coordinates from place_id
  static Future<LatLng?> getPlaceDetails(String placeId) async {
    final completer = Completer<LatLng?>();
    
    try {
      final map = js.JsObject(
        js.context['google']['maps']['Map'],
        [html.document.createElement('div')],
      );
      
      final service = js.JsObject(
        js.context['google']['maps']['places']['PlacesService'],
        [map],
      );
      
      service.callMethod('getDetails', [
        js.JsObject.jsify({'placeId': placeId}),
        js.allowInterop((place, status) {
          if (status == 'OK' && place != null) {
            final location = place['geometry']['location'];
            final lat = location.callMethod('lat').toDouble();
            final lng = location.callMethod('lng').toDouble();
            completer.complete(LatLng(lat, lng));
          } else {
            completer.complete(null);
          }
        })
      ]);
    } catch (e) {
      print('Place details error: $e');
      completer.complete(null);
    }
    
    return completer.future;
  }
}
