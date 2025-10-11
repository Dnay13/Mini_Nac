import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import 'glassmorphic_card.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool showTrend;
  final String? trendValue;
  final bool isTrendPositive;
  final bool isLoading;
  final Widget? customChild;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isTrendPositive = true,
    this.isLoading = false,
    this.customChild,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GlassmorphicCardVariants.stat(
              onTap: widget.onTap,
              accentColor: widget.color,
              child: widget.customChild ?? _buildDefaultContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con ícono y título
        Row(
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (widget.color ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color ?? AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Valor principal
        if (widget.isLoading)
          _buildLoadingValue()
        else
          _buildValue(),
        
        const SizedBox(height: 8),
        
        // Subtítulo y tendencia
        if (widget.subtitle != null || widget.showTrend)
          _buildSubtitle(),
      ],
    );
  }

  Widget _buildLoadingValue() {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildValue() {
    return Text(
      widget.value,
      style: AppTextStyles.metricLarge.copyWith(
        color: widget.color ?? AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        if (widget.subtitle != null) ...[
          Expanded(
            child: Text(
              widget.subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (widget.showTrend && widget.trendValue != null) ...[
          const SizedBox(width: 8),
          _buildTrendIndicator(),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (widget.isTrendPositive ? AppColors.success : AppColors.error)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isTrendPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: widget.isTrendPositive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 2),
          Text(
            widget.trendValue!,
            style: AppTextStyles.caption.copyWith(
              color: widget.isTrendPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Variantes predefinidas de StatCard
class StatCardVariants {
  // Card de usuarios totales
  static Widget totalUsers({
    required String value,
    String? subtitle,
    String? trendValue,
    bool isTrendPositive = true,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Usuarios totales',
      value: value,
      subtitle: subtitle,
      icon: Icons.people_outline,
      color: AppColors.primary,
      onTap: onTap,
      showTrend: trendValue != null,
      trendValue: trendValue,
      isTrendPositive: isTrendPositive,
      isLoading: isLoading,
    );
  }

  // Card de usuarios activos
  static Widget activeUsers({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Activos ahora',
      value: value,
      subtitle: subtitle,
      icon: Icons.wifi,
      color: AppColors.success,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de tiempo promedio
  static Widget averageTime({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Tiempo promedio',
      value: value,
      subtitle: subtitle,
      icon: Icons.access_time,
      color: AppColors.accent,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de consumo total
  static Widget totalConsumption({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Consumo total',
      value: value,
      subtitle: subtitle,
      icon: Icons.storage,
      color: AppColors.warning,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de velocidad de red
  static Widget networkSpeed({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Velocidad de red',
      value: value,
      subtitle: subtitle,
      icon: Icons.speed,
      color: AppColors.primary,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de latencia
  static Widget latency({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Latencia',
      value: value,
      subtitle: subtitle,
      icon: Icons.network_ping,
      color: AppColors.success,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de ancho de banda
  static Widget bandwidth({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Ancho de banda',
      value: value,
      subtitle: subtitle,
      icon: Icons.network_check,
      color: AppColors.warning,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de sesiones activas
  static Widget activeSessions({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Sesiones activas',
      value: value,
      subtitle: subtitle,
      icon: Icons.radio_button_checked,
      color: AppColors.success,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card de códigos QR
  static Widget qrCodes({
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return StatCard(
      title: 'Códigos QR',
      value: value,
      subtitle: subtitle,
      icon: Icons.qr_code,
      color: AppColors.primary,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  // Card personalizable
  static Widget custom({
    required String title,
    required String value,
    String? subtitle,
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
    bool showTrend = false,
    String? trendValue,
    bool isTrendPositive = true,
    bool isLoading = false,
    Widget? customChild,
  }) {
    return StatCard(
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      color: color,
      onTap: onTap,
      showTrend: showTrend,
      trendValue: trendValue,
      isTrendPositive: isTrendPositive,
      isLoading: isLoading,
      customChild: customChild,
    );
  }
}
