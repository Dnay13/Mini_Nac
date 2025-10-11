import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/glassmorphic_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
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
                // Apariencia
                _buildThemeSection(context),

                const SizedBox(height: 16),

                // Configuración de aplicación
                _buildAppSettingsSection(context),

                const SizedBox(height: 16),

                // Configuración de cuenta
                _buildAccountSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // SECCIÓN DE TEMA
  // ------------------------------
  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apariencia', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Tema'),
                subtitle: Text(themeProvider.currentThemeName),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------
  // SECCIÓN DE CONFIGURACIÓN DE APP
  // ------------------------------
  Widget _buildAppSettingsSection(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aplicación', style: AppTextStyles.h3),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Configuración de Internet'),
            subtitle: const Text('Guardar conexión Wi-Fi'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _goToInternetConfig(context),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // SECCIÓN DE CUENTA
  // ------------------------------
  Widget _buildAccountSection(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cuenta', style: AppTextStyles.h3),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Editar información personal'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showProfileDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar contraseña'),
            subtitle: const Text('Actualizar contraseña de seguridad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showChangePasswordDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Autenticación de dos factores'),
            subtitle: const Text('Agregar capa extra de seguridad'),
            trailing: Switch(
              value: false,
              onChanged: (value) => _toggleTwoFactor(context, value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Notificaciones de seguridad'),
            subtitle: const Text('Alertas de inicio de sesión'),
            trailing: Switch(
              value: true,
              onChanged: (value) => _toggleSecurityNotifications(context, value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de actividad'),
            subtitle: const Text('Ver registros de acceso'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showActivityHistory(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Respaldo de datos'),
            subtitle: const Text('Exportar configuración'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showBackupDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            subtitle: const Text('Salir de la aplicación'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // MÉTODOS AUXILIARES
  // ------------------------------
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeProvider.availableThemes.map((theme) {
            return RadioListTile<ThemeMode>(
              title: Text(theme.name),
              subtitle: Text(theme.description),
              value: theme.mode,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeFromOption(theme);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesión cerrada (solo frontend demo)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Perfil de Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Función en desarrollo'),
            SizedBox(height: 16),
            Text(
              'Aquí podrás editar tu información personal, foto de perfil y preferencias de cuenta.',
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Función en desarrollo'),
            SizedBox(height: 16),
            Text(
              'Aquí podrás cambiar tu contraseña actual por una nueva con mayor seguridad.',
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTwoFactor(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Autenticación de dos factores activada'
            : 'Autenticación de dos factores desactivada'),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  void _toggleSecurityNotifications(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Notificaciones de seguridad activadas'
            : 'Notificaciones de seguridad desactivadas'),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showActivityHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Historial de Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Función en desarrollo'),
            SizedBox(height: 16),
            Text(
              'Aquí podrás ver el historial completo de accesos, cambios de configuración y actividades de tu cuenta.',
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Respaldo de Datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Función en desarrollo'),
            SizedBox(height: 16),
            Text(
              'Aquí podrás exportar tu configuración, usuarios y datos de la aplicación para respaldo o migración.',
            ),
          ],
        ),
      ),
    );
  }

  void _goToInternetConfig(BuildContext context) {
    context.go('/internet-config');
  }
}

