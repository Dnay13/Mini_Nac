class NetworkStatsModel {
  final String status;
  final double downloadSpeed;
  final double uploadSpeed;
  final double latency;
  final int totalUsers;
  final int activeUsers;
  final int totalDataUsageMB;
  final double bandwidthUtilization;
  final DateTime lastUpdated;
  final List<NetworkDataPoint> speedHistory;
  final Map<String, dynamic>? metadata;

  NetworkStatsModel({
    required this.status,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalDataUsageMB,
    required this.bandwidthUtilization,
    required this.lastUpdated,
    required this.speedHistory,
    this.metadata,
  });

  // Crear desde JSON
  factory NetworkStatsModel.fromJson(Map<String, dynamic> json) {
    return NetworkStatsModel(
      status: json['status'] as String,
      downloadSpeed: (json['download_speed'] as num).toDouble(),
      uploadSpeed: (json['upload_speed'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      totalUsers: json['total_users'] as int,
      activeUsers: json['active_users'] as int,
      totalDataUsageMB: json['total_data_usage_mb'] as int,
      bandwidthUtilization: (json['bandwidth_utilization'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      speedHistory: (json['speed_history'] as List<dynamic>?)
          ?.map((item) => NetworkDataPoint.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'latency': latency,
      'total_users': totalUsers,
      'active_users': activeUsers,
      'total_data_usage_mb': totalDataUsageMB,
      'bandwidth_utilization': bandwidthUtilization,
      'last_updated': lastUpdated.toIso8601String(),
      'speed_history': speedHistory.map((point) => point.toJson()).toList(),
      'metadata': metadata,
    };
  }

  // Crear copia con cambios
  NetworkStatsModel copyWith({
    String? status,
    double? downloadSpeed,
    double? uploadSpeed,
    double? latency,
    int? totalUsers,
    int? activeUsers,
    int? totalDataUsageMB,
    double? bandwidthUtilization,
    DateTime? lastUpdated,
    List<NetworkDataPoint>? speedHistory,
    Map<String, dynamic>? metadata,
  }) {
    return NetworkStatsModel(
      status: status ?? this.status,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      latency: latency ?? this.latency,
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalDataUsageMB: totalDataUsageMB ?? this.totalDataUsageMB,
      bandwidthUtilization: bandwidthUtilization ?? this.bandwidthUtilization,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      speedHistory: speedHistory ?? this.speedHistory,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters para cálculos
  bool get isStable => status.toLowerCase() == 'stable';
  bool get isUnstable => status.toLowerCase() == 'unstable';
  bool get isDown => status.toLowerCase() == 'down';

  // Porcentaje de usuarios activos
  double get activeUsersPercentage {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers).clamp(0.0, 1.0);
  }

  // Velocidad total (download + upload)
  double get totalSpeed => downloadSpeed + uploadSpeed;

  // Velocidad promedio
  double get averageSpeed => (downloadSpeed + uploadSpeed) / 2;

  // Estado de la red basado en velocidad
  String get speedStatus {
    if (downloadSpeed >= 50) return 'optimal';
    if (downloadSpeed >= 25) return 'good';
    if (downloadSpeed >= 10) return 'moderate';
    return 'poor';
  }

  // Estado de la red basado en latencia
  String get latencyStatus {
    if (latency <= 50) return 'excellent';
    if (latency <= 100) return 'good';
    if (latency <= 200) return 'moderate';
    return 'poor';
  }

  // Estado general de la red
  String get overallStatus {
    if (isDown) return 'down';
    if (isUnstable) return 'unstable';
    if (speedStatus == 'poor' || latencyStatus == 'poor') return 'poor';
    if (speedStatus == 'moderate' || latencyStatus == 'moderate') return 'moderate';
    return 'good';
  }

  // Obtener color según el estado
  String get statusColor {
    switch (overallStatus) {
      case 'down':
        return 'red';
      case 'poor':
        return 'red';
      case 'moderate':
        return 'orange';
      case 'good':
        return 'green';
      case 'excellent':
        return 'green';
      default:
        return 'gray';
    }
  }

  // Formatear velocidad de descarga
  String get downloadSpeedFormatted {
    if (downloadSpeed >= 1000) {
      return '${(downloadSpeed / 1000).toStringAsFixed(1)} Gbps';
    }
    return '${downloadSpeed.toStringAsFixed(1)} Mbps';
  }

  // Formatear velocidad de subida
  String get uploadSpeedFormatted {
    if (uploadSpeed >= 1000) {
      return '${(uploadSpeed / 1000).toStringAsFixed(1)} Gbps';
    }
    return '${uploadSpeed.toStringAsFixed(1)} Mbps';
  }

  // Formatear latencia
  String get latencyFormatted {
    if (latency < 1) {
      return '${(latency * 1000).toStringAsFixed(0)} μs';
    }
    return '${latency.toStringAsFixed(0)} ms';
  }

  // Formatear uso total de datos
  String get totalDataUsageFormatted {
    if (totalDataUsageMB < 1024) {
      return '${totalDataUsageMB} MB';
    } else if (totalDataUsageMB < 1024 * 1024) {
      return '${(totalDataUsageMB / 1024).toStringAsFixed(1)} GB';
    } else {
      return '${(totalDataUsageMB / (1024 * 1024)).toStringAsFixed(1)} TB';
    }
  }

  // Formatear utilización de ancho de banda
  String get bandwidthUtilizationFormatted {
    return '${(bandwidthUtilization * 100).toStringAsFixed(1)}%';
  }

  // Formatear porcentaje de usuarios activos
  String get activeUsersPercentageFormatted {
    return '${(activeUsersPercentage * 100).toStringAsFixed(1)}%';
  }

  // Obtener tiempo desde última actualización
  Duration get timeSinceLastUpdate {
    return DateTime.now().difference(lastUpdated);
  }

  // Verificar si los datos están actualizados (menos de 5 minutos)
  bool get isDataFresh {
    return timeSinceLastUpdate.inMinutes < 5;
  }

  // Obtener velocidad máxima histórica
  double get maxHistoricalSpeed {
    if (speedHistory.isEmpty) return 0.0;
    return speedHistory.map((point) => point.downloadSpeed).reduce((a, b) => a > b ? a : b);
  }

  // Obtener velocidad mínima histórica
  double get minHistoricalSpeed {
    if (speedHistory.isEmpty) return 0.0;
    return speedHistory.map((point) => point.downloadSpeed).reduce((a, b) => a < b ? a : b);
  }

  // Obtener velocidad promedio histórica
  double get averageHistoricalSpeed {
    if (speedHistory.isEmpty) return 0.0;
    final total = speedHistory.fold<double>(0.0, (sum, point) => sum + point.downloadSpeed);
    return total / speedHistory.length;
  }

  // Obtener tendencia de velocidad (últimos 5 puntos)
  String get speedTrend {
    if (speedHistory.length < 5) return 'stable';
    
    final recent = speedHistory.length >= 5 
        ? speedHistory.sublist(speedHistory.length - 5)
        : speedHistory;
    final first = recent.first.downloadSpeed;
    final last = recent.last.downloadSpeed;
    
    final difference = last - first;
    final threshold = 2.0; // Mbps
    
    if (difference > threshold) return 'increasing';
    if (difference < -threshold) return 'decreasing';
    return 'stable';
  }

  // Verificar si hay problemas de red
  bool get hasNetworkIssues {
    return isDown || 
           isUnstable || 
           downloadSpeed < 5.0 || 
           latency > 500 ||
           bandwidthUtilization > 0.9;
  }

  // Obtener recomendaciones basadas en el estado
  List<String> get recommendations {
    final recommendations = <String>[];
    
    if (isDown) {
      recommendations.add('Verificar conexión a internet');
      recommendations.add('Reiniciar router/modem');
    } else if (isUnstable) {
      recommendations.add('Verificar interferencias');
      recommendations.add('Cambiar canal Wi-Fi');
    }
    
    if (downloadSpeed < 10) {
      recommendations.add('Considerar actualizar plan de internet');
    }
    
    if (latency > 200) {
      recommendations.add('Verificar calidad de conexión');
      recommendations.add('Optimizar configuración de red');
    }
    
    if (bandwidthUtilization > 0.8) {
      recommendations.add('Reducir número de usuarios activos');
      recommendations.add('Implementar límites de ancho de banda');
    }
    
    if (activeUsersPercentage > 0.8) {
      recommendations.add('Considerar expandir capacidad de red');
    }
    
    return recommendations;
  }

  @override
  String toString() {
    return 'NetworkStatsModel(status: $status, download: ${downloadSpeedFormatted}, upload: ${uploadSpeedFormatted}, users: $activeUsers/$totalUsers)';
  }
}

// Modelo para puntos de datos históricos
class NetworkDataPoint {
  final DateTime timestamp;
  final double downloadSpeed;
  final double uploadSpeed;
  final double latency;
  final int activeUsers;

  NetworkDataPoint({
    required this.timestamp,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.activeUsers,
  });

  factory NetworkDataPoint.fromJson(Map<String, dynamic> json) {
    return NetworkDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      downloadSpeed: (json['download_speed'] as num).toDouble(),
      uploadSpeed: (json['upload_speed'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      activeUsers: json['active_users'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'latency': latency,
      'active_users': activeUsers,
    };
  }

  @override
  String toString() {
    return 'NetworkDataPoint(timestamp: $timestamp, download: $downloadSpeed, upload: $uploadSpeed)';
  }
}
