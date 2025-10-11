class QRModel {
  final int id;
  final String ssid;
  final String password;
  final String authType;
  final String qrData;
  final String qrImagePath;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status;
  final int? userId;
  final String? userName;
  final int usageCount;
  final int maxUsage;
  final String? description;
  final Map<String, dynamic>? metadata;

  QRModel({
    required this.id,
    required this.ssid,
    required this.password,
    required this.authType,
    required this.qrData,
    required this.qrImagePath,
    required this.createdAt,
    this.expiresAt,
    required this.status,
    this.userId,
    this.userName,
    required this.usageCount,
    required this.maxUsage,
    this.description,
    this.metadata,
  });

  // Crear desde JSON
  factory QRModel.fromJson(Map<String, dynamic> json) {
    return QRModel(
      id: json['id'] as int,
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      authType: json['auth_type'] as String,
      qrData: json['qr_data'] as String,
      qrImagePath: json['qr_image_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
      status: json['status'] as String,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      maxUsage: json['max_usage'] as int? ?? -1, // -1 = ilimitado
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ssid': ssid,
      'password': password,
      'auth_type': authType,
      'qr_data': qrData,
      'qr_image_path': qrImagePath,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'status': status,
      'user_id': userId,
      'user_name': userName,
      'usage_count': usageCount,
      'max_usage': maxUsage,
      'description': description,
      'metadata': metadata,
    };
  }

  // Crear copia con cambios
  QRModel copyWith({
    int? id,
    String? ssid,
    String? password,
    String? authType,
    String? qrData,
    String? qrImagePath,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
    int? userId,
    String? userName,
    int? usageCount,
    int? maxUsage,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return QRModel(
      id: id ?? this.id,
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      authType: authType ?? this.authType,
      qrData: qrData ?? this.qrData,
      qrImagePath: qrImagePath ?? this.qrImagePath,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      usageCount: usageCount ?? this.usageCount,
      maxUsage: maxUsage ?? this.maxUsage,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters para cálculos
  bool get isActive => status.toLowerCase() == 'active';
  bool get isExpired => status.toLowerCase() == 'expired';
  bool get isDisabled => status.toLowerCase() == 'disabled';
  bool get isUsed => status.toLowerCase() == 'used';

  bool get hasExpirationDate => expiresAt != null;
  bool get isExpiredByDate => hasExpirationDate && DateTime.now().isAfter(expiresAt!);
  bool get hasUsageLimit => maxUsage > 0;
  bool get isUsageLimitReached => hasUsageLimit && usageCount >= maxUsage;

  // Verificar si el QR está disponible para uso
  bool get isAvailable {
    return isActive && 
           !isExpiredByDate && 
           !isUsageLimitReached;
  }

  // Tiempo restante hasta expiración
  Duration? get timeUntilExpiration {
    if (!hasExpirationDate) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  // Usos restantes
  int get remainingUsage {
    if (!hasUsageLimit) return -1; // Ilimitado
    return (maxUsage - usageCount).clamp(0, maxUsage);
  }

  // Porcentaje de uso
  double get usagePercentage {
    if (!hasUsageLimit) return 0.0;
    return (usageCount / maxUsage).clamp(0.0, 1.0);
  }

  // Verificar si está cerca de expirar (menos de 24 horas)
  bool get isNearExpiration {
    if (!hasExpirationDate) return false;
    final timeLeft = timeUntilExpiration;
    if (timeLeft == null) return false;
    return timeLeft.inHours <= 24;
  }

  // Verificar si está cerca del límite de uso (80% o más)
  bool get isNearUsageLimit {
    if (!hasUsageLimit) return false;
    return usagePercentage >= 0.8;
  }

  // Obtener estado de alerta
  String get alertStatus {
    if (isExpired || isExpiredByDate) return 'expired';
    if (isUsageLimitReached) return 'used';
    if (isNearExpiration || isNearUsageLimit) return 'warning';
    if (isActive) return 'active';
    return 'unknown';
  }

  // Obtener color según el estado
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'green';
      case 'expired':
        return 'red';
      case 'disabled':
        return 'gray';
      case 'used':
        return 'orange';
      default:
        return 'blue';
    }
  }

  // Obtener ícono según el estado
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'active':
        return 'qr_code';
      case 'expired':
        return 'schedule';
      case 'disabled':
        return 'block';
      case 'used':
        return 'check_circle';
      default:
        return 'help';
    }
  }

  // Formatear tiempo restante
  String get timeRemainingFormatted {
    if (!hasExpirationDate) return 'Sin expiración';
    
    final timeLeft = timeUntilExpiration;
    if (timeLeft == null || timeLeft.isNegative) return 'Expirado';
    
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays} día${timeLeft.inDays > 1 ? 's' : ''}';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours} hora${timeLeft.inHours > 1 ? 's' : ''}';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes} minuto${timeLeft.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Menos de 1 minuto';
    }
  }

  // Formatear usos restantes
  String get remainingUsageFormatted {
    if (!hasUsageLimit) return 'Ilimitado';
    final remaining = remainingUsage;
    if (remaining <= 0) return 'Agotado';
    return '$remaining uso${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}';
  }

  // Formatear fecha de creación
  String get createdAtFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Formatear fecha de expiración
  String get expiresAtFormatted {
    if (!hasExpirationDate) return 'Sin expiración';
    return '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}';
  }

  // Obtener tipo de autenticación formateado
  String get authTypeFormatted {
    switch (authType.toUpperCase()) {
      case 'WPA2':
        return 'WPA2';
      case 'WPA3':
        return 'WPA3';
      case 'WPA2/WPA3':
        return 'WPA2/WPA3';
      default:
        return authType;
    }
  }

  // Generar datos del QR en formato estándar
  String get wifiQRData {
    // Formato: WIFI:T:WPA;S:SSID;P:Password;H:false;;
    return 'WIFI:T:$authType;S:$ssid;P:$password;H:false;;';
  }

  // Verificar si el QR es para un usuario específico
  bool get isForSpecificUser => userId != null;

  // Obtener título para mostrar
  String get displayTitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (isForSpecificUser && userName != null) {
      return 'QR para $userName';
    }
    return 'QR - $ssid';
  }

  // Obtener subtítulo para mostrar
  String get displaySubtitle {
    if (isForSpecificUser && userName != null) {
      return 'Usuario: $userName';
    }
    return 'SSID: $ssid';
  }

  // Verificar si necesita notificación
  bool get needsNotification {
    return isNearExpiration || isNearUsageLimit;
  }

  @override
  String toString() {
    return 'QRModel(id: $id, ssid: $ssid, status: $status, usage: $usageCount/$maxUsage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
