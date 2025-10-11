import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Configuración base de la fuente
  static TextStyle _baseTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Títulos grandes (H1)
  static TextStyle get h1 => _baseTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  static TextStyle get h1White => _baseTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  // Títulos de sección (H2)
  static TextStyle get h2 => _baseTextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h2White => _baseTextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  // Subtítulos (H3)
  static TextStyle get h3 => _baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h3Secondary => _baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Cuerpo regular
  static TextStyle get bodyLarge => _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Botones
  static TextStyle get buttonLarge => _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonMedium => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get buttonOutline => _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  // Captions
  static TextStyle get caption => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.3,
  );

  static TextStyle get captionBold => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Números y métricas
  static TextStyle get metricLarge => _baseTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle get metricMedium => _baseTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get metricSmall => _baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Labels y etiquetas
  static TextStyle get labelLarge => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Overline
  static TextStyle get overline => _baseTextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Especiales para la app
  static TextStyle get appBarTitle => _baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardTitle => _baseTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get cardSubtitle => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get inputLabel => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputText => _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputHint => _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle get errorText => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );

  static TextStyle get successText => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    height: 1.3,
  );

  // Badges y estados
  static TextStyle get badge => _baseTextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get statusText => _baseTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  // Métodos para colores dinámicos
  static TextStyle metricWithColor(Color color) => _baseTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.2,
  );

  static TextStyle bodyWithColor(Color color) => _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
  );
}
