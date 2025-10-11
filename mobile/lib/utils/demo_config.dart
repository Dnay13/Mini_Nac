/// Configuración para modo demo
/// Cambia este valor a false cuando el backend esté listo
class DemoConfig {
  // Cambiar a false cuando el backend esté funcionando
  static const bool isDemoMode = true;
  
  // Configuración de delays para simular latencia de red
  static const Duration networkDelay = Duration(milliseconds: 800);
  static const Duration authDelay = Duration(milliseconds: 1000);
  static const Duration quickDelay = Duration(milliseconds: 500);
  
  // Mensajes informativos
  static const String demoModeMessage = 'MODO DEMO - Backend deshabilitado';
  static const String backendNotReadyMessage = 'Backend no disponible - Usando datos simulados';
  
  // URLs del backend (para cuando esté listo)
  static const String backendUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  
  // Configuración de polling en modo demo
  static const bool enablePolling = false; // Deshabilitar polling en demo
  static const Duration pollingInterval = Duration(seconds: 30);
  
  // Configuración de notificaciones en demo
  static const bool enableNotifications = false; // Deshabilitar notificaciones en demo
  
  // Configuración de logs en demo
  static const bool enableLogging = true;
  static const String logPrefix = '[DEMO]';
  
  // Métodos de utilidad
  static bool get isBackendReady => !isDemoMode;
  static String get currentMode => isDemoMode ? 'DEMO' : 'PRODUCTION';
  
  // Simular delay de red
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    if (isDemoMode) {
      await Future.delayed(delay ?? networkDelay);
    }
  }
  
  // Log en modo demo
  static void log(String message) {
    if (enableLogging && isDemoMode) {
      print('$logPrefix $message');
    }
  }
  
  // Verificar si una funcionalidad está disponible
  static bool isFeatureAvailable(String feature) {
    if (isDemoMode) {
      // En modo demo, solo algunas funcionalidades están disponibles
      const availableFeatures = [
        'login',
        'dashboard',
        'users_list',
        'network_stats',
        'qr_generation',
        'sessions_view',
        'settings_view',
      ];
      return availableFeatures.contains(feature);
    }
    return true; // En producción, todas las funcionalidades están disponibles
  }
}
