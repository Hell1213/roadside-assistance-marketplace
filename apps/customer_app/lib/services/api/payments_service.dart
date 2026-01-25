import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../config/api_config.dart';

/// Payments service for Razorpay integration
class PaymentsService {
  final ApiClient _apiClient = ApiClient();

  /// Create payment order
  Future<Map<String, dynamic>> createPaymentOrder({
    required String jobId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.paymentsOrders,
        data: {'jobId': jobId},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify payment after Razorpay success
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.paymentsVerify,
        data: {
          'paymentId': paymentId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payment details
  Future<Map<String, dynamic>> getPaymentById(String paymentId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.paymentById(paymentId));
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

