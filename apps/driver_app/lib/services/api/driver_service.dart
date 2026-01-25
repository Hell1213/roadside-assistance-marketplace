import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Driver service for profile and job management
class DriverService {
  final ApiClient _apiClient = ApiClient();

  /// Get driver profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.driverProfile);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update driver profile (status, capabilities)
  Future<Map<String, dynamic>> updateProfile({
    String? status, // 'ONLINE', 'OFFLINE', 'BUSY', 'SUSPENDED'
    List<String>? capabilities, // ['TOW', 'JUMP_START', 'FUEL_DELIVERY', 'FLAT_TYRE']
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.driverProfile,
        data: {
          if (status != null) 'status': status,
          if (capabilities != null) 'capabilities': capabilities,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update vehicle details
  Future<Map<String, dynamic>> updateVehicle({
    String? type, // 'TOW_TRUCK', 'PICKUP', 'MOTORCYCLE'
    String? plateNo,
    String? make,
    String? model,
    int? year,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.driverVehicle,
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

  /// Get pending job offers
  Future<Map<String, dynamic>> getJobOffers() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.driverJobs);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Accept job offer
  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.driverJobAccept(jobId),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update job status
  Future<Map<String, dynamic>> updateJobStatus(
    String jobId, {
    required String state, // 'ARRIVING', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED'
    Map<String, dynamic>? meta,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.driverJobStatus(jobId),
        data: {
          'state': state,
          if (meta != null) 'meta': meta,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update driver location (for tracking)
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.driverLocation,
        data: {
          'lat': lat,
          'lng': lng,
          if (heading != null) 'heading': heading,
          if (speed != null) 'speed': speed,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get job details
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.jobById(jobId));
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

