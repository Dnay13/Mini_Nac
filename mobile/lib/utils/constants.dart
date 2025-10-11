class AppConstants {
  // URLs y endpoints
  static const String baseUrl = 'http://localhost:8000'; // Cambiar por la URL real del backend
  static const String apiVersion = '/api/v1';
  static const String baseApiUrl = '$baseUrl$apiVersion';
  
  // Endpoints específicos
  static const String loginEndpoint = '/auth/login';
  static const String usersEndpoint = '/users';
  static const String sessionsEndpoint = '/sessions';
  static const String qrEndpoint = '/qr';
  static const String networkEndpoint = '/network';
  static const String statsEndpoint = '/stats';
  static const String notificationsEndpoint = '/notifications';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  static const int sendTimeout = 30000; // 30 segundos
  
  // Polling intervals
  static const int networkPollingInterval = 10000; // 10 segundos
  static const int sessionsPollingInterval = 15000; // 15 segundos
  static const int statsPollingInterval = 60000; // 1 minuto
  
  // Límites y validaciones
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;
  
  // Límites de datos
  static const List<String> dataLimits = [
    '500 MB',
    '1 GB',
    '2 GB',
    '5 GB',
    '10 GB',
    'Ilimitado'
  ];
  
  // Límites de tiempo
  static const List<String> timeLimits = [
    '1 hora',
    '2 horas',
    '5 horas',
    '24 horas',
    'Ilimitado'
  ];
  
  // Velocidades de red
  static const List<String> speedLimits = [
    '10 Mbps',
    '25 Mbps',
    '50 Mbps',
    '100 Mbps',
    'Ilimitado'
  ];
  
  // Tipos de autenticación
  static const List<String> authTypes = [
    'WPA2',
    'WPA3',
    'WPA2/WPA3'
  ];
  
  // Estados de usuario
  static const String userStatusActive = 'active';
  static const String userStatusSuspended = 'suspended';
  static const String userStatusExpired = 'expired';
  static const String userStatusWarning = 'warning';
  
  // Estados de red
  static const String networkStatusStable = 'stable';
  static const String networkStatusUnstable = 'unstable';
  static const String networkStatusDown = 'down';
  
  // Configuración de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
  
  static const double defaultElevation = 2.0;
  static const double highElevation = 8.0;
  
  // Animaciones
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Splash screen
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Debounce para búsquedas
  static const Duration searchDebounce = Duration(milliseconds: 300);
  
  // Paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Archivos y assets
  static const String logoPath = 'assets/images/logo.png';
  static const String splashAnimationPath = 'assets/animations/splash.json';
  static const String emptyStatePath = 'assets/animations/empty.json';
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  
  // Configuración de QR
  static const int qrCodeSize = 200;
  static const int qrCodeVersion = 5;
  static const int qrCodeErrorCorrectionLevel = 3;
  
  // Configuración de gráficos
  static const int chartAnimationDuration = 1500;
  static const int chartDataPoints = 15; // Puntos de datos para gráficos
  
  // Notificaciones
  static const String notificationChannelId = 'mini_nac_notifications';
  static const String notificationChannelName = 'Mini NAC Notifications';
  static const String notificationChannelDescription = 'Notificaciones de la aplicación Mini NAC';
  
  // Configuración de biometría
  static const String biometricLocalizedReason = 'Autentícate para acceder a Mini NAC';
  static const String biometricCancelButton = 'Cancelar';
  
  // Configuración de red
  static const double maxNetworkSpeed = 100.0; // Mbps
  static const double networkOptimalThreshold = 50.0; // Mbps
  static const double networkModerateThreshold = 80.0; // Mbps
  
  // Configuración de alertas
  static const double dataUsageWarningThreshold = 0.8; // 80%
  static const double timeUsageWarningThreshold = 0.8; // 80%
  static const int warningDaysBeforeExpiry = 3; // días
  
  // Configuración de cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50; // MB
  
  // Configuración de logs
  static const bool enableLogging = true;
  static const String logTag = 'MiniNAC';
  
  // Configuración de desarrollo
  static const bool isDebugMode = true;
  static const bool enablePerformanceOverlay = false;
  static const bool enableDebugBanner = false;
  
  // Mensajes de error comunes
  static const String networkErrorMessage = 'Error de conexión. Verifica tu internet.';
  static const String serverErrorMessage = 'Error del servidor. Intenta más tarde.';
  static const String timeoutErrorMessage = 'Tiempo de espera agotado.';
  static const String unknownErrorMessage = 'Error desconocido.';
  
  // Mensajes de éxito
  static const String loginSuccessMessage = 'Inicio de sesión exitoso';
  static const String userCreatedMessage = 'Usuario creado exitosamente';
  static const String userUpdatedMessage = 'Usuario actualizado exitosamente';
  static const String userDeletedMessage = 'Usuario eliminado exitosamente';
  static const String qrGeneratedMessage = 'Código QR generado exitosamente';
  
  // Configuración de validación de email
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // Configuración de validación de teléfono
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  
  // Configuración de MAC address
  static const String macAddressRegex = r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$';
}
