import 'constants.dart';

class AppValidators {
  // Validación de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    if (value.length > AppConstants.maxEmailLength) {
      return 'El email es demasiado largo';
    }
    
    return null;
  }

  // Validación de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña es demasiado larga';
    }
    
    return null;
  }

  // Validación de nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < AppConstants.minNameLength) {
      return 'El nombre debe tener al menos ${AppConstants.minNameLength} caracteres';
    }
    
    if (value.length > AppConstants.maxNameLength) {
      return 'El nombre es demasiado largo';
    }
    
    // Validar que solo contenga letras, espacios y algunos caracteres especiales
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'-]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre contiene caracteres no válidos';
    }
    
    return null;
  }

  // Validación de teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Teléfono es opcional
    }
    
    final phoneRegex = RegExp(AppConstants.phoneRegex);
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }
    
    if (value.length > AppConstants.maxPhoneLength) {
      return 'El teléfono es demasiado largo';
    }
    
    return null;
  }

  // Validación de SSID
  static String? validateSSID(String? value) {
    if (value == null || value.isEmpty) {
      return 'El SSID es requerido';
    }
    
    if (value.length < 3) {
      return 'El SSID debe tener al menos 3 caracteres';
    }
    
    if (value.length > 32) {
      return 'El SSID no puede tener más de 32 caracteres';
    }
    
    // Validar que no contenga caracteres especiales problemáticos
    final ssidRegex = RegExp(r'^[a-zA-Z0-9\-_\s]+$');
    if (!ssidRegex.hasMatch(value)) {
      return 'El SSID contiene caracteres no válidos';
    }
    
    return null;
  }

  // Validación de MAC address
  static String? validateMacAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // MAC address es opcional
    }
    
    final macRegex = RegExp(AppConstants.macAddressRegex);
    if (!macRegex.hasMatch(value)) {
      return 'Ingresa una dirección MAC válida (formato: XX:XX:XX:XX:XX:XX)';
    }
    
    return null;
  }

  // Validación de IP address
  static String? validateIPAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // IP es opcional
    }
    
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    if (!ipRegex.hasMatch(value)) {
      return 'Ingresa una dirección IP válida';
    }
    
    return null;
  }

  // Validación de tiempo (en horas)
  static String? validateTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'El límite de tiempo es requerido';
    }
    
    if (value.toLowerCase() == 'ilimitado') {
      return null;
    }
    
    final timeRegex = RegExp(r'^(\d+(\.\d+)?)\s*(hora|horas|h)$');
    if (!timeRegex.hasMatch(value.toLowerCase())) {
      return 'Formato de tiempo inválido (ej: 2 horas)';
    }
    
    return null;
  }

  // Validación de límite de datos
  static String? validateDataLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'El límite de datos es requerido';
    }
    
    if (value.toLowerCase() == 'ilimitado') {
      return null;
    }
    
    final dataRegex = RegExp(r'^(\d+(\.\d+)?)\s*(MB|GB|TB)$');
    if (!dataRegex.hasMatch(value.toUpperCase())) {
      return 'Formato de datos inválido (ej: 1 GB)';
    }
    
    return null;
  }

  // Validación de velocidad de red
  static String? validateSpeedLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'El límite de velocidad es requerido';
    }
    
    if (value.toLowerCase() == 'ilimitado') {
      return null;
    }
    
    final speedRegex = RegExp(r'^(\d+(\.\d+)?)\s*(Mbps|Gbps)$');
    if (!speedRegex.hasMatch(value)) {
      return 'Formato de velocidad inválido (ej: 25 Mbps)';
    }
    
    return null;
  }

  // Validación de fecha de expiración
  static String? validateExpirationDate(DateTime? value) {
    if (value == null) {
      return null; // Fecha de expiración es opcional
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'La fecha de expiración no puede ser anterior a hoy';
    }
    
    // Limitar a máximo 1 año en el futuro
    final maxDate = now.add(const Duration(days: 365));
    if (value.isAfter(maxDate)) {
      return 'La fecha de expiración no puede ser mayor a 1 año';
    }
    
    return null;
  }

  // Validación de confirmación de contraseña
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // Validación de código de confirmación para eliminación
  static String? validateConfirmationCode(String? value, String? expectedValue) {
    if (value == null || value.isEmpty) {
      return 'Ingresa el código de confirmación';
    }
    
    if (value.toLowerCase() != expectedValue?.toLowerCase()) {
      return 'El código de confirmación no coincide';
    }
    
    return null;
  }

  // Validación de búsqueda
  static String? validateSearch(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Búsqueda vacía es válida
    }
    
    if (value.length < 2) {
      return 'La búsqueda debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  // Validación de comentarios/notas
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Comentarios son opcionales
    }
    
    if (value.length > 500) {
      return 'El comentario no puede tener más de 500 caracteres';
    }
    
    return null;
  }

  // Validación de URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL es opcional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }
    
    return null;
  }

  // Validación de puerto
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Puerto es opcional
    }
    
    final port = int.tryParse(value);
    if (port == null) {
      return 'El puerto debe ser un número';
    }
    
    if (port < 1 || port > 65535) {
      return 'El puerto debe estar entre 1 y 65535';
    }
    
    return null;
  }

  // Validación de porcentaje
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Porcentaje es opcional
    }
    
    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'El porcentaje debe ser un número';
    }
    
    if (percentage < 0 || percentage > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }
    
    return null;
  }

  // Validación de número entero positivo
  static String? validatePositiveInteger(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Número es opcional
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Debe ser un número entero';
    }
    
    if (number < 0) {
      return 'El número debe ser positivo';
    }
    
    return null;
  }

  // Validación de número decimal positivo
  static String? validatePositiveDecimal(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Número es opcional
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Debe ser un número válido';
    }
    
    if (number < 0) {
      return 'El número debe ser positivo';
    }
    
    return null;
  }
}
