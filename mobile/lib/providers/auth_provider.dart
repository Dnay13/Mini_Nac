import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AdminModel? _admin;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  AdminModel? get admin => _admin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasAdmin => _admin != null;

  // Inicializar el provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // MODO DEMO: Simular usuario autenticado para desarrollo
      await Future.delayed(const Duration(milliseconds: 500));
      
      _admin = AdminModel(
        id: 1,
        name: 'Admin Demo',
        email: 'admin@demo.com',
        phone: '+1234567890',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = 'Error al inicializar autenticación: $e';
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // MODO DEMO: Simular login exitoso
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _admin = AdminModel(
        id: 1,
        name: 'Admin Demo',
        email: email,
        phone: '+1234567890',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // MODO DEMO: Simular logout
      await Future.delayed(const Duration(milliseconds: 500));
      
      _admin = null;
      _isAuthenticated = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (response.isSuccess) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al cambiar contraseña';
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

  // Solicitar recuperación de contraseña
  Future<bool> requestPasswordReset({
    required String email,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.requestPasswordReset(email: email);
      
      if (response.isSuccess) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al solicitar recuperación';
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

  // Obtener perfil
  Future<bool> getProfile() async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.getProfile();
      
      if (response.isSuccess) {
        _admin = response.admin;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al obtener perfil';
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

  // Actualizar perfil
  Future<bool> updateProfile({
    required String name,
    String? email,
    String? phone,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      
      if (response.isSuccess) {
        _admin = response.admin;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al actualizar perfil';
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

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.isSuccess) {
        _error = null;
        return true;
      } else {
        _error = response.message ?? 'Error al renovar token';
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Establecer loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Verificar si el admin tiene permisos específicos
  bool hasPermission(String permission) {
    // Por ahora, todos los admins tienen todos los permisos
    // En el futuro se puede implementar un sistema de roles
    return _isAuthenticated && _admin != null;
  }

  // Obtener nombre del admin
  String get adminName => _admin?.name ?? 'Administrador';

  // Obtener email del admin
  String get adminEmail => _admin?.email ?? '';

  // Obtener iniciales del admin
  String get adminInitials => _admin?.initials ?? 'A';

  // Verificar si el perfil está completo
  bool get isProfileComplete {
    if (_admin == null) return false;
    return _admin!.name.isNotEmpty && _admin!.email.isNotEmpty;
  }

  // Obtener tiempo desde último login
  Duration? get timeSinceLastLogin {
    if (_admin?.lastLogin == null) return null;
    return DateTime.now().difference(_admin!.lastLogin!);
  }

  // Verificar si necesita actualizar perfil
  bool get needsProfileUpdate {
    if (_admin == null) return true;
    
    // Verificar si faltan datos importantes
    if (_admin!.name.isEmpty || _admin!.email.isEmpty) return true;
    
    // Verificar si no se ha actualizado en mucho tiempo
    final daysSinceUpdate = DateTime.now().difference(_admin!.createdAt).inDays;
    return daysSinceUpdate > 30; // Sugerir actualización cada 30 días
  }

  @override
  void dispose() {
    super.dispose();
  }
}
