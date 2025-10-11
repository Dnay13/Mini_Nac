import '../models/network_stats_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class NetworkService {
  final ApiService _apiService = ApiService();

  // Obtener estadísticas de red
  Future<NetworkStatsResponse> getNetworkStats() async {
    try {
      // MODO DEMO: Simular estadísticas de red
      await Future.delayed(const Duration(milliseconds: 600));
      
      final mockStats = NetworkStatsModel(
        status: 'stable',
        downloadSpeed: 85.5,
        uploadSpeed: 42.3,
        latency: 12.0,
        totalUsers: 8,
        activeUsers: 3,
        totalDataUsageMB: 1250,
        bandwidthUtilization: 0.65,
        lastUpdated: DateTime.now(),
        speedHistory: [],
        metadata: {
          'isp': 'ISP Demo',
          'publicIP': '192.168.1.1',
          'dnsServers': ['8.8.8.8', '8.8.4.4'],
          'wifiChannels': [1, 6, 11],
          'currentChannel': 6,
          'bandwidth': '20MHz',
          'securityProtocol': 'WPA2',
          'maxConnections': 50,
          'currentConnections': 8,
          'guestNetworkEnabled': true,
          'parentalControlsEnabled': false,
          'qosEnabled': true,
          'firmwareVersion': '1.2.3',
          'lastUpdate': DateTime.now().subtract(const Duration(days: 7)),
          'temperature': 45.0,
          'cpuUsage': 25.0,
          'memoryUsage': 60.0,
          'diskUsage': 30.0,
        },
      );
      
      return NetworkStatsResponse.success(stats: mockStats);
    } catch (e) {
      return NetworkStatsResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener historial de velocidad
  Future<NetworkHistoryResponse> getSpeedHistory({
    int hours = 24,
    int intervalMinutes = 5,
  }) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.networkEndpoint}/speed-history',
        queryParameters: {
          'hours': hours,
          'interval_minutes': intervalMinutes,
        },
      );

      if (response.isSuccess) {
        final data = response.data as List<dynamic>;
        final history = data
            .map((item) => NetworkDataPoint.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return NetworkHistoryResponse.success(history: history);
      } else {
        return NetworkHistoryResponse.error(
          message: response.message ?? 'Error al obtener historial de velocidad',
        );
      }
    } on ApiException catch (e) {
      return NetworkHistoryResponse.error(message: e.message);
    } catch (e) {
      return NetworkHistoryResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener estado de la red
  Future<NetworkStatusResponse> getNetworkStatus() async {
    try {
      final response = await _apiService.get('${AppConstants.networkEndpoint}/status');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        
        return NetworkStatusResponse.success(
          status: data['status'] as String,
          isOnline: data['is_online'] as bool,
          lastCheck: DateTime.parse(data['last_check'] as String),
          uptime: Duration(seconds: data['uptime_seconds'] as int),
        );
      } else {
        return NetworkStatusResponse.error(
          message: response.message ?? 'Error al obtener estado de red',
        );
      }
    } on ApiException catch (e) {
      return NetworkStatusResponse.error(message: e.message);
    } catch (e) {
      return NetworkStatusResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Realizar test de velocidad
  Future<SpeedTestResponse> performSpeedTest() async {
    try {
      final response = await _apiService.post('${AppConstants.networkEndpoint}/speed-test');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        
        return SpeedTestResponse.success(
          downloadSpeed: (data['download_speed'] as num).toDouble(),
          uploadSpeed: (data['upload_speed'] as num).toDouble(),
          latency: (data['latency'] as num).toDouble(),
          server: data['server'] as String?,
          timestamp: DateTime.parse(data['timestamp'] as String),
        );
      } else {
        return SpeedTestResponse.error(
          message: response.message ?? 'Error al realizar test de velocidad',
        );
      }
    } on ApiException catch (e) {
      return SpeedTestResponse.error(message: e.message);
    } catch (e) {
      return SpeedTestResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener configuración de red
  Future<NetworkConfigResponse> getNetworkConfig() async {
    try {
      final response = await _apiService.get('${AppConstants.networkEndpoint}/config');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        
        return NetworkConfigResponse.success(
          config: NetworkConfig.fromJson(data),
        );
      } else {
        return NetworkConfigResponse.error(
          message: response.message ?? 'Error al obtener configuración de red',
        );
      }
    } on ApiException catch (e) {
      return NetworkConfigResponse.error(message: e.message);
    } catch (e) {
      return NetworkConfigResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Actualizar configuración de red
  Future<NetworkConfigResponse> updateNetworkConfig({
    required NetworkConfig config,
  }) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.networkEndpoint}/config',
        data: config.toJson(),
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final updatedConfig = NetworkConfig.fromJson(data);
        
        return NetworkConfigResponse.success(
          config: updatedConfig,
          message: 'Configuración actualizada exitosamente',
        );
      } else {
        return NetworkConfigResponse.error(
          message: response.message ?? 'Error al actualizar configuración',
        );
      }
    } on ApiException catch (e) {
      return NetworkConfigResponse.error(message: e.message);
    } catch (e) {
      return NetworkConfigResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Reiniciar router/modem
  Future<NetworkActionResponse> restartRouter() async {
    try {
      final response = await _apiService.post('${AppConstants.networkEndpoint}/restart');

      if (response.isSuccess) {
        return NetworkActionResponse.success(
          message: 'Router reiniciado exitosamente',
        );
      } else {
        return NetworkActionResponse.error(
          message: response.message ?? 'Error al reiniciar router',
        );
      }
    } on ApiException catch (e) {
      return NetworkActionResponse.error(message: e.message);
    } catch (e) {
      return NetworkActionResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener logs de red
  Future<NetworkLogsResponse> getNetworkLogs({
    int limit = 100,
    String? level,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        if (level != null) 'level': level,
        if (since != null) 'since': since.toIso8601String(),
      };

      final response = await _apiService.get(
        '${AppConstants.networkEndpoint}/logs',
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final data = response.data as List<dynamic>;
        final logs = data
            .map((item) => NetworkLog.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return NetworkLogsResponse.success(logs: logs);
      } else {
        return NetworkLogsResponse.error(
          message: response.message ?? 'Error al obtener logs de red',
        );
      }
    } on ApiException catch (e) {
      return NetworkLogsResponse.error(message: e.message);
    } catch (e) {
      return NetworkLogsResponse.error(message: 'Error inesperado: $e');
    }
  }
}

// Respuesta de estadísticas de red
class NetworkStatsResponse {
  final bool success;
  final String? message;
  final NetworkStatsModel? stats;

  NetworkStatsResponse._({
    required this.success,
    this.message,
    this.stats,
  });

  factory NetworkStatsResponse.success({
    required NetworkStatsModel stats,
    String? message,
  }) {
    return NetworkStatsResponse._(
      success: true,
      stats: stats,
      message: message,
    );
  }

  factory NetworkStatsResponse.error({
    required String message,
  }) {
    return NetworkStatsResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de historial de red
class NetworkHistoryResponse {
  final bool success;
  final String? message;
  final List<NetworkDataPoint>? history;

  NetworkHistoryResponse._({
    required this.success,
    this.message,
    this.history,
  });

  factory NetworkHistoryResponse.success({
    required List<NetworkDataPoint> history,
    String? message,
  }) {
    return NetworkHistoryResponse._(
      success: true,
      history: history,
      message: message,
    );
  }

  factory NetworkHistoryResponse.error({
    required String message,
  }) {
    return NetworkHistoryResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de estado de red
class NetworkStatusResponse {
  final bool success;
  final String? message;
  final String? status;
  final bool? isOnline;
  final DateTime? lastCheck;
  final Duration? uptime;

  NetworkStatusResponse._({
    required this.success,
    this.message,
    this.status,
    this.isOnline,
    this.lastCheck,
    this.uptime,
  });

  factory NetworkStatusResponse.success({
    required String status,
    required bool isOnline,
    required DateTime lastCheck,
    required Duration uptime,
    String? message,
  }) {
    return NetworkStatusResponse._(
      success: true,
      status: status,
      isOnline: isOnline,
      lastCheck: lastCheck,
      uptime: uptime,
      message: message,
    );
  }

  factory NetworkStatusResponse.error({
    required String message,
  }) {
    return NetworkStatusResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de test de velocidad
class SpeedTestResponse {
  final bool success;
  final String? message;
  final double? downloadSpeed;
  final double? uploadSpeed;
  final double? latency;
  final String? server;
  final DateTime? timestamp;

  SpeedTestResponse._({
    required this.success,
    this.message,
    this.downloadSpeed,
    this.uploadSpeed,
    this.latency,
    this.server,
    this.timestamp,
  });

  factory SpeedTestResponse.success({
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? server,
    required DateTime timestamp,
    String? message,
  }) {
    return SpeedTestResponse._(
      success: true,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      latency: latency,
      server: server,
      timestamp: timestamp,
      message: message,
    );
  }

  factory SpeedTestResponse.error({
    required String message,
  }) {
    return SpeedTestResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Configuración de red
class NetworkConfig {
  final String ssid;
  final String password;
  final String securityType;
  final String channel;
  final String bandwidth;
  final bool isHidden;
  final int maxConnections;
  final bool guestNetworkEnabled;
  final String? guestSSID;
  final String? guestPassword;

  NetworkConfig({
    required this.ssid,
    required this.password,
    required this.securityType,
    required this.channel,
    required this.bandwidth,
    required this.isHidden,
    required this.maxConnections,
    required this.guestNetworkEnabled,
    this.guestSSID,
    this.guestPassword,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      securityType: json['security_type'] as String,
      channel: json['channel'] as String,
      bandwidth: json['bandwidth'] as String,
      isHidden: json['is_hidden'] as bool,
      maxConnections: json['max_connections'] as int,
      guestNetworkEnabled: json['guest_network_enabled'] as bool,
      guestSSID: json['guest_ssid'] as String?,
      guestPassword: json['guest_password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'security_type': securityType,
      'channel': channel,
      'bandwidth': bandwidth,
      'is_hidden': isHidden,
      'max_connections': maxConnections,
      'guest_network_enabled': guestNetworkEnabled,
      'guest_ssid': guestSSID,
      'guest_password': guestPassword,
    };
  }
}

// Respuesta de configuración de red
class NetworkConfigResponse {
  final bool success;
  final String? message;
  final NetworkConfig? config;

  NetworkConfigResponse._({
    required this.success,
    this.message,
    this.config,
  });

  factory NetworkConfigResponse.success({
    required NetworkConfig config,
    String? message,
  }) {
    return NetworkConfigResponse._(
      success: true,
      config: config,
      message: message,
    );
  }

  factory NetworkConfigResponse.error({
    required String message,
  }) {
    return NetworkConfigResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de acción de red
class NetworkActionResponse {
  final bool success;
  final String? message;

  NetworkActionResponse._({
    required this.success,
    this.message,
  });

  factory NetworkActionResponse.success({
    required String message,
  }) {
    return NetworkActionResponse._(
      success: true,
      message: message,
    );
  }

  factory NetworkActionResponse.error({
    required String message,
  }) {
    return NetworkActionResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Log de red
class NetworkLog {
  final int id;
  final DateTime timestamp;
  final String level;
  final String message;
  final String? source;
  final Map<String, dynamic>? metadata;

  NetworkLog({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.metadata,
  });

  factory NetworkLog.fromJson(Map<String, dynamic> json) {
    return NetworkLog(
      id: json['id'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: json['level'] as String,
      message: json['message'] as String,
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'message': message,
      'source': source,
      'metadata': metadata,
    };
  }
}

// Respuesta de logs de red
class NetworkLogsResponse {
  final bool success;
  final String? message;
  final List<NetworkLog>? logs;

  NetworkLogsResponse._({
    required this.success,
    this.message,
    this.logs,
  });

  factory NetworkLogsResponse.success({
    required List<NetworkLog> logs,
    String? message,
  }) {
    return NetworkLogsResponse._(
      success: true,
      logs: logs,
      message: message,
    );
  }

  factory NetworkLogsResponse.error({
    required String message,
  }) {
    return NetworkLogsResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
