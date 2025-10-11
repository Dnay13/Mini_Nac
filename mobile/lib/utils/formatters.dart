import 'package:intl/intl.dart';

class AppFormatters {
  // Formateador de fecha
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  // Formatear fecha
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Formatear fecha y hora
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Formatear solo hora
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Formatear mes y año
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  // Formatear fecha relativa (hace X tiempo)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'hace $years año${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months mes${months > 1 ? 'es' : ''}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora';
    }
  }

  // Formatear duración
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${days}d ${hours}h';
      }
      return '${days}d';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Formatear bytes a unidades legibles
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Formatear velocidad de red
  static String formatNetworkSpeed(double speedInMbps) {
    if (speedInMbps >= 1000) {
      return '${(speedInMbps / 1000).toStringAsFixed(1)} Gbps';
    } else {
      return '${speedInMbps.toStringAsFixed(1)} Mbps';
    }
  }

  // Formatear porcentaje
  static String formatPercentage(double percentage) {
    return '${(percentage * 100).toStringAsFixed(1)}%';
  }

  // Formatear número con separadores de miles
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Formatear número decimal
  static String formatDecimal(double number, {int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}');
    return formatter.format(number);
  }

  // Formatear moneda
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Formatear teléfono
  static String formatPhone(String phone) {
    // Remover todos los caracteres no numéricos
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10) {
      // Formato: (XXX) XXX-XXXX
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // Formato: +1 (XXX) XXX-XXXX
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    } else {
      // Devolver el número original si no coincide con formatos conocidos
      return phone;
    }
  }

  // Formatear MAC address
  static String formatMacAddress(String mac) {
    // Remover separadores existentes y convertir a mayúsculas
    final cleanMac = mac.replaceAll(RegExp(r'[:\-]'), '').toUpperCase();
    
    if (cleanMac.length == 12) {
      // Formato: XX:XX:XX:XX:XX:XX
      return '${cleanMac.substring(0, 2)}:${cleanMac.substring(2, 4)}:${cleanMac.substring(4, 6)}:${cleanMac.substring(6, 8)}:${cleanMac.substring(8, 10)}:${cleanMac.substring(10, 12)}';
    }
    
    return mac;
  }

  // Formatear IP address
  static String formatIPAddress(String ip) {
    // Validar que sea una IP válida
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    
    if (ipRegex.hasMatch(ip)) {
      return ip;
    }
    
    return ip; // Devolver original si no es válida
  }

  // Formatear SSID
  static String formatSSID(String ssid) {
    // Limpiar y capitalizar
    return ssid.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Formatear nombre de usuario
  static String formatUserName(String name) {
    // Capitalizar primera letra de cada palabra
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Formatear email
  static String formatEmail(String email) {
    return email.toLowerCase().trim();
  }

  // Formatear tiempo restante
  static String formatTimeRemaining(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    
    if (difference.isNegative) {
      return 'Expirado';
    }
    
    return formatDuration(difference);
  }

  // Formatear tiempo transcurrido desde inicio de sesión
  static String formatSessionDuration(DateTime startTime) {
    final now = DateTime.now();
    final difference = now.difference(startTime);
    
    return formatDuration(difference);
  }

  // Formatear límite de datos
  static String formatDataLimit(String limit) {
    if (limit.toLowerCase() == 'ilimitado') {
      return 'Ilimitado';
    }
    
    // Intentar parsear y formatear
    final regex = RegExp(r'^(\d+(\.\d+)?)\s*(MB|GB|TB)$');
    final match = regex.firstMatch(limit.toUpperCase());
    
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(3)!;
      return '${formatDecimal(value)} $unit';
    }
    
    return limit;
  }

  // Formatear límite de tiempo
  static String formatTimeLimit(String limit) {
    if (limit.toLowerCase() == 'ilimitado') {
      return 'Ilimitado';
    }
    
    // Intentar parsear y formatear
    final regex = RegExp(r'^(\d+(\.\d+)?)\s*(hora|horas|h)$');
    final match = regex.firstMatch(limit.toLowerCase());
    
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = value == 1 ? 'hora' : 'horas';
      return '${formatDecimal(value)} $unit';
    }
    
    return limit;
  }

  // Formatear límite de velocidad
  static String formatSpeedLimit(String limit) {
    if (limit.toLowerCase() == 'ilimitado') {
      return 'Ilimitado';
    }
    
    // Intentar parsear y formatear
    final regex = RegExp(r'^(\d+(\.\d+)?)\s*(Mbps|Gbps)$');
    final match = regex.firstMatch(limit);
    
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(3)!;
      return '${formatDecimal(value)} $unit';
    }
    
    return limit;
  }

  // Formatear estado de usuario
  static String formatUserStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'suspended':
        return 'Suspendido';
      case 'expired':
        return 'Expirado';
      case 'warning':
        return 'Alerta';
      default:
        return status;
    }
  }

  // Formatear estado de red
  static String formatNetworkStatus(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
        return 'Estable';
      case 'unstable':
        return 'Inestable';
      case 'down':
        return 'Caído';
      default:
        return status;
    }
  }

  // Formatear tipo de autenticación
  static String formatAuthType(String authType) {
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

  // Formatear mensaje de error
  static String formatErrorMessage(String error) {
    // Capitalizar primera letra
    if (error.isEmpty) return error;
    return error[0].toUpperCase() + error.substring(1);
  }

  // Formatear texto para mostrar en UI (truncar si es muy largo)
  static String formatDisplayText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // Formatear lista de elementos
  static String formatList(List<String> items, {String separator = ', '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} y ${items.last}';
    
    final lastItem = items.last;
    final otherItems = items.sublist(0, items.length - 1);
    return '${otherItems.join(separator)} y $lastItem';
  }
}
