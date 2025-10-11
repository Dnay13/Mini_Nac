import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa tus pantallas
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/network/network_meter_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/users/users_list_screen.dart';
import '../screens/users/user_details_screen.dart';
import '../screens/users/create_user_screen.dart';
import '../screens/qr/generate_qr_screen.dart';
import '../screens/qr/qr_history_screen.dart';
import '../screens/sessions/active_sessions_screen.dart';
import '../screens/stats/statistics_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/internet_config_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Network
      GoRoute(
        path: '/network-meter',
        name: 'network-meter',
        builder: (context, state) => const NetworkMeterScreen(),
      ),

      // Users (rutas anidadas corregidas)
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersListScreen(),
        routes: [
          GoRoute(
            path: 'create', // ✅ relativo
            name: 'create-user',
            builder: (context, state) => const CreateUserScreen(),
          ),
          GoRoute(
            path: ':userId', // ✅ relativo
            name: 'user-details',
            builder: (context, state) {
              final userId = int.parse(state.pathParameters['userId']!);
              return UserDetailsScreen(userId: userId);
            },
          ),
        ],
      ),

      // QR (rutas anidadas corregidas)
      GoRoute(
        path: '/qr',
        name: 'qr',
        builder: (context, state) => const GenerateQRScreen(),
        routes: [
          GoRoute(
            path: 'generate', // ✅ relativo
            name: 'generate-qr',
            builder: (context, state) => const GenerateQRScreen(),
          ),
          GoRoute(
            path: 'history', // ✅ relativo
            name: 'qr-history',
            builder: (context, state) => const QRHistoryScreen(),
          ),
        ],
      ),

      // Sessions
      GoRoute(
        path: '/sessions',
        name: 'sessions',
        builder: (context, state) => const ActiveSessionsScreen(),
      ),

      // Statistics
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Internet Configuration
      GoRoute(
        path: '/internet-config',
        name: 'internet-config',
        builder: (context, state) => const InternetConfigScreen(),
      ),
    ],

    // Error page (fallback)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('La página que buscas no existe',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Ir al Dashboard'),
            ),
          ],
        ),
      ),
    ),

    // Redirección (placeholder, sin auth)
    redirect: (context, state) => null,
  );

  static GoRouter get router => _router;
}

// --------------------------------------
// Extensión para navegación rápida
// --------------------------------------
extension AppRouterExtension on GoRouter {
  void goToSplash() => go('/splash');
  void goToLogin() => go('/login');
  void goToDashboard() => go('/dashboard');
  void goToNetworkMeter() => go('/network-meter');

  // Users
  void goToUsers() => go('/users');
  void goToCreateUser() => go('/users/create');
  void goToUserDetails(int id) => go('/users/$id');

  // QR
  void goToGenerateQR() => go('/qr/generate');
  void goToQRHistory() => go('/qr/history');

  // Others
  void goToSessions() => go('/sessions');
  void goToStatistics() => go('/statistics');
  void goToNotifications() => go('/notifications');
  void goToSettings() => go('/settings');
  void goToInternetConfig() => go('/internet-config');
}

// --------------------------------------
// Helper opcional (navegación avanzada)
// --------------------------------------
class NavigationHelper {
  static final GoRouter _router = AppRouter.router;

  static void goToUserDetailsWithParams(int userId, {Map<String, String>? queryParams}) {
    final uri = Uri(path: '/users/$userId', queryParameters: queryParams);
    _router.go(uri.toString());
  }

  static void replaceToDashboard() => _router.go('/dashboard');
  static void pushToCreateUser() => _router.push('/users/create');
  static void pop() => _router.pop();
  static bool canPop() => _router.canPop();

  static String get currentLocation =>
      _router.routerDelegate.currentConfiguration.uri.toString();
}

// --------------------------------------
// Transiciones personalizadas
// --------------------------------------
class CustomPageTransitions {
  static Page<T> fadeTransition<T extends Object?>({
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }

  static Page<T> slideTransition<T extends Object?>({
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween(begin: begin, end: end)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      ),
      child: child,
    );
  }
}

class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}
