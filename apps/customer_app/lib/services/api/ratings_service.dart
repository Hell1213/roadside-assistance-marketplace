import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Ratings service for submitting and retrieving ratings
class RatingsService {
  final ApiClient _apiClient = ApiClient();

  /// Submit rating for a completed job
  Future<Map<String, dynamic>> submitRating({
    required String jobId,
    required String rating, // 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE'
    String? comment,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.ratingsByJob(jobId),
        data: {
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get rating for a job
  Future<Map<String, dynamic>> getJobRating(String jobId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.ratingsByJob(jobId));
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get driver ratings
  Future<Map<String, dynamic>> getDriverRatings(String driverId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.ratingsByDriver(driverId));
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

