import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// KYC service for document upload and verification
class KycService {
  final ApiClient _apiClient = ApiClient();

  /// Upload KYC document
  Future<Map<String, dynamic>> uploadDocument({
    required String documentType, // 'DRIVER_LICENSE', 'VEHICLE_REGISTRATION', 'INSURANCE', 'AADHAAR', 'PAN'
    required String documentUrl, // S3 URL after upload
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.kycDocuments,
        data: {
          'documentType': documentType,
          'documentUrl': documentUrl,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get KYC status
  Future<Map<String, dynamic>> getKycStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.kycStatus);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all documents
  Future<Map<String, dynamic>> getDocuments() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.kycDocuments);
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

