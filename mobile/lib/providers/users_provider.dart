import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/users_service.dart';

class UsersProvider with ChangeNotifier {
  final UsersService _usersService = UsersService();
  
  List<UserModel> _users = [];
  UserModel? _selectedUser;
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;
  UsersStats? _stats;
  
  // Filtros y búsqueda
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  
  // Estados de carga específicos
  bool _isLoadingStats = false;
  bool _isLoadingMore = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  UsersStats? get stats => _stats;
  
  // Filtros
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  
  // Estados específicos
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingMore => _isLoadingMore;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  
  // Computed properties
  List<UserModel> get filteredUsers {
    List<UserModel> filtered = _users;
    
    // Aplicar filtro de estado
    if (_statusFilter != 'all') {
      filtered = filtered.where((user) => user.status.toLowerCase() == _statusFilter).toList();
    }
    
    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final query = _searchQuery.toLowerCase();
        return user.name.toLowerCase().contains(query) ||
               user.ssid.toLowerCase().contains(query) ||
               (user.email?.toLowerCase().contains(query) ?? false) ||
               (user.currentIP?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return filtered;
  }
  
  int get totalUsers => _users.length;
  int get activeUsers => _users.where((user) => user.isActive).length;
  int get connectedUsers => _users.where((user) => user.isConnected).length;
  int get suspendedUsers => _users.where((user) => user.isSuspended).length;
  int get expiredUsers => _users.where((user) => user.isExpired).length;

  // Cargar usuarios
  Future<bool> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _setLoading(true);
    } else {
      _setLoadingMore(true);
    }
    
    _error = null;
    
    try {
      final response = await _usersService.getUsers(
        page: refresh ? 1 : (_pagination?.currentPage ?? 0) + 1,
        limit: 20,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter != 'all' ? _statusFilter : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      if (response.isSuccess) {
        if (refresh || _pagination == null) {
          _users = response.users ?? [];
        } else {
          _users.addAll(response.users ?? []);
        }
        _pagination = response.pagination;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar usuarios';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  // Cargar estadísticas
  Future<bool> loadStats() async {
    _setLoadingStats(true);
    _error = null;
    
    try {
      final response = await _usersService.getUsersStats();
      
      if (response.isSuccess) {
        _stats = response.stats;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cargar estadísticas';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoadingStats(false);
    }
  }

  // Obtener usuario por ID
  Future<bool> getUserById(int userId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _usersService.getUserById(userId);
      
      if (response.isSuccess) {
        _selectedUser = response.user;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al obtener usuario';
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

  // Crear usuario
  Future<bool> createUser({
    required String name,
    String? email,
    String? phone,
    required String ssid,
    required String password,
    required String authType,
    int? timeLimitMinutes,
    int? dataLimitMB,
    int? speedLimitMbps,
    DateTime? expirationDate,
    String? macAddress,
    bool notificationsEnabled = true,
    String? notes,
  }) async {
    _setCreating(true);
    _error = null;
    
    try {
      final response = await _usersService.createUser(
        name: name,
        email: email,
        phone: phone,
        ssid: ssid,
        password: password,
        authType: authType,
        timeLimitMinutes: timeLimitMinutes,
        dataLimitMB: dataLimitMB,
        speedLimitMbps: speedLimitMbps,
        expirationDate: expirationDate,
        macAddress: macAddress,
        notificationsEnabled: notificationsEnabled,
        notes: notes,
      );
      
      if (response.isSuccess) {
        // Agregar el nuevo usuario a la lista
        if (response.user != null) {
          _users.insert(0, response.user!);
        }
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al crear usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setCreating(false);
    }
  }

  // Actualizar usuario
  Future<bool> updateUser({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? ssid,
    String? password,
    String? authType,
    String? status,
    int? timeLimitMinutes,
    int? dataLimitMB,
    int? speedLimitMbps,
    DateTime? expirationDate,
    String? macAddress,
    bool? notificationsEnabled,
    String? notes,
  }) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.updateUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        ssid: ssid,
        password: password,
        authType: authType,
        status: status,
        timeLimitMinutes: timeLimitMinutes,
        dataLimitMB: dataLimitMB,
        speedLimitMbps: speedLimitMbps,
        expirationDate: expirationDate,
        macAddress: macAddress,
        notificationsEnabled: notificationsEnabled,
        notes: notes,
      );
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        // Actualizar usuario seleccionado si es el mismo
        if (_selectedUser?.id == userId && response.user != null) {
          _selectedUser = response.user;
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al actualizar usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Eliminar usuario
  Future<bool> deleteUser(int userId) async {
    _setDeleting(true);
    _error = null;
    
    try {
      final response = await _usersService.deleteUser(userId);
      
      if (response.isSuccess) {
        // Remover usuario de la lista
        _users.removeWhere((user) => user.id == userId);
        
        // Limpiar usuario seleccionado si es el mismo
        if (_selectedUser?.id == userId) {
          _selectedUser = null;
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al eliminar usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  // Suspender usuario
  Future<bool> suspendUser(int userId) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.suspendUser(userId);
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al suspender usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Activar usuario
  Future<bool> activateUser(int userId) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.activateUser(userId);
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al activar usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Desconectar usuario
  Future<bool> disconnectUser(int userId) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.disconnectUser(userId);
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al desconectar usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Agregar tiempo a usuario
  Future<bool> addTimeToUser({
    required int userId,
    required int additionalMinutes,
  }) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.addTimeToUser(
        userId: userId,
        additionalMinutes: additionalMinutes,
      );
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al agregar tiempo';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Agregar datos a usuario
  Future<bool> addDataToUser({
    required int userId,
    required int additionalMB,
  }) async {
    _setUpdating(true);
    _error = null;
    
    try {
      final response = await _usersService.addDataToUser(
        userId: userId,
        additionalMB: additionalMB,
      );
      
      if (response.isSuccess) {
        // Actualizar usuario en la lista
        if (response.user != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = response.user!;
          }
        }
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al agregar datos';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Establecer usuario seleccionado
  void setSelectedUser(UserModel? user) {
    _selectedUser = user;
    notifyListeners();
  }

  // Limpiar usuario seleccionado
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  // Establecer filtros
  void setFilters({
    String? searchQuery,
    String? statusFilter,
    String? sortBy,
    String? sortOrder,
  }) {
    bool shouldReload = false;
    
    if (searchQuery != null && searchQuery != _searchQuery) {
      _searchQuery = searchQuery;
      shouldReload = true;
    }
    
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
      loadUsers(refresh: true);
    }
    
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'all';
    _sortBy = 'name';
    _sortOrder = 'asc';
    loadUsers(refresh: true);
    notifyListeners();
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

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setLoadingStats(bool loading) {
    _isLoadingStats = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }

  // Verificar si hay más páginas
  bool get hasMorePages => _pagination?.hasNextPage ?? false;

  // Verificar si está cargando la primera página
  bool get isFirstPage => _pagination?.currentPage == 1;

  // Obtener usuarios por estado
  List<UserModel> getUsersByStatus(String status) {
    return _users.where((user) => user.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Obtener usuarios conectados
  List<UserModel> get connectedUsersList {
    return _users.where((user) => user.isConnected).toList();
  }

  // Obtener usuarios que necesitan atención
  List<UserModel> get usersNeedingAttention {
    return _users.where((user) => 
      user.isNearTimeLimit || 
      user.isNearDataLimit || 
      user.isNearExpiration ||
      user.isExpired
    ).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
