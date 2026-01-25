import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Support service for creating and managing support tickets
class SupportService {
  final ApiClient _apiClient = ApiClient();

  /// Create support ticket
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String description,
    String? jobId,
    String? priority, // 'LOW', 'MEDIUM', 'HIGH', 'URGENT'
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.supportTickets,
        data: {
          'subject': subject,
          'description': description,
          if (jobId != null) 'jobId': jobId,
          if (priority != null) 'priority': priority,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get support tickets
  Future<Map<String, dynamic>> getTickets({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.supportTickets,
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

  /// Get ticket by ID
  Future<Map<String, dynamic>> getTicketById(String ticketId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.supportTicketById(ticketId),
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

