import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/users_provider.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _selectedFilter = 'all';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    await usersProvider.loadUsers(refresh: true);
  }

  Future<void> _loadMoreUsers() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    if (usersProvider.hasMorePages && !usersProvider.isLoadingMore) {
      await usersProvider.loadUsers();
    }
  }

  void _onSearchChanged(String query) {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    usersProvider.setFilters(searchQuery: query);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    usersProvider.setFilters(statusFilter: filter);
  }

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
              _buildAppBar(),
              
              // Search Bar
              if (_showSearch) _buildSearchBar(),
              
              // Filter Chips
              _buildFilterChips(),
              
              // Users List
              Expanded(
                child: _buildUsersList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/users/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Text(
              'Usuarios',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassmorphicCard(
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre, SSID, IP...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'Todos', 'count': 0},
      {'key': 'active', 'label': 'Activos', 'count': 0},
      {'key': 'suspended', 'label': 'Suspendidos', 'count': 0},
      {'key': 'expired', 'label': 'Expirados', 'count': 0},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(filter['key'] as String),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<UsersProvider>(
      builder: (context, usersProvider, child) {
        if (usersProvider.isLoading && usersProvider.users.isEmpty) {
          return const LoadingOverlay(
            isLoading: true,
            message: 'Cargando usuarios...',
            child: SizedBox(),
          );
        }

        if (usersProvider.error != null && usersProvider.users.isEmpty) {
          return EmptyStateVariants.error(
            message: usersProvider.error,
            onRetry: _loadUsers,
          );
        }

        if (usersProvider.filteredUsers.isEmpty) {
          return EmptyStateVariants.noUsers(
            onAddUser: () => context.go('/users/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadUsers,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: usersProvider.filteredUsers.length + 
                      (usersProvider.hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= usersProvider.filteredUsers.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final user = usersProvider.filteredUsers[index];
              return _buildUserCard(user);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        onTap: () => context.go('/users/${user.id}'),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.getUserStatusColor(user.status).withOpacity(0.1),
              child: Text(
                user.initials,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.getUserStatusColor(user.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusBadge(user.status),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    user.ssid,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Usage info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.remainingTimeMinutes > 0 
                            ? '${AppFormatters.formatDuration(Duration(minutes: user.remainingTimeMinutes))} restante'
                            : 'Ilimitado',
                        style: AppTextStyles.caption,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Icon(
                        Icons.data_usage,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.remainingDataMB > 0 
                            ? '${AppFormatters.formatBytes(user.remainingDataMB * 1024 * 1024)} restante'
                            : 'Ilimitado',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Connection indicator
            if (user.isConnected)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = AppColors.getUserStatusColor(status);
    final text = AppFormatters.formatUserStatus(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showOptionsMenu() {
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
              leading: const Icon(Icons.sort),
              title: const Text('Ordenar por'),
              onTap: () {
                Navigator.pop(context);
                _showSortOptions();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Filtros avanzados'),
              onTap: () {
                Navigator.pop(context);
                _showAdvancedFilters();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exportar lista'),
              onTap: () {
                Navigator.pop(context);
                _exportUsersList();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    // TODO: Implement sort options
  }

  void _showAdvancedFilters() {
    // TODO: Implement advanced filters
  }

  void _exportUsersList() {
    // TODO: Implement export functionality
  }
}
