import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/animated_button.dart';

class InternetConfigScreen extends StatefulWidget {
  const InternetConfigScreen({super.key});

  @override
  State<InternetConfigScreen> createState() => _InternetConfigScreenState();
}

class _InternetConfigScreenState extends State<InternetConfigScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController(text: 'MiWiFi-Home');
  final _passwordController = TextEditingController(text: 'miPassword123');
  final _providerController = TextEditingController(text: 'ISP Demo');
  final _planController = TextEditingController(text: 'Plan 100 Mbps');
  
  String _selectedAuthType = 'WPA2';
  String _selectedFrequency = '2.4 GHz';
  bool _autoConnect = true;
  bool _saveCredentials = true;
  bool _showPassword = false;

  final List<String> _authTypes = ['WPA2', 'WPA3', 'WPA2/WPA3', 'Open'];
  final List<String> _frequencies = ['2.4 GHz', '5 GHz', 'Ambas'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    _providerController.dispose();
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Internet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildNetworkInfoCard(),
                          const SizedBox(height: 16),
                          _buildSecurityCard(),
                          const SizedBox(height: 16),
                          _buildProviderCard(),
                          const SizedBox(height: 16),
                          _buildOptionsCard(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkInfoCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de Red',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _ssidController,
            decoration: const InputDecoration(
              labelText: 'Nombre de red (SSID)',
              hintText: 'Ej: MiWiFi-Home',
              prefixIcon: Icon(Icons.wifi),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El SSID es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Contraseña de la red',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedAuthType,
            decoration: const InputDecoration(
              labelText: 'Tipo de autenticación',
              prefixIcon: Icon(Icons.security),
            ),
            items: _authTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAuthType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedFrequency,
            decoration: const InputDecoration(
              labelText: 'Frecuencia',
              prefixIcon: Icon(Icons.signal_cellular_alt),
            ),
            items: _frequencies.map((freq) {
              return DropdownMenuItem(
                value: freq,
                child: Text(freq),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFrequency = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seguridad',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Guardar credenciales'),
            subtitle: const Text('Almacenar información de forma segura'),
            value: _saveCredentials,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _saveCredentials = value;
              });
            },
          ),
          
          SwitchListTile(
            title: const Text('Conexión automática'),
            subtitle: const Text('Conectar automáticamente cuando esté disponible'),
            value: _autoConnect,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _autoConnect = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proveedor de Internet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _providerController,
            decoration: const InputDecoration(
              labelText: 'Proveedor',
              hintText: 'Ej: Movistar, Claro, etc.',
              prefixIcon: Icon(Icons.business),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _planController,
            decoration: const InputDecoration(
              labelText: 'Plan contratado',
              hintText: 'Ej: Plan 100 Mbps',
              prefixIcon: Icon(Icons.speed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opciones Avanzadas',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Generar QR de conexión'),
            subtitle: const Text('Crear código QR para conexión rápida'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _generateQRCode,
          ),
          
          ListTile(
            leading: const Icon(Icons.network_check),
            title: const Text('Probar conexión'),
            subtitle: const Text('Verificar velocidad y estabilidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _testConnection,
          ),
          
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de conexiones'),
            subtitle: const Text('Ver conexiones anteriores'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showConnectionHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AnimatedButtonVariants.outline(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedButtonVariants.primary(
            text: 'Guardar',
            onPressed: _saveConfiguration,
            icon: Icons.save,
          ),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      // Simular guardado de configuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuración guardada exitosamente'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver QR',
            textColor: Colors.white,
            onPressed: _generateQRCode,
          ),
        ),
      );
      
      // Simular generación automática de QR
      if (_saveCredentials) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _generateQRCode();
          }
        });
      }
    }
  }

  void _generateQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código QR Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'WiFi: ${_ssidController.text}',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contraseña: ${_passwordController.text}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR descargado')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR compartido')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _testConnection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Probando Conexión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando velocidad y estabilidad...'),
          ],
        ),
      ),
    );

    // Simular prueba de conexión
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión estable - Velocidad: 85.5 Mbps'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showConnectionHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de Conexiones'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Función en desarrollo'),
            SizedBox(height: 16),
            Text('Aquí podrás ver el historial completo de conexiones, velocidades y tiempos de conexión.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
