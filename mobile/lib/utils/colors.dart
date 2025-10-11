import 'package:flutter/material.dart';

class AppColors {
  // Paleta de colores principal
  static const Color primary = Color(0xFF5B5FEF);
  static const Color secondary = Color(0xFFE4E6F6);
  static const Color background = Color(0xFFF9FAFB);
  static const Color accent = Color(0xFFFFB800);
  
  // Estados
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  // Bordes y separadores
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  
  // Fondos
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  
  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B5FEF), Color(0xFF6366F1)],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );
  
  // Estados de usuario
  static const Color userActive = success;
  static const Color userSuspended = warning;
  static const Color userExpired = error;
  static const Color userWarning = Color(0xFFF59E0B);
  
  // Velocímetro de red
  static const Color networkOptimal = success;
  static const Color networkModerate = warning;
  static const Color networkSaturated = error;
  
  // Sombras
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  // Método para obtener color según porcentaje
  static Color getPercentageColor(double percentage) {
    if (percentage < 0.7) return success;
    if (percentage < 0.9) return warning;
    return error;
  }
  
  // Método para obtener color de estado de usuario
  static Color getUserStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'activo':
        return userActive;
      case 'suspended':
      case 'suspendido':
        return userSuspended;
      case 'expired':
      case 'expirado':
        return userExpired;
      case 'warning':
      case 'alerta':
        return userWarning;
      default:
        return textSecondary;
    }
  }
}
