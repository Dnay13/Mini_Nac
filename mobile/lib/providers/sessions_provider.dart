import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SessionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<SessionModel> _activeSessions = [];
  List<SessionModel> _sessionHistory = [];
  SessionModel? _selectedSession;
  
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Paginación para historial
  int _currentPage = 1;
  bool _hasMorePages = true;
  
  // Timer para polling de sesiones activas
  Timer? _sessionsTimer;
  
  // Filtros
  String _statusFilter = 'all';
  String _sortBy = 'start_time';
  String _sortOrder = 'desc';

  // Getters
  List<SessionModel> get activeSessions => _activeSessions;
  List<SessionModel> get sessionHistory => _sessionHistory;
  SessionModel? get selectedSession => _selectedSession;
  
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  
  // Computed properties
  int get totalActiveSessions => _activeSessions.length;
  int get totalSessionHistory => _sessionHistory.length;
  
  List<SessionModel> get filteredSessionHistory {
    List<SessionModel> filtered = _sessionHistory;
    
    // Aplicar filtro de estado
    if (_statusFilter != 'all') {
      filtered = filtered.where((session) => 
        session.status.toLowerCase() == _statusFilter.toLowerCase()
      ).toList();
    }
    
    return filtered;
  }
  
  // Sesiones por estado
  List<SessionModel> get completedSessions {
    return _sessionHistory.where((session) => session.isCompleted).toList();
  }
  
  List<SessionModel> get disconnectedSessions {
    return _sessionHistory.where((session) => session.isDisconnected).toList();
  }
  
  List<SessionModel> get expiredSessions {
    return _sessionHistory.where((session) => session.isExpired).toList();
  }
  
  // Sesiones recientes (últimas 24 horas)
  List<SessionModel> get recentSessions {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _sessionHistory.where((session) => 
      session.startTime.isAfter(cutoff)
    ).toList();
  }
  
  // Sesiones de hoy
  List<SessionModel> get todaySessions {
    final now = DateTime.now();
    return _sessionHistory.where((session) => 
      session.startTime.year == now.year &&
      session.startTime.month == now.month &&
      session.startTime.day == now.day
    ).toList();
  }

  // Cargar sesiones activas
  Future<bool> loadActiveSessions() async {
    _setLoading(true);
    _error = null;
    
    try {
      // MODO DEMO: Simular sesiones activas
      await Future.delayed(const Duration(milliseconds: 600));
      
      _activeSessions = [
        SessionModel(
          id: 1,
          userId: 1,
          userName: 'Juan Pérez',
          ssid: 'WiFi-Guest-1',
          ipAddress: '192.168.1.100',
          macAddress: '00:11:22:33:44:55',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: null,
          status: 'active',
          dataUsageMB: 150,
          durationMinutes: 120,
          disconnectReason: null,
          metadata: {
            'deviceInfo': 'iPhone 13 Pro',
            'location': 'Sala de espera',
            'notes': 'Usuario temporal',
          },
        ),
        SessionModel(
          id: 2,
          userId: 3,
          userName: 'Carlos López',
          ssid: 'WiFi-Guest-3',
          ipAddress: '192.168.1.101',
          macAddress: '11:22:33:44:55:66',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          endTime: null,
          status: 'active',
          dataUsageMB: 75,
          durationMinutes: 30,
          disconnectReason: null,
          metadata: {
            'deviceInfo': 'Samsung Galaxy S21',
            'location': 'Oficina principal',
            'notes': 'Usuario premium',
          },
        ),
      ];
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar historial de sesiones
  Future<bool> loadSessionHistory({bool loadMore = false}) async {
    if (loadMore) {
      _setLoadingMore(true);
    } else {
      _setLoadingHistory(true);
      _currentPage = 1;
      _hasMorePages = true;
    }
    
    _error = null;
    
    try {
      final response = await _apiService.get(
        '${AppConstants.sessionsEndpoint}/history',
        queryParameters: {
          'page': loadMore ? _currentPage + 1 : 1,
          'limit': AppConstants.defaultPageSize,
          'status': _statusFilter != 'all' ? _statusFilter : null,
          'sort_by': _sortBy,
          'sort_order': _sortOrder,
        },
      );
      
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final sessionsData = data['sessions'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        
        final sessions = sessionsData
            .map((sessionJson) => SessionModel.fromJson(sessionJson as Map<String, dynamic>))
            .toList();
        
        if (loadMore) {
          _sessionHistory.addAll(sessions);
          _currentPage++;
        } else {
          _sessionHistory = sessions;
          _currentPage = 1;
        }
        
        _hasMorePages = pagination['has_next_page'] as bool;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar historial de sesiones';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingHistory(false);
      _setLoadingMore(false);
    }
  }

  // Obtener sesión por ID
  Future<bool> getSessionById(int sessionId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.get('${AppConstants.sessionsEndpoint}/$sessionId');
      
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        _selectedSession = SessionModel.fromJson(data);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al obtener sesión';
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

  // Desconectar sesión
  Future<bool> disconnectSession(int sessionId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.post('${AppConstants.sessionsEndpoint}/$sessionId/disconnect');
      
      if (response.isSuccess) {
        // Remover de sesiones activas
        _activeSessions.removeWhere((session) => session.id == sessionId);
        
        // Actualizar en historial si existe
        final historyIndex = _sessionHistory.indexWhere((session) => session.id == sessionId);
        if (historyIndex != -1) {
          _sessionHistory[historyIndex] = _sessionHistory[historyIndex].copyWith(
            status: 'disconnected',
            endTime: DateTime.now(),
          );
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al desconectar sesión';
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

  // Desconectar todas las sesiones
  Future<bool> disconnectAllSessions() async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.post('${AppConstants.sessionsEndpoint}/disconnect-all');
      
      if (response.isSuccess) {
        // Limpiar sesiones activas
        _activeSessions.clear();
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al desconectar todas las sesiones';
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

  // Obtener estadísticas de sesiones
  Future<Map<String, dynamic>?> getSessionStats() async {
    try {
      final response = await _apiService.get('${AppConstants.sessionsEndpoint}/stats');
      
      if (response.isSuccess) {
        return response.data as Map<String, dynamic>;
      } else {
        _error = response.message ?? 'Error al obtener estadísticas de sesiones';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return null;
    }
  }

  // Obtener sesiones por usuario
  Future<List<SessionModel>> getSessionsByUser(int userId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.sessionsEndpoint}/user/$userId',
      );
      
      if (response.isSuccess) {
        final data = response.data as List<dynamic>;
        return data
            .map((sessionJson) => SessionModel.fromJson(sessionJson as Map<String, dynamic>))
            .toList();
      } else {
        _error = response.message ?? 'Error al obtener sesiones del usuario';
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return [];
    }
  }

  // Establecer sesión seleccionada
  void setSelectedSession(SessionModel? session) {
    _selectedSession = session;
    notifyListeners();
  }

  // Limpiar sesión seleccionada
  void clearSelectedSession() {
    _selectedSession = null;
    notifyListeners();
  }

  // Establecer filtros
  void setFilters({
    String? statusFilter,
    String? sortBy,
    String? sortOrder,
  }) {
    bool shouldReload = false;
    
    if (statusFilter != null && statusFilter != _statusFilter) {
      _statusFilter = statusFilter;
      shouldReload = true;
    }
    
    if (sortBy != null && sortBy != _sortBy) {
      _sortBy = sortBy;
      shouldReload = true;
    }
    
    if (sortOrder != null && sortOrder != _sortOrder) {
      _sortOrder = sortOrder;
      shouldReload = true;
    }
    
    if (shouldReload) {
      loadSessionHistory();
    }
    
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _statusFilter = 'all';
    _sortBy = 'start_time';
    _sortOrder = 'desc';
    loadSessionHistory();
    notifyListeners();
  }

  // Iniciar polling de sesiones activas
  void startPolling() {
    _sessionsTimer?.cancel();
    _sessionsTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.sessionsPollingInterval),
      (_) => loadActiveSessions(),
    );
  }

  // Detener polling
  void stopPolling() {
    _sessionsTimer?.cancel();
    _sessionsTimer = null;
  }

  // Refrescar todos los datos
  Future<void> refreshAll() async {
    await Future.wait([
      loadActiveSessions(),
      loadSessionHistory(),
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

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  // Obtener sesiones por día
  Map<DateTime, List<SessionModel>> get sessionsByDay {
    final Map<DateTime, List<SessionModel>> grouped = {};
    
    for (final session in _sessionHistory) {
      final day = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(session);
    }
    
    return grouped;
  }

  // Obtener sesiones por hora del día
  Map<int, List<SessionModel>> get sessionsByHour {
    final Map<int, List<SessionModel>> grouped = {};
    
    for (final session in _sessionHistory) {
      final hour = session.startTime.hour;
      
      if (!grouped.containsKey(hour)) {
        grouped[hour] = [];
      }
      grouped[hour]!.add(session);
    }
    
    return grouped;
  }

  // Obtener duración total de sesiones
  Duration get totalSessionDuration {
    return _sessionHistory.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.elapsedTime,
    );
  }

  // Obtener uso total de datos
  int get totalDataUsage {
    return _sessionHistory.fold<int>(
      0,
      (total, session) => total + session.dataUsageMB,
    );
  }

  // Obtener duración promedio de sesión
  Duration get averageSessionDuration {
    if (_sessionHistory.isEmpty) return Duration.zero;
    
    final totalMinutes = _sessionHistory.fold<int>(
      0,
      (total, session) => total + session.durationMinutes,
    );
    
    return Duration(minutes: totalMinutes ~/ _sessionHistory.length);
  }

  // Obtener sesiones más largas
  List<SessionModel> get longestSessions {
    final sorted = List<SessionModel>.from(_sessionHistory);
    sorted.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
    return sorted.take(10).toList();
  }

  // Obtener sesiones con más uso de datos
  List<SessionModel> get sessionsWithMostDataUsage {
    final sorted = List<SessionModel>.from(_sessionHistory);
    sorted.sort((a, b) => b.dataUsageMB.compareTo(a.dataUsageMB));
    return sorted.take(10).toList();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
