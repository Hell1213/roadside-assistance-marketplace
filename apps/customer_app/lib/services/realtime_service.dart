import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'api/api_client.dart';

/// Real-time WebSocket service for job tracking and updates
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  IO.Socket? _socket;
  final ApiClient _apiClient = ApiClient();
  bool _isConnected = false;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected && _socket?.connected == true) {
      return;
    }

    try {
      final token = await _apiClient.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      _socket = IO.io(
        ApiConfig.wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        print('WebSocket connected');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('WebSocket disconnected');
      });

      _socket!.onError((error) {
        print('WebSocket error: $error');
      });

      _socket!.connect();
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      rethrow;
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Subscribe to job updates
  void subscribeToJob(String jobId) {
    if (_socket?.connected == true) {
      _socket!.emit('subscribe:job', {'jobId': jobId});
    }
  }

  /// Unsubscribe from job updates
  void unsubscribeFromJob(String jobId) {
    if (_socket?.connected == true) {
      _socket!.emit('unsubscribe:job', {'jobId': jobId});
    }
  }

  /// Listen to job state changes
  void onJobStateChange(Function(Map<String, dynamic>) callback) {
    _socket?.on('job:state_change', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  /// Listen to driver location updates
  void onDriverLocation(Function(Map<String, dynamic>) callback) {
    _socket?.on('job:driver_location', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  /// Listen to job updates (general)
  void onJobUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('job:update', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  /// Check if connected
  bool get isConnected => _isConnected && (_socket?.connected ?? false);
}

