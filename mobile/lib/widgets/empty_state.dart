import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import 'animated_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? imagePath;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customWidget;
  final bool showIcon;
  final bool showButton;
  final Color? iconColor;
  final double? iconSize;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imagePath,
    this.buttonText,
    this.onButtonPressed,
    this.customWidget,
    this.showIcon = true,
    this.showButton = true,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono o imagen
            if (showIcon) ...[
              _buildIconOrImage(),
              const SizedBox(height: 24),
            ],
            
            // Widget personalizado
            if (customWidget != null) ...[
              customWidget!,
              const SizedBox(height: 24),
            ],
            
            // Título
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botón de acción
            if (showButton && buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              AnimatedButtonVariants.primary(
                text: buttonText!,
                onPressed: onButtonPressed!,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconOrImage() {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      );
    }
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: iconSize ?? 40,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }
}

// Variantes predefinidas de EmptyState
class EmptyStateVariants {
  // Estado vacío para usuarios
  static Widget noUsers({
    VoidCallback? onAddUser,
  }) {
    return EmptyState(
      title: 'Aún no hay usuarios',
      subtitle: 'Crea tu primer usuario para comenzar a gestionar el acceso a la red Wi-Fi',
      icon: Icons.people_outline,
      buttonText: 'Crear usuario',
      onButtonPressed: onAddUser,
    );
  }

  // Estado vacío para sesiones
  static Widget noSessions({
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      title: 'No hay sesiones activas',
      subtitle: 'Los usuarios aparecerán aquí cuando se conecten a la red',
      icon: Icons.wifi_off,
      buttonText: 'Actualizar',
      onButtonPressed: onRefresh,
    );
  }

  // Estado vacío para códigos QR
  static Widget noQRCodes({
    VoidCallback? onGenerateQR,
  }) {
    return EmptyState(
      title: 'No hay códigos QR',
      subtitle: 'Genera tu primer código QR para facilitar el acceso a la red',
      icon: Icons.qr_code_outlined,
      buttonText: 'Generar QR',
      onButtonPressed: onGenerateQR,
    );
  }

  // Estado vacío para notificaciones
  static Widget noNotifications({
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      title: 'No hay notificaciones',
      subtitle: 'Las notificaciones importantes aparecerán aquí',
      icon: Icons.notifications_none,
      buttonText: 'Actualizar',
      onButtonPressed: onRefresh,
    );
  }

  // Estado vacío para búsqueda
  static Widget noSearchResults({
    String? searchQuery,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      title: 'No se encontraron resultados',
      subtitle: searchQuery != null 
          ? 'No hay elementos que coincidan con "$searchQuery"'
          : 'Intenta con otros términos de búsqueda',
      icon: Icons.search_off,
      buttonText: 'Limpiar búsqueda',
      onButtonPressed: onClearSearch,
    );
  }

  // Estado vacío para errores
  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      title: 'Algo salió mal',
      subtitle: message ?? 'Ocurrió un error inesperado. Intenta nuevamente',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      buttonText: 'Reintentar',
      onButtonPressed: onRetry,
    );
  }

  // Estado vacío para conexión
  static Widget noConnection({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      title: 'Sin conexión',
      subtitle: 'Verifica tu conexión a internet e intenta nuevamente',
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      buttonText: 'Reintentar',
      onButtonPressed: onRetry,
    );
  }

  // Estado vacío para permisos
  static Widget noPermissions({
    String? message,
    VoidCallback? onRequestPermission,
  }) {
    return EmptyState(
      title: 'Permisos requeridos',
      subtitle: message ?? 'Esta función requiere permisos especiales para funcionar correctamente',
      icon: Icons.lock_outline,
      iconColor: AppColors.warning,
      buttonText: 'Solicitar permisos',
      onButtonPressed: onRequestPermission,
    );
  }

  // Estado vacío para datos
  static Widget noData({
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      title: 'Sin datos',
      subtitle: message ?? 'No hay datos disponibles en este momento',
      icon: Icons.data_usage,
      iconColor: AppColors.textLight,
      buttonText: 'Actualizar',
      onButtonPressed: onRefresh,
    );
  }

  // Estado vacío para historial
  static Widget noHistory({
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      title: 'Sin historial',
      subtitle: message ?? 'El historial aparecerá aquí cuando haya actividad',
      icon: Icons.history,
      iconColor: AppColors.textLight,
      buttonText: 'Actualizar',
      onButtonPressed: onRefresh,
    );
  }

  // Estado vacío para estadísticas
  static Widget noStats({
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      title: 'Sin estadísticas',
      subtitle: message ?? 'Las estadísticas aparecerán aquí cuando haya datos suficientes',
      icon: Icons.bar_chart_outlined,
      iconColor: AppColors.textLight,
      buttonText: 'Actualizar',
      onButtonPressed: onRefresh,
    );
  }

  // Estado vacío personalizable
  static Widget custom({
    required String title,
    String? subtitle,
    IconData? icon,
    String? imagePath,
    String? buttonText,
    VoidCallback? onButtonPressed,
    Widget? customWidget,
    bool showIcon = true,
    bool showButton = true,
    Color? iconColor,
    double? iconSize,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      icon: icon,
      imagePath: imagePath,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      customWidget: customWidget,
      showIcon: showIcon,
      showButton: showButton,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }
}

// Widget de estado vacío con animación
class AnimatedEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showIcon;
  final bool showButton;
  final Color? iconColor;

  const AnimatedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.showIcon = true,
    this.showButton = true,
    this.iconColor,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: EmptyState(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
                buttonText: widget.buttonText,
                onButtonPressed: widget.onButtonPressed,
                showIcon: widget.showIcon,
                showButton: widget.showButton,
                iconColor: widget.iconColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
