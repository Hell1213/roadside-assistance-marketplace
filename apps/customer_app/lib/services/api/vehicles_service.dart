import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Vehicles service for managing customer vehicles
class VehiclesService {
  final ApiClient _apiClient = ApiClient();

  /// Add vehicle
  Future<Map<String, dynamic>> addVehicle({
    required String type, // 'CAR', 'BIKE', 'TRUCK'
    required String plateNo,
    required String make,
    required String model,
    required int year,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.vehicles,
        data: {
          'type': type,
          'plateNo': plateNo,
          'make': make,
          'model': model,
          'year': year,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all vehicles
  Future<Map<String, dynamic>> getVehicles() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.vehicles);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get default vehicle
  Future<Map<String, dynamic>> getDefaultVehicle() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.vehiclesDefault);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update vehicle
  Future<Map<String, dynamic>> updateVehicle(
    String vehicleId, {
    String? type,
    String? plateNo,
    String? make,
    String? model,
    int? year,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.vehicleById(vehicleId),
        data: {
          if (type != null) 'type': type,
          if (plateNo != null) 'plateNo': plateNo,
          if (make != null) 'make': make,
          if (model != null) 'model': model,
          if (year != null) 'year': year,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _apiClient.dio.delete(ApiConfig.vehicleById(vehicleId));
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

