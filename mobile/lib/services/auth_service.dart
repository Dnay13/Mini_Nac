import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Guardar token
        await _apiService.setAuthToken(token);
        
        // Crear modelo de usuario admin
        final admin = AdminModel.fromJson(userData);
        
        return AuthResponse.success(
          token: token,
          admin: admin,
        );
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error de autenticación',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Llamar al endpoint de logout si existe
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Ignorar errores de logout, siempre limpiar token local
    } finally {
      // Limpiar token local
      await _apiService.logout();
    }
  }

  // Verificar si está autenticado
  bool get isAuthenticated => _apiService.isAuthenticated;

  // Obtener token actual
  String? get currentToken => _apiService.authToken;

  // Refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh');
      
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String;
        
        await _apiService.setAuthToken(token);
        
        return AuthResponse.success(token: token);
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error al renovar token',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Cambiar contraseña
  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.isSuccess) {
        return AuthResponse.success(
          message: 'Contraseña cambiada exitosamente',
        );
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error al cambiar contraseña',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Solicitar recuperación de contraseña
  Future<AuthResponse> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      if (response.isSuccess) {
        return AuthResponse.success(
          message: 'Se ha enviado un enlace de recuperación a tu email',
        );
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error al solicitar recuperación',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Verificar token
  Future<AuthResponse> verifyToken() async {
    try {
      final response = await _apiService.get('/auth/verify');
      
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final admin = AdminModel.fromJson(userData);
        
        return AuthResponse.success(admin: admin);
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Token inválido',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener perfil del administrador
  Future<AuthResponse> getProfile() async {
    try {
      final response = await _apiService.get('/auth/profile');
      
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final admin = AdminModel.fromJson(data);
        
        return AuthResponse.success(admin: admin);
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error al obtener perfil',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Actualizar perfil del administrador
  Future<AuthResponse> updateProfile({
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/profile',
        data: {
          'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final admin = AdminModel.fromJson(data);
        
        return AuthResponse.success(
          admin: admin,
          message: 'Perfil actualizado exitosamente',
        );
      } else {
        return AuthResponse.error(
          message: response.message ?? 'Error al actualizar perfil',
        );
      }
    } on ApiException catch (e) {
      return AuthResponse.error(message: e.message);
    } catch (e) {
      return AuthResponse.error(message: 'Error inesperado: $e');
    }
  }
}

// Modelo de administrador
class AdminModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? avatar;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
    this.lastLogin,
    required this.isActive,
    this.avatar,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'avatar': avatar,
    };
  }

  AdminModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? avatar,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      avatar: avatar ?? this.avatar,
    );
  }

  // Obtener iniciales del nombre
  String get initials {
    final names = name.split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  @override
  String toString() {
    return 'AdminModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Respuesta de autenticación
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final AdminModel? admin;

  AuthResponse._({
    required this.success,
    this.message,
    this.token,
    this.admin,
  });

  factory AuthResponse.success({
    String? message,
    String? token,
    AdminModel? admin,
  }) {
    return AuthResponse._(
      success: true,
      message: message,
      token: token,
      admin: admin,
    );
  }

  factory AuthResponse.error({
    required String message,
  }) {
    return AuthResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
