import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Payouts service for driver earnings withdrawal
class PayoutsService {
  final ApiClient _apiClient = ApiClient();

  /// Initiate payout
  Future<Map<String, dynamic>> createPayout({
    required double amount,
    required String accountNumber,
    required String ifsc,
    required String name,
    String? contact,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.payouts,
        data: {
          'amount': amount,
          'accountNumber': accountNumber,
          'ifsc': ifsc,
          'name': name,
          if (contact != null) 'contact': contact,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payout by ID
  Future<Map<String, dynamic>> getPayoutById(String payoutId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.payoutById(payoutId));
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payout history
  Future<Map<String, dynamic>> getPayouts({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.payouts,
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

