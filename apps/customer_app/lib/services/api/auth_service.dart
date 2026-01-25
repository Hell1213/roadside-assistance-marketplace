import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Authentication service for OTP-based login
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phone,
    required String role, // 'CUSTOMER', 'DRIVER', or 'ADMIN' (will be converted to lowercase)
  }) async {
    try {
      // Backend expects lowercase: 'customer', 'driver', 'admin'
      final roleLower = role.toLowerCase();
      
      final response = await _apiClient.dio.post(
        ApiConfig.authRequestOtp,
        data: {
          'phone': phone,
          'role': roleLower,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify OTP and get tokens
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role, // 'customer', 'driver', or 'admin'
    String? deviceId,
  }) async {
    try {
      // Backend expects lowercase: 'customer', 'driver', 'admin'
      final roleLower = role.toLowerCase();
      
      final response = await _apiClient.dio.post(
        ApiConfig.authVerifyOtp,
        data: {
          'phone': phone,
          'role': roleLower,
          'otp': otp,
          if (deviceId != null) 'device_id': deviceId,
        },
      );
      
      final data = response.data;
      
      // Store tokens
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

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }
      
      final response = await _apiClient.dio.post(
        ApiConfig.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      
      final data = response.data;
      
      // Update tokens
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

  /// Logout
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

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        // Handle validation errors (array of messages)
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message is List) {
            return message.join(', ');
          }
          return message.toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
      }
    }
    return e.message ?? 'Authentication failed';
  }
}

