import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/loading_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _actionsController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _statsFadeAnimation;
  late Animation<double> _actionsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Stats animation
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _statsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    // Actions animation
    _actionsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _actionsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionsController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _statsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _actionsController.forward();
    });
  }

  Future<void> _loadDashboardData() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);
    
    await Future.wait([
      usersProvider.loadStats(),
      networkProvider.loadNetworkStats(),
      sessionsProvider.loadActiveSessions(),
    ]);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _actionsController.dispose();
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
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Welcome Header
                        _buildWelcomeHeader(),
                        
                        const SizedBox(height: 24),
                        
                        // Stats Cards
                        _buildStatsCards(),
                        
                        const SizedBox(height: 32),
                        
                        // Quick Actions
                        _buildQuickActions(),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.go('/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.go('/settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<UsersProvider>(
      builder: (context, usersProvider, child) {
        return AnimatedBuilder(
          animation: _headerController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, Administrador 👋',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${usersProvider.connectedUsers} usuarios conectados ahora',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer3<UsersProvider, NetworkProvider, SessionsProvider>(
      builder: (context, usersProvider, networkProvider, sessionsProvider, child) {
        return AnimatedBuilder(
          animation: _statsController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _statsFadeAnimation,
              child: Column(
                children: [
                  // First row
                  Row(
                    children: [
                      Expanded(
                        child: StatCardVariants.totalUsers(
                          value: usersProvider.totalUsers.toString(),
                          subtitle: '+3 esta semana',
                          trendValue: '+3',
                          isTrendPositive: true,
                          onTap: () => context.go('/users'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardVariants.activeUsers(
                          value: usersProvider.connectedUsers.toString(),
                          subtitle: 'En línea',
                          onTap: () => context.go('/sessions'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Second row
                  Row(
                    children: [
                      Expanded(
                        child: StatCardVariants.averageTime(
                          value: '2.5h',
                          subtitle: 'Por sesión',
                          onTap: () => context.go('/statistics'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardVariants.totalConsumption(
                          value: '127 GB',
                          subtitle: 'Este mes',
                          onTap: () => context.go('/statistics'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return AnimatedBuilder(
      animation: _actionsController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _actionsFadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acceso rápido',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Quick action buttons
              _buildQuickActionButton(
                icon: Icons.people_outline,
                title: 'Gestionar Usuarios',
                subtitle: 'Ver y editar usuarios',
                onTap: () => context.go('/users'),
              ),
              
              const SizedBox(height: 12),
              
              _buildQuickActionButton(
                icon: Icons.qr_code_outlined,
                title: 'Generar código QR',
                subtitle: 'Crear acceso rápido',
                onTap: () => context.go('/qr/generate'),
              ),
              
              const SizedBox(height: 12),
              
              _buildQuickActionButton(
                icon: Icons.radio_button_checked,
                title: 'Sesiones activas',
                subtitle: '12 usuarios en línea',
                onTap: () => context.go('/sessions'),
              ),
              
              const SizedBox(height: 12),
              
              _buildQuickActionButton(
                icon: Icons.bar_chart_outlined,
                title: 'Ver estadísticas',
                subtitle: 'Gráficos y métricas',
                onTap: () => context.go('/statistics'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassmorphicCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textLight,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showFABMenu(),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showFABMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Crear nuevo usuario'),
              onTap: () {
                Navigator.pop(context);
                context.go('/users/create');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Generar código QR'),
              onTap: () {
                Navigator.pop(context);
                context.go('/qr/generate');
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
