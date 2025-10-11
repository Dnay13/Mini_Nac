import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/animated_button.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  double _timeLimit = 2.0;
  double _dataLimit = 2.0;
  double _speedLimit = 10.0;
  bool _notificationsEnabled = true;
  bool _autoGenerateQR = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Crear nuevo usuario',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 32),
                      _buildForm(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Nuevo usuario',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        children: [
          // Basic Info
          _buildSectionTitle('Información básica'),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Ej: Juan Pérez',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email (opcional)',
              hintText: 'usuario@ejemplo.com',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Teléfono (opcional)',
              hintText: '+51 999 999 999',
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Network Config
          _buildSectionTitle('Configuración de red'),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'SSID',
            ),
            items: const [
              DropdownMenuItem(value: 'WiFi_Guest', child: Text('WiFi_Guest')),
              DropdownMenuItem(value: 'WiFi_Premium', child: Text('WiFi_Premium')),
            ],
            onChanged: (value) {},
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Generar automática',
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Limits
          _buildSectionTitle('Límites y restricciones'),
          const SizedBox(height: 16),
          
          // Time limit slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tiempo de sesión: ${_timeLimit.toInt()} horas'),
              Slider(
                value: _timeLimit,
                min: 1.0,
                max: 24.0,
                divisions: 23,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (value) {
                  setState(() {
                    _timeLimit = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Data limit slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Límite de datos: ${_dataLimit.toStringAsFixed(1)} GB'),
              Slider(
                value: _dataLimit,
                min: 0.5,
                max: 10.0,
                divisions: 19,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (value) {
                  setState(() {
                    _dataLimit = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Speed limit slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Velocidad máxima: ${_speedLimit.toInt()} Mbps'),
              Slider(
                value: _speedLimit,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (value) {
                  setState(() {
                    _speedLimit = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Notifications toggle
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Alertas de límites'),
                  value: _notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
          
          // Auto QR generation toggle
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Generar QR automático'),
                  subtitle: const Text('Crear código QR al guardar'),
                  value: _autoGenerateQR,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _autoGenerateQR = value;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: AnimatedButtonVariants.outline(
                  text: 'Cancelar',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedButtonVariants.primary(
                  text: 'Crear usuario',
                  onPressed: () => _createUser(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  void _createUser(BuildContext context) {
    // Simular creación de usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario creado exitosamente${_autoGenerateQR ? ' y QR generado' : ''}'),
        backgroundColor: Colors.green,
        action: _autoGenerateQR ? SnackBarAction(
          label: 'Ver QR',
          textColor: Colors.white,
          onPressed: () => _showQRDialog(context),
        ) : null,
      ),
    );
    
    // Simular generación automática de QR
    if (_autoGenerateQR) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showQRDialog(context);
        }
      });
    }
  }

  void _showQRDialog(BuildContext context) {
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
              'WiFi: Demo-Network',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contraseña: demo123',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement download QR
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
                      // TODO: Implement share QR
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
}
