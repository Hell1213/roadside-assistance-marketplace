import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// User service for profile management
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.me);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConfig.me,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
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

