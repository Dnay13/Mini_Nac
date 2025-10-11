class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final String priority;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionText;
  final int? userId;
  final String? userName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.readAt,
    required this.isRead,
    this.data,
    this.actionUrl,
    this.actionText,
    this.userId,
    this.userName,
  });

  // Crear desde JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['action_url'] as String?,
      actionText: json['action_text'] as String?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'action_url': actionUrl,
      'action_text': actionText,
      'user_id': userId,
      'user_name': userName,
    };
  }

  // Crear copia con cambios
  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
    int? userId,
    String? userName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }

  // Getters para cálculos
  bool get isUnread => !isRead;
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;
  bool get isForSpecificUser => userId != null;

  // Tipos de notificación
  bool get isUserNotification => type.toLowerCase() == 'user';
  bool get isSystemNotification => type.toLowerCase() == 'system';
  bool get isNetworkNotification => type.toLowerCase() == 'network';
  bool get isSecurityNotification => type.toLowerCase() == 'security';
  bool get isMaintenanceNotification => type.toLowerCase() == 'maintenance';

  // Prioridades
  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isMediumPriority => priority.toLowerCase() == 'medium';
  bool get isLowPriority => priority.toLowerCase() == 'low';
  bool get isCriticalPriority => priority.toLowerCase() == 'critical';

  // Obtener color según el tipo
  String get typeColor {
    switch (type.toLowerCase()) {
      case 'user':
        return 'blue';
      case 'system':
        return 'gray';
      case 'network':
        return 'green';
      case 'security':
        return 'red';
      case 'maintenance':
        return 'orange';
      default:
        return 'blue';
    }
  }

  // Obtener color según la prioridad
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'green';
      default:
        return 'gray';
    }
  }

  // Obtener ícono según el tipo
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'user':
        return 'person';
      case 'system':
        return 'settings';
      case 'network':
        return 'wifi';
      case 'security':
        return 'security';
      case 'maintenance':
        return 'build';
      default:
        return 'notifications';
    }
  }

  // Obtener ícono según la prioridad
  String get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'error';
      case 'high':
        return 'warning';
      case 'medium':
        return 'info';
      case 'low':
        return 'check_circle';
      default:
        return 'notifications';
    }
  }

  // Formatear tiempo relativo
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora';
    }
  }

  // Formatear fecha completa
  String get createdAtFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Verificar si es reciente (últimas 24 horas)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours <= 24;
  }

  // Verificar si es de hoy
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  // Obtener tipo formateado
  String get typeFormatted {
    switch (type.toLowerCase()) {
      case 'user':
        return 'Usuario';
      case 'system':
        return 'Sistema';
      case 'network':
        return 'Red';
      case 'security':
        return 'Seguridad';
      case 'maintenance':
        return 'Mantenimiento';
      default:
        return type;
    }
  }

  // Obtener prioridad formateada
  String get priorityFormatted {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'Crítica';
      case 'high':
        return 'Alta';
      case 'medium':
        return 'Media';
      case 'low':
        return 'Baja';
      default:
        return priority;
    }
  }

  // Obtener título para mostrar
  String get displayTitle {
    if (isForSpecificUser && userName != null) {
      return '$title - $userName';
    }
    return title;
  }

  // Obtener subtítulo para mostrar
  String get displaySubtitle {
    final parts = <String>[];
    
    if (isForSpecificUser && userName != null) {
      parts.add('Usuario: $userName');
    }
    
    parts.add(timeAgo);
    
    return parts.join(' • ');
  }

  // Verificar si necesita acción urgente
  bool get needsUrgentAction {
    return isCriticalPriority && isUnread;
  }

  // Obtener datos específicos del tipo de notificación
  T? getData<T>(String key) {
    return data?[key] as T?;
  }

  // Verificar si tiene datos específicos
  bool hasData(String key) {
    return data?.containsKey(key) ?? false;
  }

  // Crear notificación como leída
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  // Crear notificación como no leída
  NotificationModel markAsUnread() {
    return copyWith(
      isRead: false,
      readAt: null,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, priority: $priority, read: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Tipos de notificación predefinidos
class NotificationTypes {
  static const String user = 'user';
  static const String system = 'system';
  static const String network = 'network';
  static const String security = 'security';
  static const String maintenance = 'maintenance';
}

// Prioridades predefinidas
class NotificationPriorities {
  static const String critical = 'critical';
  static const String high = 'high';
  static const String medium = 'medium';
  static const String low = 'low';
}

// Factory para crear notificaciones comunes
class NotificationFactory {
  // Notificación de usuario conectado
  static NotificationModel userConnected({
    required int userId,
    required String userName,
    required String ssid,
  }) {
    return NotificationModel(
      id: 0, // Se asignará en el backend
      title: 'Usuario conectado',
      message: '$userName se conectó a la red $ssid',
      type: NotificationTypes.user,
      priority: NotificationPriorities.medium,
      createdAt: DateTime.now(),
      isRead: false,
      userId: userId,
      userName: userName,
      data: {
        'ssid': ssid,
        'action': 'view_user',
      },
      actionText: 'Ver usuario',
    );
  }

  // Notificación de usuario desconectado
  static NotificationModel userDisconnected({
    required int userId,
    required String userName,
    required String reason,
  }) {
    return NotificationModel(
      id: 0,
      title: 'Usuario desconectado',
      message: '$userName se desconectó: $reason',
      type: NotificationTypes.user,
      priority: NotificationPriorities.low,
      createdAt: DateTime.now(),
      isRead: false,
      userId: userId,
      userName: userName,
      data: {
        'reason': reason,
        'action': 'view_user',
      },
      actionText: 'Ver usuario',
    );
  }

  // Notificación de límite alcanzado
  static NotificationModel limitReached({
    required int userId,
    required String userName,
    required String limitType,
  }) {
    return NotificationModel(
      id: 0,
      title: 'Límite alcanzado',
      message: '$userName alcanzó el límite de $limitType',
      type: NotificationTypes.user,
      priority: NotificationPriorities.high,
      createdAt: DateTime.now(),
      isRead: false,
      userId: userId,
      userName: userName,
      data: {
        'limit_type': limitType,
        'action': 'view_user',
      },
      actionText: 'Ver usuario',
    );
  }

  // Notificación de problema de red
  static NotificationModel networkIssue({
    required String issue,
    required String description,
  }) {
    return NotificationModel(
      id: 0,
      title: 'Problema de red',
      message: '$issue: $description',
      type: NotificationTypes.network,
      priority: NotificationPriorities.high,
      createdAt: DateTime.now(),
      isRead: false,
      data: {
        'issue': issue,
        'action': 'view_network',
      },
      actionText: 'Ver estado de red',
    );
  }

  // Notificación de mantenimiento
  static NotificationModel maintenance({
    required String title,
    required String description,
    DateTime? scheduledTime,
  }) {
    return NotificationModel(
      id: 0,
      title: title,
      message: description,
      type: NotificationTypes.maintenance,
      priority: NotificationPriorities.medium,
      createdAt: DateTime.now(),
      isRead: false,
      data: {
        'scheduled_time': scheduledTime?.toIso8601String(),
        'action': 'view_maintenance',
      },
      actionText: 'Ver detalles',
    );
  }
}
