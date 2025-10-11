class SessionModel {
  final int id;
  final int userId;
  final String userName;
  final String ssid;
  final String? macAddress;
  final String? ipAddress;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int dataUsageMB;
  final int durationMinutes;
  final String? disconnectReason;
  final Map<String, dynamic>? metadata;

  SessionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.ssid,
    this.macAddress,
    this.ipAddress,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.dataUsageMB,
    required this.durationMinutes,
    this.disconnectReason,
    this.metadata,
  });

  // Crear desde JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      ssid: json['ssid'] as String,
      macAddress: json['mac_address'] as String?,
      ipAddress: json['ip_address'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String) 
          : null,
      status: json['status'] as String,
      dataUsageMB: json['data_usage_mb'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      disconnectReason: json['disconnect_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'ssid': ssid,
      'mac_address': macAddress,
      'ip_address': ipAddress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'data_usage_mb': dataUsageMB,
      'duration_minutes': durationMinutes,
      'disconnect_reason': disconnectReason,
      'metadata': metadata,
    };
  }

  // Crear copia con cambios
  SessionModel copyWith({
    int? id,
    int? userId,
    String? userName,
    String? ssid,
    String? macAddress,
    String? ipAddress,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? dataUsageMB,
    int? durationMinutes,
    String? disconnectReason,
    Map<String, dynamic>? metadata,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      ssid: ssid ?? this.ssid,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      dataUsageMB: dataUsageMB ?? this.dataUsageMB,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      disconnectReason: disconnectReason ?? this.disconnectReason,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters para cálculos
  bool get isActive => status.toLowerCase() == 'active';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isDisconnected => status.toLowerCase() == 'disconnected';
  bool get isExpired => status.toLowerCase() == 'expired';

  // Duración actual si está activa
  int get currentDurationMinutes {
    if (isActive) {
      final now = DateTime.now();
      return now.difference(startTime).inMinutes;
    }
    return durationMinutes;
  }

  // Tiempo transcurrido desde el inicio
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Tiempo restante estimado (si hay límite)
  Duration? get estimatedRemainingTime {
    // Esto se calcularía basado en los límites del usuario
    // Por ahora retornamos null
    return null;
  }

  // Velocidad promedio de descarga
  double get averageDownloadSpeed {
    if (currentDurationMinutes <= 0) return 0.0;
    // Convertir MB a Mbps (1 MB = 8 Mbps)
    return (dataUsageMB * 8) / currentDurationMinutes;
  }

  // Verificar si la sesión es reciente (últimas 24 horas)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(startTime).inHours <= 24;
  }

  // Verificar si la sesión es de hoy
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  // Obtener día de la semana
  String get dayOfWeek {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[startTime.weekday - 1];
  }

  // Obtener hora de inicio formateada
  String get startTimeFormatted {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  // Obtener hora de fin formateada
  String get endTimeFormatted {
    if (endTime == null) return 'En curso';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  // Obtener duración formateada
  String get durationFormatted {
    final duration = Duration(minutes: currentDurationMinutes);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  // Obtener uso de datos formateado
  String get dataUsageFormatted {
    if (dataUsageMB < 1024) {
      return '${dataUsageMB} MB';
    } else {
      return '${(dataUsageMB / 1024).toStringAsFixed(1)} GB';
    }
  }

  // Obtener velocidad formateada
  String get speedFormatted {
    final speed = averageDownloadSpeed;
    if (speed < 1) {
      return '${(speed * 1000).toStringAsFixed(0)} Kbps';
    } else {
      return '${speed.toStringAsFixed(1)} Mbps';
    }
  }

  // Obtener color según el estado
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'green';
      case 'completed':
        return 'blue';
      case 'disconnected':
        return 'orange';
      case 'expired':
        return 'red';
      default:
        return 'gray';
    }
  }

  // Obtener ícono según el estado
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'active':
        return 'wifi';
      case 'completed':
        return 'check_circle';
      case 'disconnected':
        return 'wifi_off';
      case 'expired':
        return 'schedule';
      default:
        return 'help';
    }
  }

  // Verificar si la sesión fue exitosa
  bool get wasSuccessful {
    return isCompleted || (isActive && currentDurationMinutes > 5);
  }

  // Obtener razón de desconexión formateada
  String get disconnectReasonFormatted {
    if (disconnectReason == null) return '';
    
    switch (disconnectReason!.toLowerCase()) {
      case 'user_disconnect':
        return 'Desconexión manual';
      case 'time_limit':
        return 'Límite de tiempo alcanzado';
      case 'data_limit':
        return 'Límite de datos alcanzado';
      case 'expiration':
        return 'Cuenta expirada';
      case 'admin_disconnect':
        return 'Desconectado por administrador';
      case 'network_error':
        return 'Error de red';
      case 'device_offline':
        return 'Dispositivo desconectado';
      default:
        return disconnectReason!;
    }
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, user: $userName, status: $status, duration: ${durationFormatted})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
