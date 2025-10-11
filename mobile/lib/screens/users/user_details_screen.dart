import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/users_provider.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/animated_button.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;

  const UserDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    await usersProvider.getUserById(widget.userId);
    setState(() {
      _user = usersProvider.selectedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // User Header
              _buildUserHeader(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Tab Content
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/users'),
          ),
          Expanded(
            child: Text(
              _user!.name,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editUser(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GlassmorphicCard(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.getUserStatusColor(_user!.status).withOpacity(0.1),
              child: Text(
                _user!.initials,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.getUserStatusColor(_user!.status),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _user!.name,
              style: AppTextStyles.h2,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _user!.ssid,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.getUserStatusColor(_user!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.getUserStatusColor(_user!.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                AppFormatters.formatUserStatus(_user!.status),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.getUserStatusColor(_user!.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassmorphicCard(
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Historial'),
            Tab(text: 'Configuración'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInfoTab(),
        _buildHistoryTab(),
        _buildConfigTab(),
      ],
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Network Info
          _buildInfoSection(
            title: 'Datos de red',
            children: [
              _buildInfoItem('SSID', _user!.ssid),
              _buildInfoItem('Tipo de autenticación', _user!.authType),
              _buildInfoItem('Contraseña', '••••••••'),
              if (_user!.macAddress != null)
                _buildInfoItem('MAC Address', _user!.macAddress!),
              if (_user!.currentIP != null)
                _buildInfoItem('IP actual', _user!.currentIP!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Limits Info
          _buildInfoSection(
            title: 'Límites y consumo',
            children: [
              _buildLimitCard(
                'Tiempo de sesión',
                Icons.access_time,
                _user!.timeUsagePercentage,
                '${AppFormatters.formatDuration(Duration(minutes: _user!.currentSessionTimeMinutes))} / ${AppFormatters.formatDuration(Duration(minutes: _user!.timeLimitMinutes))}',
              ),
              _buildLimitCard(
                'Consumo de datos',
                Icons.data_usage,
                _user!.dataUsagePercentage,
                '${AppFormatters.formatBytes(_user!.currentDataUsageMB * 1024 * 1024)} / ${AppFormatters.formatBytes(_user!.dataLimitMB * 1024 * 1024)}',
              ),
              _buildLimitCard(
                'Ancho de banda',
                Icons.speed,
                0.5, // Placeholder
                '${_user!.speedLimitMbps} Mbps',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text('Historial de sesiones'),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildConfigSection(
            title: 'Estado del usuario',
            children: [
              SwitchListTile(
                title: const Text('Usuario activo'),
                value: _user!.isActive,
                onChanged: (value) => _toggleUserStatus(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildConfigSection(
            title: 'Acciones',
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Restablecer contraseña'),
                onTap: () => _resetPassword(),
              ),
              ListTile(
                leading: const Icon(Icons.wifi_off),
                title: const Text('Desconectar ahora'),
                onTap: () => _disconnectUser(),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar usuario'),
                onTap: () => _deleteUser(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard(String title, IconData icon, double percentage, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.getPercentageColor(percentage),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection({
    required String title,
    required List<Widget> children,
  }) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _editUser() {
    // TODO: Navigate to edit user screen
  }

  void _showOptionsMenu() {
    // TODO: Show options menu
  }

  void _toggleUserStatus() {
    // TODO: Toggle user status
  }

  void _resetPassword() {
    // TODO: Reset password
  }

  void _disconnectUser() {
    // TODO: Disconnect user
  }

  void _deleteUser() {
    // TODO: Delete user
  }
}
