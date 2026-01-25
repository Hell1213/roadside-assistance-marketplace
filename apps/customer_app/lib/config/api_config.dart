import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001';
  static String get wsUrl => dotenv.env['WS_BASE_URL'] ?? 'http://localhost:3001';
  
  // API Endpoints
  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  
  static const String me = '/me';
  
  static const String quotes = '/quotes';
  static const String jobs = '/jobs';
  static String jobById(String id) => '/jobs/$id';
  static String jobStatus(String id) => '/jobs/$id/status';
  
  static const String paymentsOrders = '/payments/orders';
  static const String paymentsVerify = '/payments/verify';
  static String paymentById(String id) => '/payments/$id';
  
  static const String walletsBalance = '/wallets/balance';
  static const String walletsTransactions = '/wallets/transactions';
  
  static String ratingsByJob(String jobId) => '/ratings/jobs/$jobId';
  static String ratingsByDriver(String driverId) => '/ratings/drivers/$driverId';
  
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';
  static const String vehiclesDefault = '/vehicles/default';
  
  static const String notificationsDevices = '/notifications/devices';
  static const String notifications = '/notifications';
  
  static const String supportTickets = '/support/tickets';
  static String supportTicketById(String id) => '/support/tickets/$id';
}

