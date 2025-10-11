import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glassmorphic_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 1,
      title: 'Usuario conectado',
      message: 'Juan Pérez se ha conectado a la red',
      type: NotificationType.success,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: 2,
      title: 'Límite de datos alcanzado',
      message: 'María García ha alcanzado el 80% de su límite de datos',
      type: NotificationType.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationItem(
      id: 3,
      title: 'Sesión expirada',
      message: 'Carlos López ha terminado su sesión',
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: 4,
      title: 'Nuevo usuario creado',
      message: 'Se ha creado un nuevo usuario: Ana Martínez',
      type: NotificationType.success,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
  ];

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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: IconButton(
                  icon: const Icon(Icons.notifications_active),
                  onPressed: _markAllAsRead,
                ),
              );
            },
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
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _notifications.isEmpty
                      ? EmptyStateVariants.noNotifications(
                          onRefresh: _refreshNotifications,
                        )
                      : _buildNotificationsList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return AnimatedNotificationCard(
          notification: notification,
          animationDelay: Duration(milliseconds: index * 100),
          onTap: () => _markAsRead(notification.id),
          onDismiss: () => _dismissNotification(notification.id),
        );
      },
    );
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _dismissNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _refreshNotifications() {
    // Simular actualización de notificaciones
    setState(() {
      _notifications.add(
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Nueva notificación',
          message: 'Esta es una notificación simulada',
          type: NotificationType.info,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType { success, warning, error, info }

class AnimatedNotificationCard extends StatefulWidget {
  final NotificationItem notification;
  final Duration animationDelay;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const AnimatedNotificationCard({
    super.key,
    required this.notification,
    required this.animationDelay,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<AnimatedNotificationCard> createState() => _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(MediaQuery.of(context).size.width * _slideAnimation.value, 0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassmorphicCard(
                child: ListTile(
                  leading: _buildNotificationIcon(),
                  title: Text(
                    widget.notification.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: widget.notification.isRead 
                          ? FontWeight.normal 
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.notification.message),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(widget.notification.timestamp),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  trailing: widget.notification.isRead
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onDismiss,
                        )
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: widget.onTap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    Color color;

    switch (widget.notification.type) {
      case NotificationType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case NotificationType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case NotificationType.info:
        icon = Icons.info;
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}