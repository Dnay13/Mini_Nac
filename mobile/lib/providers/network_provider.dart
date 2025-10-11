import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/network_stats_model.dart';
import '../services/network_service.dart';
import '../utils/constants.dart';

class NetworkProvider with ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  
  NetworkStatsModel? _networkStats;
  List<NetworkDataPoint> _speedHistory = [];
  NetworkConfig? _networkConfig;
  List<NetworkLog> _networkLogs = [];
  
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isLoadingConfig = false;
  bool _isLoadingLogs = false;
  bool _isPerformingSpeedTest = false;
  bool _isRestarting = false;
  
  String? _error;
  
  // Timers para polling
  Timer? _statsTimer;
  Timer? _historyTimer;
  
  // Estados de la red
  bool _isOnline = true;
  DateTime? _lastUpdate;
  Duration? _uptime;

  // Getters
  NetworkStatsModel? get networkStats => _networkStats;
  List<NetworkDataPoint> get speedHistory => _speedHistory;
  NetworkConfig? get networkConfig => _networkConfig;
  List<NetworkLog> get networkLogs => _networkLogs;
  
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingConfig => _isLoadingConfig;
  bool get isLoadingLogs => _isLoadingLogs;
  bool get isPerformingSpeedTest => _isPerformingSpeedTest;
  bool get isRestarting => _isRestarting;
  
  String? get error => _error;
  bool get isOnline => _isOnline;
  DateTime? get lastUpdate => _lastUpdate;
  Duration? get uptime => _uptime;
  
  // Computed properties
  bool get hasNetworkStats => _networkStats != null;
  bool get hasSpeedHistory => _speedHistory.isNotEmpty;
  bool get hasNetworkConfig => _networkConfig != null;
  bool get hasNetworkLogs => _networkLogs.isNotEmpty;
  
  // Estado de la red basado en estadísticas
  String get networkStatus {
    if (_networkStats == null) return 'unknown';
    return _networkStats!.overallStatus;
  }
  
  // Velocidad actual
  double get currentDownloadSpeed => _networkStats?.downloadSpeed ?? 0.0;
  double get currentUploadSpeed => _networkStats?.uploadSpeed ?? 0.0;
  double get currentLatency => _networkStats?.latency ?? 0.0;
  
  // Usuarios conectados
  int get activeUsers => _networkStats?.activeUsers ?? 0;
  int get totalUsers => _networkStats?.totalUsers ?? 0;
  
  // Utilización de ancho de banda
  double get bandwidthUtilization => _networkStats?.bandwidthUtilization ?? 0.0;
  
  // Uso total de datos
  int get totalDataUsage => _networkStats?.totalDataUsageMB ?? 0;

  // Inicializar el provider
  Future<void> initialize() async {
    await loadNetworkStats();
    await loadSpeedHistory();
    await loadNetworkConfig();
    startPolling();
  }

  // Cargar estadísticas de red
  Future<bool> loadNetworkStats() async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _networkService.getNetworkStats();
      
      if (response.isSuccess) {
        _networkStats = response.stats;
        _lastUpdate = DateTime.now();
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar estadísticas de red';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar historial de velocidad
  Future<bool> loadSpeedHistory({int hours = 24}) async {
    _setLoadingHistory(true);
    _error = null;
    
    try {
      final response = await _networkService.getSpeedHistory(hours: hours);
      
      if (response.isSuccess) {
        _speedHistory = response.history ?? [];
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar historial de velocidad';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingHistory(false);
    }
  }

  // Cargar configuración de red
  Future<bool> loadNetworkConfig() async {
    _setLoadingConfig(true);
    _error = null;
    
    try {
      final response = await _networkService.getNetworkConfig();
      
      if (response.isSuccess) {
        _networkConfig = response.config;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar configuración de red';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingConfig(false);
    }
  }

  // Cargar logs de red
  Future<bool> loadNetworkLogs({int limit = 100}) async {
    _setLoadingLogs(true);
    _error = null;
    
    try {
      final response = await _networkService.getNetworkLogs(limit: limit);
      
      if (response.isSuccess) {
        _networkLogs = response.logs ?? [];
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar logs de red';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingLogs(false);
    }
  }

  // Realizar test de velocidad
  Future<bool> performSpeedTest() async {
    _setPerformingSpeedTest(true);
    _error = null;
    
    try {
      final response = await _networkService.performSpeedTest();
      
      if (response.isSuccess) {
        // Actualizar estadísticas con los nuevos datos
        if (_networkStats != null) {
          _networkStats = _networkStats!.copyWith(
            downloadSpeed: response.downloadSpeed ?? 0.0,
            uploadSpeed: response.uploadSpeed ?? 0.0,
            latency: response.latency ?? 0.0,
            lastUpdated: response.timestamp ?? DateTime.now(),
          );
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al realizar test de velocidad';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setPerformingSpeedTest(false);
    }
  }

  // Actualizar configuración de red
  Future<bool> updateNetworkConfig(NetworkConfig config) async {
    _setLoadingConfig(true);
    _error = null;
    
    try {
      final response = await _networkService.updateNetworkConfig(config: config);
      
      if (response.isSuccess) {
        _networkConfig = response.config;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al actualizar configuración';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingConfig(false);
    }
  }

  // Reiniciar router
  Future<bool> restartRouter() async {
    _setRestarting(true);
    _error = null;
    
    try {
      final response = await _networkService.restartRouter();
      
      if (response.isSuccess) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al reiniciar router';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setRestarting(false);
    }
  }

  // Obtener estado de la red
  Future<bool> getNetworkStatus() async {
    try {
      final response = await _networkService.getNetworkStatus();
      
      if (response.isSuccess) {
        _isOnline = response.isOnline ?? true;
        _uptime = response.uptime;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al obtener estado de red';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      _isOnline = false;
      notifyListeners();
      return false;
    }
  }

  // Iniciar polling automático
  void startPolling() {
    // Polling de estadísticas cada 10 segundos
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.networkPollingInterval),
      (_) => loadNetworkStats(),
    );
    
    // Polling de historial cada minuto
    _historyTimer?.cancel();
    _historyTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.statsPollingInterval),
      (_) => loadSpeedHistory(),
    );
  }

  // Detener polling
  void stopPolling() {
    _statsTimer?.cancel();
    _statsTimer = null;
    _historyTimer?.cancel();
    _historyTimer = null;
  }

  // Refrescar todos los datos
  Future<void> refreshAll() async {
    await Future.wait([
      loadNetworkStats(),
      loadSpeedHistory(),
      loadNetworkConfig(),
      getNetworkStatus(),
    ]);
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos privados para establecer estados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingHistory(bool loading) {
    _isLoadingHistory = loading;
    notifyListeners();
  }

  void _setLoadingConfig(bool loading) {
    _isLoadingConfig = loading;
    notifyListeners();
  }

  void _setLoadingLogs(bool loading) {
    _isLoadingLogs = loading;
    notifyListeners();
  }

  void _setPerformingSpeedTest(bool performing) {
    _isPerformingSpeedTest = performing;
    notifyListeners();
  }

  void _setRestarting(bool restarting) {
    _isRestarting = restarting;
    notifyListeners();
  }

  // Verificar si la red tiene problemas
  bool get hasNetworkIssues {
    if (_networkStats == null) return false;
    return _networkStats!.hasNetworkIssues;
  }

  // Obtener recomendaciones
  List<String> get recommendations {
    if (_networkStats == null) return [];
    return _networkStats!.recommendations;
  }

  // Obtener tendencia de velocidad
  String get speedTrend {
    if (_networkStats == null) return 'stable';
    return _networkStats!.speedTrend;
  }

  // Verificar si los datos están actualizados
  bool get isDataFresh {
    if (_lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!).inMinutes < 5;
  }

  // Obtener velocidad máxima histórica
  double get maxHistoricalSpeed {
    if (_networkStats == null) return 0.0;
    return _networkStats!.maxHistoricalSpeed;
  }

  // Obtener velocidad mínima histórica
  double get minHistoricalSpeed {
    if (_networkStats == null) return 0.0;
    return _networkStats!.minHistoricalSpeed;
  }

  // Obtener velocidad promedio histórica
  double get averageHistoricalSpeed {
    if (_networkStats == null) return 0.0;
    return _networkStats!.averageHistoricalSpeed;
  }

  // Obtener logs por nivel
  List<NetworkLog> getLogsByLevel(String level) {
    return _networkLogs.where((log) => log.level.toLowerCase() == level.toLowerCase()).toList();
  }

  // Obtener logs recientes (últimas 24 horas)
  List<NetworkLog> get recentLogs {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _networkLogs.where((log) => log.timestamp.isAfter(cutoff)).toList();
  }

  // Obtener logs de error
  List<NetworkLog> get errorLogs {
    return _networkLogs.where((log) => 
      log.level.toLowerCase() == 'error' || 
      log.level.toLowerCase() == 'critical'
    ).toList();
  }

  // Verificar si hay logs de error recientes
  bool get hasRecentErrors {
    return errorLogs.any((log) => 
      DateTime.now().difference(log.timestamp).inHours <= 24
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
