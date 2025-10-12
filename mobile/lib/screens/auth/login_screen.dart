import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/glassmorphic_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  ButtonState _buttonState = ButtonState.idle;

  // Focus nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    // Form animations
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    // Button animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _headerController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _buttonState = ButtonState.error;
      });
      return;
    }

    setState(() {
      _buttonState = ButtonState.loading;
    });

    // MODO DEMO: Simular login exitoso sin backend
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _buttonState = ButtonState.success;
      });

      // Navigate to network meter after success animation
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.go('/network-meter');
        }
      });
    }
  }
  Future<void> _loginWithBackend() async {
  final url = Uri.parse('https://renetta-concordal-anderson.ngrok-free.dev/admin/users'); // <-- cambia por tu URL ngrok

  final body = jsonEncode({
    "nombre": "Admin Demo",
    "correo": _emailController.text.trim(),
    "password": _passwordController.text.trim(),
    "rol": "admin"
  });

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Usuario creado: ${data['uid']}");

      if (mounted) {
        setState(() {
          _buttonState = ButtonState.success;
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          context.go('/network-meter');
        });
      }
    } else {
      print("❌ Error ${response.statusCode}: ${response.body}");
      setState(() {
        _buttonState = ButtonState.error;
      });
    }
  } catch (e) {
    print("🚨 Error de conexión: $e");
    setState(() {
      _buttonState = ButtonState.error;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: SlideTransition(
                          position: _headerSlideAnimation,
                          child: _buildHeader(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Form
                  AnimatedBuilder(
                    animation: _formController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _formFadeAnimation,
                        child: SlideTransition(
                          position: _formSlideAnimation,
                          child: _buildForm(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Button
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _buttonFadeAnimation,
                        child: _buildLoginButton(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Forgot password link
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _buttonFadeAnimation,
                        child: _buildForgotPasswordLink(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.wifi, size: 40, color: Colors.white),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Bienvenido',
          style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Inicia sesión para gestionar tu red Wi-Fi',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return GlassmorphicCard(
      child: Column(
        children: [
          // Email field
          _buildEmailField(),

          const SizedBox(height: 16),

          // Password field
          _buildPasswordField(),

          const SizedBox(height: 16),

          // Remember me checkbox
          _buildRememberMeCheckbox(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
      validator: AppValidators.validateEmail,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'correo@ejemplo.com',
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: _emailController.text.isNotEmpty
            ? Icon(
                _isValidEmail(_emailController.text)
                    ? Icons.check_circle
                    : Icons.error,
                color: _isValidEmail(_emailController.text)
                    ? AppColors.success
                    : AppColors.error,
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      validator: AppValidators.validatePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const SizedBox(width: 8),
        Text('Recordarme', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedButton(
      text: 'Iniciar Sesión',
      onPressed: () async {
    if (_formKey.currentState!.validate()) {
      setState(() => _buttonState = ButtonState.loading);
      await _loginWithBackend();
    }
  },
      state: _buttonState,
      isFullWidth: true,
      icon: Icons.login,
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        // TODO: Implement forgot password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Función en desarrollo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return AppValidators.validateEmail(email) == null;
  }
}
