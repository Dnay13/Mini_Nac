import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _waveController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthentication();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));
    
    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));
    
    // Final scale to normal size
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.forward();
      }
    });

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Start logo animation
    _logoController.forward();
    
    // Start text animation with delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
    
    // Start wave animation
    _waveController.repeat();
  }

  Future<void> _checkAuthentication() async {
    // Wait for minimum splash duration
    await Future.delayed(AppConstants.splashDuration);
    
    if (!mounted) return;
    
    // MODO DEMO: Ir directamente al login sin verificar autenticación
    context.go('/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animations
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // App name with animations
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Mini NAC',
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.primary,
                                fontSize: 36,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Administrador Wi-Fi',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                // Wave animation
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return _buildWaveAnimation();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Loading indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveAnimation() {
    return SizedBox(
      width: 200,
      height: 60,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: index * 20.0,
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                final delay = index * 0.2;
                final animationValue = (_waveAnimation.value + delay) % 1.0;
                
                return Container(
                  width: 4,
                  height: 20 + (animationValue * 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3 + (animationValue * 0.4)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
