class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String ssid;
  final String password;
  final String authType;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastConnection;
  final DateTime? expirationDate;
  final String? macAddress;
  final String? currentIP;
  final int timeLimitMinutes;
  final int dataLimitMB;
  final int speedLimitMbps;
  final int currentDataUsageMB;
  final int currentSessionTimeMinutes;
  final bool notificationsEnabled;
  final String? notes;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.ssid,
    required this.password,
    required this.authType,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.lastConnection,
    this.expirationDate,
    this.macAddress,
    this.currentIP,
    required this.timeLimitMinutes,
    required this.dataLimitMB,
    required this.speedLimitMbps,
    required this.currentDataUsageMB,
    required this.currentSessionTimeMinutes,
    required this.notificationsEnabled,
    this.notes,
  });

  // Crear desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      authType: json['auth_type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      lastConnection: json['last_connection'] != null 
          ? DateTime.parse(json['last_connection'] as String) 
          : null,
      expirationDate: json['expiration_date'] != null 
          ? DateTime.parse(json['expiration_date'] as String) 
          : null,
      macAddress: json['mac_address'] as String?,
      currentIP: json['current_ip'] as String?,
      timeLimitMinutes: json['time_limit_minutes'] as int? ?? 0,
      dataLimitMB: json['data_limit_mb'] as int? ?? 0,
      speedLimitMbps: json['speed_limit_mbps'] as int? ?? 0,
      currentDataUsageMB: json['current_data_usage_mb'] as int? ?? 0,
      currentSessionTimeMinutes: json['current_session_time_minutes'] as int? ?? 0,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'ssid': ssid,
      'password': password,
      'auth_type': authType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_connection': lastConnection?.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'mac_address': macAddress,
      'current_ip': currentIP,
      'time_limit_minutes': timeLimitMinutes,
      'data_limit_mb': dataLimitMB,
      'speed_limit_mbps': speedLimitMbps,
      'current_data_usage_mb': currentDataUsageMB,
      'current_session_time_minutes': currentSessionTimeMinutes,
      'notifications_enabled': notificationsEnabled,
      'notes': notes,
    };
  }

  // Crear copia con cambios
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? ssid,
    String? password,
    String? authType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastConnection,
    DateTime? expirationDate,
    String? macAddress,
    String? currentIP,
    int? timeLimitMinutes,
    int? dataLimitMB,
    int? speedLimitMbps,
    int? currentDataUsageMB,
    int? currentSessionTimeMinutes,
    bool? notificationsEnabled,
    String? notes,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      authType: authType ?? this.authType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastConnection: lastConnection ?? this.lastConnection,
      expirationDate: expirationDate ?? this.expirationDate,
      macAddress: macAddress ?? this.macAddress,
      currentIP: currentIP ?? this.currentIP,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      dataLimitMB: dataLimitMB ?? this.dataLimitMB,
      speedLimitMbps: speedLimitMbps ?? this.speedLimitMbps,
      currentDataUsageMB: currentDataUsageMB ?? this.currentDataUsageMB,
      currentSessionTimeMinutes: currentSessionTimeMinutes ?? this.currentSessionTimeMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notes: notes ?? this.notes,
    );
  }

  // Getters para cálculos
  bool get isActive => status.toLowerCase() == 'active';
  bool get isSuspended => status.toLowerCase() == 'suspended';
  bool get isExpired => status.toLowerCase() == 'expired';
  bool get isWarning => status.toLowerCase() == 'warning';

  bool get isConnected => currentIP != null && currentIP!.isNotEmpty;
  bool get hasExpirationDate => expirationDate != null;
  bool get isExpiredByDate => hasExpirationDate && DateTime.now().isAfter(expirationDate!);

  // Porcentajes de uso
  double get timeUsagePercentage {
    if (timeLimitMinutes <= 0) return 0.0;
    return (currentSessionTimeMinutes / timeLimitMinutes).clamp(0.0, 1.0);
  }

  double get dataUsagePercentage {
    if (dataLimitMB <= 0) return 0.0;
    return (currentDataUsageMB / dataLimitMB).clamp(0.0, 1.0);
  }

  // Tiempo restante
  int get remainingTimeMinutes {
    if (timeLimitMinutes <= 0) return -1; // Ilimitado
    return (timeLimitMinutes - currentSessionTimeMinutes).clamp(0, timeLimitMinutes);
  }

  int get remainingDataMB {
    if (dataLimitMB <= 0) return -1; // Ilimitado
    return (dataLimitMB - currentDataUsageMB).clamp(0, dataLimitMB);
  }

  // Verificar si está cerca de los límites
  bool get isNearTimeLimit => timeUsagePercentage >= 0.8;
  bool get isNearDataLimit => dataUsagePercentage >= 0.8;
  bool get isNearExpiration {
    if (!hasExpirationDate) return false;
    final daysUntilExpiry = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3;
  }

  // Obtener estado de alerta
  String get alertStatus {
    if (isExpired || isExpiredByDate) return 'expired';
    if (isSuspended) return 'suspended';
    if (isNearTimeLimit || isNearDataLimit || isNearExpiration) return 'warning';
    if (isActive) return 'active';
    return 'unknown';
  }

  // Verificar si necesita notificación
  bool get needsNotification {
    return notificationsEnabled && (isNearTimeLimit || isNearDataLimit || isNearExpiration);
  }

  // Obtener iniciales del nombre
  String get initials {
    final names = name.split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  // Verificar si el usuario puede conectarse
  bool get canConnect {
    return isActive && 
           !isExpiredByDate && 
           remainingTimeMinutes != 0 && 
           remainingDataMB != 0;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, ssid: $ssid, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
