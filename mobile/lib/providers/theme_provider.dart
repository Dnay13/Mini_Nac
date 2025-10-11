import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  
  // Verificar si el tema es automático
  bool get isSystemTheme => _themeMode == ThemeMode.system;
  
  // Verificar si el tema es claro
  bool get isLightTheme => _themeMode == ThemeMode.light;
  
  // Verificar si el tema es oscuro
  bool get isDarkTheme => _themeMode == ThemeMode.dark;

  // Inicializar el provider
  Future<void> initialize() async {
    await _loadThemeFromPreferences();
  }

  // Cargar tema desde SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      switch (themeIndex) {
        case 0:
          _themeMode = ThemeMode.system;
          break;
        case 1:
          _themeMode = ThemeMode.light;
          _isDarkMode = false;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          _isDarkMode = true;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      
      notifyListeners();
    } catch (e) {
      // Si hay error, usar tema del sistema por defecto
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  // Guardar tema en SharedPreferences
  Future<void> _saveThemeToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex;
      
      switch (_themeMode) {
        case ThemeMode.system:
          themeIndex = 0;
          break;
        case ThemeMode.light:
          themeIndex = 1;
          break;
        case ThemeMode.dark:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      // Ignorar errores de guardado
    }
  }

  // Establecer tema del sistema
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;
    await _saveThemeToPreferences();
    notifyListeners();
  }

  // Establecer tema claro
  Future<void> setLightTheme() async {
    _themeMode = ThemeMode.light;
    _isDarkMode = false;
    await _saveThemeToPreferences();
    notifyListeners();
  }

  // Establecer tema oscuro
  Future<void> setDarkTheme() async {
    _themeMode = ThemeMode.dark;
    _isDarkMode = true;
    await _saveThemeToPreferences();
    notifyListeners();
  }

  // Alternar entre tema claro y oscuro
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkTheme();
    } else {
      await setLightTheme();
    }
  }

  // Establecer tema basado en el modo del sistema
  void updateSystemTheme(bool isDark) {
    if (_themeMode == ThemeMode.system) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }

  // Obtener el tema actual efectivo
  bool get effectiveIsDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return _isDarkMode;
    }
  }

  // Obtener el nombre del tema actual
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  // Obtener el ícono del tema actual
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Obtener la descripción del tema actual
  String get currentThemeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Tema claro siempre activo';
      case ThemeMode.dark:
        return 'Tema oscuro siempre activo';
      case ThemeMode.system:
        return 'Sigue la configuración del sistema';
    }
  }

  // Verificar si el tema está disponible
  bool isThemeAvailable(ThemeMode mode) {
    // Por ahora todos los temas están disponibles
    // En el futuro se podría verificar la versión de Android/iOS
    return true;
  }

  // Obtener lista de temas disponibles
  List<ThemeOption> get availableThemes {
    return [
      ThemeOption(
        mode: ThemeMode.system,
        name: 'Sistema',
        description: 'Sigue la configuración del sistema',
        icon: Icons.brightness_auto,
      ),
      ThemeOption(
        mode: ThemeMode.light,
        name: 'Claro',
        description: 'Tema claro siempre activo',
        icon: Icons.light_mode,
      ),
      ThemeOption(
        mode: ThemeMode.dark,
        name: 'Oscuro',
        description: 'Tema oscuro siempre activo',
        icon: Icons.dark_mode,
      ),
    ];
  }

  // Obtener el tema seleccionado
  ThemeOption get selectedTheme {
    return availableThemes.firstWhere(
      (theme) => theme.mode == _themeMode,
      orElse: () => availableThemes.first,
    );
  }

  // Establecer tema desde opción
  Future<void> setThemeFromOption(ThemeOption option) async {
    switch (option.mode) {
      case ThemeMode.system:
        await setSystemTheme();
        break;
      case ThemeMode.light:
        await setLightTheme();
        break;
      case ThemeMode.dark:
        await setDarkTheme();
        break;
    }
  }

  // Verificar si el tema necesita reinicio
  bool get needsRestart {
    // Por ahora no se necesita reinicio
    // En el futuro se podría verificar si hay cambios que requieren reinicio
    return false;
  }

  // Obtener configuración de tema para Material 3
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5FEF),
        brightness: Brightness.light,
      ),
      fontFamily: 'Poppins',
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5FEF),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Poppins',
    );
  }

  // Obtener el tema actual basado en el modo
  ThemeData get currentTheme {
    if (effectiveIsDarkMode) {
      return darkTheme;
    } else {
      return lightTheme;
    }
  }

  // Obtener colores del tema actual
  ColorScheme get currentColorScheme {
    return currentTheme.colorScheme;
  }

  // Obtener color primario
  Color get primaryColor {
    return currentColorScheme.primary;
  }

  // Obtener color de superficie
  Color get surfaceColor {
    return currentColorScheme.surface;
  }

  // Obtener color de fondo
  Color get backgroundColor {
    return currentColorScheme.background;
  }

  // Obtener color de texto primario
  Color get textPrimaryColor {
    return currentColorScheme.onSurface;
  }

  // Obtener color de texto secundario
  Color get textSecondaryColor {
    return currentColorScheme.onSurface.withOpacity(0.6);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Clase para representar una opción de tema
class ThemeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;

  ThemeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeOption && other.mode == mode;
  }

  @override
  int get hashCode => mode.hashCode;

  @override
  String toString() {
    return 'ThemeOption(mode: $mode, name: $name)';
  }
}
