import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001';
  static String get wsUrl => dotenv.env['WS_BASE_URL'] ?? 'http://localhost:3001';
  
  // Auth Endpoints
  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  
  // Driver Endpoints
  static const String driverProfile = '/driver/profile';
  static const String driverVehicle = '/driver/vehicle';
  static const String driverJobs = '/driver/jobs';
  static String driverJobAccept(String id) => '/driver/jobs/$id/accept';
  static String driverJobStatus(String id) => '/driver/jobs/$id/status';
  static const String driverLocation = '/driver/location';
  
  // KYC Endpoints
  static const String kycDocuments = '/kyc/documents';
  static const String kycStatus = '/kyc/status';
  static String kycDocumentVerify(String id) => '/kyc/documents/$id/verify';
  
  // Payouts
  static const String payouts = '/payouts';
  static String payoutById(String id) => '/payouts/$id';
  
  // Wallets
  static const String walletsBalance = '/wallets/balance';
  static const String walletsTransactions = '/wallets/transactions';
  
  // Jobs
  static String jobById(String id) => '/jobs/$id';
  
  // Notifications
  static const String notificationsDevices = '/notifications/devices';
  static const String notifications = '/notifications';
}

