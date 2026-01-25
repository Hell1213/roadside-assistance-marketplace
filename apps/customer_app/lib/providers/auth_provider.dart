import 'package:flutter/material.dart';
import '../services/api/auth_service.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userRole; // 'CUSTOMER', 'DRIVER', 'ADMIN'
  String? _userId;
  String? _phoneNumber;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        // Try to get user info from token
        // For now, we'll just set authenticated
        _isAuthenticated = true;
        // TODO: Decode JWT to get user role and ID
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request OTP
  Future<void> requestOtp({
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.requestOtp(phone: phone, role: role);
      _phoneNumber = phone;
      _userRole = role;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify OTP and login
  Future<void> verifyOtp({
    required String phone,
    required String otp,
    String? role,
    String? deviceId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use stored role if not provided, default to 'CUSTOMER'
      final roleToUse = role ?? _userRole ?? 'CUSTOMER';
      
      final response = await _authService.verifyOtp(
        phone: phone,
        otp: otp,
        role: roleToUse,
        deviceId: deviceId,
      );

      // Extract user info from response
      if (response['user'] != null) {
        final user = response['user'];
        _userId = user['id']?.toString();
        _userRole = user['role']?.toString();
        _phoneNumber = phone;
      }

      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API fails
    } finally {
      _isAuthenticated = false;
      _userRole = null;
      _userId = null;
      _phoneNumber = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh auth status
  Future<void> refreshAuthStatus() async {
    await _checkAuthStatus();
  }
}

