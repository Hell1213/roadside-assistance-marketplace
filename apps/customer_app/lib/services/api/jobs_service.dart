import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Jobs service for managing service requests
class JobsService {
  final ApiClient _apiClient = ApiClient();

  /// Create job from quote
  Future<Map<String, dynamic>> createJob({required String quoteId}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.jobs,
        data: {'quoteId': quoteId},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.jobById(jobId));
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get customer job history
  Future<Map<String, dynamic>> getJobs({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.jobs,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update job status (for customer - cancel)
  Future<Map<String, dynamic>> updateJobStatus(
    String jobId, {
    required String state,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.jobStatus(jobId),
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

