import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

/// Production-grade API client with token management, interceptors, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Initialize API client
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(_ErrorInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Set access token
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Set refresh token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

/// Auth interceptor - adds token to requests and handles refresh
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final response = await _dio.post(
            ApiConfig.authRefresh,
            data: {'refresh_token': refreshToken},
          );
          
          if (response.statusCode == 200) {
            final data = response.data;
            await _storage.write(key: 'access_token', value: data['access_token']);
            await _storage.write(key: 'refresh_token', value: data['refresh_token']);
            
            // Retry original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${data['access_token']}';
            final retryResponse = await _dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            _isRefreshing = false;
            handler.resolve(retryResponse);
            return;
          }
        }
      } catch (e) {
        // Refresh failed, clear tokens
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
      _isRefreshing = false;
    }
    handler.next(err);
  }
}

/// Error interceptor - formats errors consistently
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Format error response
    final errorMessage = _getErrorMessage(err);
    final formattedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response != null
          ? Response(
              requestOptions: err.requestOptions,
              statusCode: err.response?.statusCode,
              statusMessage: errorMessage,
              data: err.response?.data,
            )
          : null,
      type: err.type,
      error: errorMessage,
    );
    handler.next(formattedError);
  }

  String _getErrorMessage(DioException err) {
    if (err.response != null) {
      final data = err.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

