import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/animated_button.dart';

class GenerateQRScreen extends StatelessWidget {
  const GenerateQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Generar código QR',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 32),
                _buildForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        children: [
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
          
          const SizedBox(height: 32),
          
          // Generate Button
          AnimatedButtonVariants.primary(
            text: 'Generar código QR',
            onPressed: () => _generateQR(context),
            isFullWidth: true,
            icon: Icons.qr_code,
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

  void _generateQR(BuildContext context) {
    // TODO: Generate QR code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR generado exitosamente')),
    );
  }
}