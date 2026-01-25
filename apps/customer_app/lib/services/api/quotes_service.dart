import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Quotes service for fare estimation
class QuotesService {
  final ApiClient _apiClient = ApiClient();

  /// Create quote (get fare estimate)
  Future<Map<String, dynamic>> createQuote({
    required String city,
    required String serviceCode, // 'TOW', 'JUMP_START', 'FUEL_DELIVERY', 'FLAT_TYRE'
    required String vehicleClass, // 'CAR', 'BIKE', 'TRUCK'
    required double originLat,
    required double originLng,
    double? destLat,
    double? destLng,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.quotes,
        data: {
          'city': city,
          'service_code': serviceCode,
          'vehicle_class': vehicleClass,
          'origin_lat': originLat,
          'origin_lng': originLng,
          if (destLat != null) 'dest_lat': destLat,
          if (destLng != null) 'dest_lng': destLng,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'] as String;
        }
      }
    }
    return e.toString();
  }
}

