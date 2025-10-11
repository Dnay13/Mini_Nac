import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/colors.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? blur;
  final double? opacity;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isEnabled;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.blur,
    this.opacity,
    this.boxShadow,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.glassBackground;
    final effectiveBorderColor = borderColor ?? AppColors.glassBorder;
    final effectiveBorderWidth = borderWidth ?? 1.0;
    final effectiveBlur = blur ?? 10.0;
    final effectiveOpacity = opacity ?? 0.1;
    final effectiveBoxShadow = boxShadow ?? AppColors.cardShadow;

    Widget card = Container(
      width: width,
      height: height,
      margin: effectiveMargin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        boxShadow: effectiveBoxShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withOpacity(effectiveOpacity),
              borderRadius: effectiveBorderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null && isEnabled) {
      card = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

// Variantes predefinidas del GlassmorphicCard
class GlassmorphicCardVariants {
  // Card básico
  static Widget basic({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: padding,
      margin: margin,
    );
  }

  // Card elevado
  static Widget elevated({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: padding,
      margin: margin,
      boxShadow: AppColors.elevatedShadow,
      blur: 15.0,
      opacity: 0.15,
    );
  }

  // Card con gradiente
  static Widget gradient({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Gradient? gradient,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: Colors.transparent,
    );
  }

  // Card de estadística
  static Widget stat({
    required Widget child,
    VoidCallback? onTap,
    Color? accentColor,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(20),
      backgroundColor: accentColor?.withOpacity(0.1) ?? AppColors.glassBackground,
      borderColor: accentColor?.withOpacity(0.3) ?? AppColors.glassBorder,
      borderWidth: 2.0,
      blur: 12.0,
      opacity: 0.12,
    );
  }

  // Card de usuario
  static Widget user({
    required Widget child,
    VoidCallback? onTap,
    Color? statusColor,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: statusColor?.withOpacity(0.05) ?? AppColors.glassBackground,
      borderColor: statusColor?.withOpacity(0.2) ?? AppColors.glassBorder,
      borderWidth: 1.5,
      blur: 8.0,
      opacity: 0.08,
    );
  }

  // Card de notificación
  static Widget notification({
    required Widget child,
    VoidCallback? onTap,
    bool isUnread = false,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: isUnread 
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.glassBackground,
      borderColor: isUnread 
          ? AppColors.primary.withOpacity(0.3)
          : AppColors.glassBorder,
      borderWidth: isUnread ? 2.0 : 1.0,
      blur: 10.0,
      opacity: isUnread ? 0.15 : 0.08,
    );
  }

  // Card de acción
  static Widget action({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    bool isEnabled = true,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: isEnabled ? onTap : null,
      isEnabled: isEnabled,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color?.withOpacity(0.1) ?? AppColors.glassBackground,
      borderColor: color?.withOpacity(0.3) ?? AppColors.glassBorder,
      borderWidth: 1.5,
      blur: 8.0,
      opacity: 0.1,
    );
  }

  // Card de lista
  static Widget listItem({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return GlassmorphicCard(
      child: child,
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 2),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: AppColors.glassBackground,
      borderColor: AppColors.glassBorder,
      borderWidth: 0.5,
      blur: 5.0,
      opacity: 0.05,
    );
  }

  // Card de modal
  static Widget modal({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphicCard(
      child: child,
      padding: padding ?? const EdgeInsets.all(24),
      margin: margin ?? const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.glassBackground,
      borderColor: AppColors.glassBorder,
      borderWidth: 1.0,
      blur: 20.0,
      opacity: 0.2,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Card de header
  static Widget header({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return GlassmorphicCard(
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      backgroundColor: AppColors.glassBackground,
      borderColor: AppColors.glassBorder,
      borderWidth: 0.5,
      blur: 15.0,
      opacity: 0.15,
    );
  }
}
