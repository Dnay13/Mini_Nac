import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

enum ButtonState { idle, loading, success, error }

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonState state;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final double? elevation;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.state = ButtonState.idle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? AppColors.primary,
      end: widget.backgroundColor ?? AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange();
    }
  }

  void _handleStateChange() {
    switch (widget.state) {
      case ButtonState.loading:
        _animationController.repeat();
        break;
      case ButtonState.success:
        _animationController.stop();
        _showSuccessAnimation();
        break;
      case ButtonState.error:
        _animationController.stop();
        _showErrorAnimation();
        break;
      case ButtonState.idle:
        _animationController.stop();
        _animationController.reset();
        break;
    }
  }

  void _showSuccessAnimation() {
    // Animación de éxito con checkmark
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            // Volver al estado idle después de mostrar éxito
          });
        }
      });
    });
  }

  void _showErrorAnimation() {
    // Animación de error con shake
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            // Volver al estado idle después de mostrar error
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.isOutlined) {
      return Colors.transparent;
    }
    
    switch (widget.state) {
      case ButtonState.loading:
        return (widget.backgroundColor ?? AppColors.primary).withOpacity(0.8);
      case ButtonState.success:
        return AppColors.success;
      case ButtonState.error:
        return AppColors.error;
      case ButtonState.idle:
        return widget.backgroundColor ?? AppColors.primary;
    }
  }

  Color _getTextColor() {
    if (widget.isOutlined) {
      return widget.textColor ?? widget.backgroundColor ?? AppColors.primary;
    }
    
    switch (widget.state) {
      case ButtonState.loading:
      case ButtonState.success:
      case ButtonState.error:
        return Colors.white;
      case ButtonState.idle:
        return widget.textColor ?? Colors.white;
    }
  }

  Color _getBorderColor() {
    if (widget.isOutlined) {
      return widget.borderColor ?? widget.backgroundColor ?? AppColors.primary;
    }
    return Colors.transparent;
  }

  Widget _buildContent() {
    switch (widget.state) {
      case ButtonState.loading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Cargando...',
              style: AppTextStyles.buttonLarge.copyWith(
                color: _getTextColor(),
              ),
            ),
          ],
        );
      
      case ButtonState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '¡Éxito!',
              style: AppTextStyles.buttonLarge.copyWith(
                color: _getTextColor(),
              ),
            ),
          ],
        );
      
      case ButtonState.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Reintentar',
              style: AppTextStyles.buttonLarge.copyWith(
                color: _getTextColor(),
              ),
            ),
          ],
        );
      
      case ButtonState.idle:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: _getTextColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: AppTextStyles.buttonLarge.copyWith(
                color: _getTextColor(),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isFullWidth ? double.infinity : widget.width,
            height: widget.height ?? 56,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: widget.isOutlined ? 2 : 0,
              ),
              boxShadow: widget.elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: widget.elevation!,
                        offset: Offset(0, widget.elevation! / 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.state == ButtonState.idle ? widget.onPressed : null,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                child: Center(
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Variantes predefinidas de AnimatedButton
class AnimatedButtonVariants {
  // Botón primario
  static Widget primary({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      icon: icon,
      isFullWidth: isFullWidth,
      elevation: 4,
    );
  }

  // Botón secundario
  static Widget secondary({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: AppColors.secondary,
      textColor: AppColors.primary,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  // Botón outline
  static Widget outline({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    Color? color,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: color ?? AppColors.primary,
      textColor: color ?? AppColors.primary,
      borderColor: color ?? AppColors.primary,
      icon: icon,
      isOutlined: true,
      isFullWidth: isFullWidth,
    );
  }

  // Botón de éxito
  static Widget success({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  // Botón de error
  static Widget error({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  // Botón de advertencia
  static Widget warning({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  // Botón pequeño
  static Widget small({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor ?? Colors.white,
      icon: icon,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // Botón grande
  static Widget large({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    bool isFullWidth = false,
  }) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      state: state,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor ?? Colors.white,
      icon: icon,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      isFullWidth: isFullWidth,
    );
  }

  // Botón con gradiente
  static Widget gradient({
    required String text,
    required VoidCallback onPressed,
    ButtonState state = ButtonState.idle,
    IconData? icon,
    Gradient? gradient,
    bool isFullWidth = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedButton(
        text: text,
        onPressed: onPressed,
        state: state,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
        icon: icon,
        isFullWidth: isFullWidth,
        elevation: 0,
      ),
    );
  }
}
