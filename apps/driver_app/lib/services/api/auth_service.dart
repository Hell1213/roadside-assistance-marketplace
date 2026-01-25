import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Authentication service for driver OTP-based login
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authRequestOtp,
        data: {'phone': phone, 'role': 'driver'},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authVerifyOtp,
        data: {
          'phone': phone,
          'role': 'driver',
          'otp': otp,
          if (deviceId != null) 'device_id': deviceId,
        },
      );
      
      final data = response.data;
      if (data['access_token'] != null) {
        await _apiClient.setAccessToken(data['access_token']);
      }
      if (data['refresh_token'] != null) {
        await _apiClient.setRefreshToken(data['refresh_token']);
      }
      
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiConfig.authLogout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    return e.message ?? 'Authentication failed';
  }
}

