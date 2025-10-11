import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UsersService {
  final ApiService _apiService = ApiService();

  // Obtener lista de usuarios
  Future<UsersResponse> getUsers({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // MODO DEMO: Simular datos de usuarios
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockUsers = <UserModel>[
        UserModel(
          id: 1,
          name: 'Juan Pérez',
          email: 'juan@ejemplo.com',
          phone: '+1234567890',
          ssid: 'WiFi-Guest-1',
          password: 'guest123',
          authType: 'wpa2',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          lastConnection: DateTime.now().subtract(const Duration(hours: 2)),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          macAddress: '00:11:22:33:44:55',
          currentIP: '192.168.1.100',
          timeLimitMinutes: 120,
          dataLimitMB: 1000,
          speedLimitMbps: 10,
          currentDataUsageMB: 150,
          currentSessionTimeMinutes: 60,
          notificationsEnabled: true,
          notes: 'Usuario temporal',
        ),
        UserModel(
          id: 2,
          name: 'María García',
          email: 'maria@ejemplo.com',
          phone: '+0987654321',
          ssid: 'WiFi-Guest-2',
          password: 'guest456',
          authType: 'wpa2',
          status: 'suspended',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          lastConnection: DateTime.now().subtract(const Duration(days: 1)),
          expirationDate: DateTime.now().add(const Duration(days: 3)),
          macAddress: 'AA:BB:CC:DD:EE:FF',
          currentIP: null,
          timeLimitMinutes: 60,
          dataLimitMB: 500,
          speedLimitMbps: 5,
          currentDataUsageMB: 0,
          currentSessionTimeMinutes: 0,
          notificationsEnabled: false,
          notes: 'Usuario suspendido por mal uso',
        ),
        UserModel(
          id: 3,
          name: 'Carlos López',
          email: 'carlos@ejemplo.com',
          phone: '+1122334455',
          ssid: 'WiFi-Guest-3',
          password: 'guest789',
          authType: 'wpa2',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          lastConnection: DateTime.now().subtract(const Duration(minutes: 30)),
          expirationDate: DateTime.now().add(const Duration(days: 14)),
          macAddress: '11:22:33:44:55:66',
          currentIP: '192.168.1.101',
          timeLimitMinutes: 180,
          dataLimitMB: 2000,
          speedLimitMbps: 15,
          currentDataUsageMB: 75,
          currentSessionTimeMinutes: 30,
          notificationsEnabled: true,
          notes: 'Usuario premium',
        ),
      ];
      
      final pagination = PaginationInfo(
        currentPage: page,
        totalPages: 1,
        totalItems: mockUsers.length,
        itemsPerPage: limit,
        hasNextPage: false,
        hasPreviousPage: false,
      );
      
      return UsersResponse.success(
        users: mockUsers,
        pagination: pagination,
      );
    } catch (e) {
      return UsersResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener usuario por ID
  Future<UserResponse> getUserById(int userId) async {
    try {
      final response = await _apiService.get('${AppConstants.usersEndpoint}/$userId');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(user: user);
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al obtener usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Crear nuevo usuario
  Future<UserResponse> createUser({
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
    try {
      final response = await _apiService.post(
        AppConstants.usersEndpoint,
        data: {
          'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'ssid': ssid,
          'password': password,
          'auth_type': authType,
          if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
          if (dataLimitMB != null) 'data_limit_mb': dataLimitMB,
          if (speedLimitMbps != null) 'speed_limit_mbps': speedLimitMbps,
          if (expirationDate != null) 'expiration_date': expirationDate.toIso8601String(),
          if (macAddress != null) 'mac_address': macAddress,
          'notifications_enabled': notificationsEnabled,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: AppConstants.userCreatedMessage,
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al crear usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Actualizar usuario
  Future<UserResponse> updateUser({
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
    try {
      final data = <String, dynamic>{};
      
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (ssid != null) data['ssid'] = ssid;
      if (password != null) data['password'] = password;
      if (authType != null) data['auth_type'] = authType;
      if (status != null) data['status'] = status;
      if (timeLimitMinutes != null) data['time_limit_minutes'] = timeLimitMinutes;
      if (dataLimitMB != null) data['data_limit_mb'] = dataLimitMB;
      if (speedLimitMbps != null) data['speed_limit_mbps'] = speedLimitMbps;
      if (expirationDate != null) data['expiration_date'] = expirationDate.toIso8601String();
      if (macAddress != null) data['mac_address'] = macAddress;
      if (notificationsEnabled != null) data['notifications_enabled'] = notificationsEnabled;
      if (notes != null) data['notes'] = notes;

      final response = await _apiService.put(
        '${AppConstants.usersEndpoint}/$userId',
        data: data,
      );

      if (response.isSuccess) {
        final responseData = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(responseData);
        
        return UserResponse.success(
          user: user,
          message: AppConstants.userUpdatedMessage,
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al actualizar usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Eliminar usuario
  Future<UserResponse> deleteUser(int userId) async {
    try {
      final response = await _apiService.delete('${AppConstants.usersEndpoint}/$userId');

      if (response.isSuccess) {
        return UserResponse.success(
          message: AppConstants.userDeletedMessage,
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al eliminar usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Suspender usuario
  Future<UserResponse> suspendUser(int userId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.usersEndpoint}/$userId/suspend',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: 'Usuario suspendido exitosamente',
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al suspender usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Activar usuario
  Future<UserResponse> activateUser(int userId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.usersEndpoint}/$userId/activate',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: 'Usuario activado exitosamente',
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al activar usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Desconectar usuario
  Future<UserResponse> disconnectUser(int userId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.usersEndpoint}/$userId/disconnect',
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: 'Usuario desconectado exitosamente',
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al desconectar usuario',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Aumentar tiempo de usuario
  Future<UserResponse> addTimeToUser({
    required int userId,
    required int additionalMinutes,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.usersEndpoint}/$userId/add-time',
        data: {
          'additional_minutes': additionalMinutes,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: 'Tiempo agregado exitosamente',
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al agregar tiempo',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Aumentar límite de datos
  Future<UserResponse> addDataToUser({
    required int userId,
    required int additionalMB,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.usersEndpoint}/$userId/add-data',
        data: {
          'additional_mb': additionalMB,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        return UserResponse.success(
          user: user,
          message: 'Datos agregados exitosamente',
        );
      } else {
        return UserResponse.error(
          message: response.message ?? 'Error al agregar datos',
        );
      }
    } on ApiException catch (e) {
      return UserResponse.error(message: e.message);
    } catch (e) {
      return UserResponse.error(message: 'Error inesperado: $e');
    }
  }

  // Obtener estadísticas de usuarios
  Future<UsersStatsResponse> getUsersStats() async {
    try {
      final response = await _apiService.get('${AppConstants.usersEndpoint}/stats');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        
        return UsersStatsResponse.success(
          stats: UsersStats.fromJson(data),
        );
      } else {
        return UsersStatsResponse.error(
          message: response.message ?? 'Error al obtener estadísticas',
        );
      }
    } on ApiException catch (e) {
      return UsersStatsResponse.error(message: e.message);
    } catch (e) {
      return UsersStatsResponse.error(message: 'Error inesperado: $e');
    }
  }
}

// Respuesta de usuarios
class UsersResponse {
  final bool success;
  final String? message;
  final List<UserModel>? users;
  final PaginationInfo? pagination;

  UsersResponse._({
    required this.success,
    this.message,
    this.users,
    this.pagination,
  });

  factory UsersResponse.success({
    required List<UserModel> users,
    required PaginationInfo pagination,
    String? message,
  }) {
    return UsersResponse._(
      success: true,
      users: users,
      pagination: pagination,
      message: message,
    );
  }

  factory UsersResponse.error({
    required String message,
  }) {
    return UsersResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Respuesta de usuario
class UserResponse {
  final bool success;
  final String? message;
  final UserModel? user;

  UserResponse._({
    required this.success,
    this.message,
    this.user,
  });

  factory UserResponse.success({
    UserModel? user,
    String? message,
  }) {
    return UserResponse._(
      success: true,
      user: user,
      message: message,
    );
  }

  factory UserResponse.error({
    required String message,
  }) {
    return UserResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// Información de paginación
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      itemsPerPage: json['items_per_page'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );
  }
}

// Estadísticas de usuarios
class UsersStats {
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int expiredUsers;
  final int connectedUsers;
  final double averageSessionTime;
  final int totalDataUsageMB;
  final Map<String, int> usersByStatus;

  UsersStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.expiredUsers,
    required this.connectedUsers,
    required this.averageSessionTime,
    required this.totalDataUsageMB,
    required this.usersByStatus,
  });

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    return UsersStats(
      totalUsers: json['total_users'] as int,
      activeUsers: json['active_users'] as int,
      suspendedUsers: json['suspended_users'] as int,
      expiredUsers: json['expired_users'] as int,
      connectedUsers: json['connected_users'] as int,
      averageSessionTime: (json['average_session_time'] as num).toDouble(),
      totalDataUsageMB: json['total_data_usage_mb'] as int,
      usersByStatus: Map<String, int>.from(json['users_by_status'] as Map),
    );
  }
}

// Respuesta de estadísticas de usuarios
class UsersStatsResponse {
  final bool success;
  final String? message;
  final UsersStats? stats;

  UsersStatsResponse._({
    required this.success,
    this.message,
    this.stats,
  });

  factory UsersStatsResponse.success({
    required UsersStats stats,
    String? message,
  }) {
    return UsersStatsResponse._(
      success: true,
      stats: stats,
      message: message,
    );
  }

  factory UsersStatsResponse.error({
    required String message,
  }) {
    return UsersStatsResponse._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
