import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Wallets service for driver wallet balance and transactions
class WalletsService {
  final ApiClient _apiClient = ApiClient();

  /// Get wallet balance
  Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.walletsBalance);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get transaction history
  Future<Map<String, dynamic>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.walletsTransactions,
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

