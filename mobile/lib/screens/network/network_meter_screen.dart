import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/network_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/network_gauge.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/loading_overlay.dart';

class NetworkMeterScreen extends StatefulWidget {
  const NetworkMeterScreen({super.key});

  @override
  State<NetworkMeterScreen> createState() => _NetworkMeterScreenState();
}

class _NetworkMeterScreenState extends State<NetworkMeterScreen>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _cardsController;
  late AnimationController _chartController;
  
  late Animation<double> _gaugeScaleAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<Offset> _cardsSlideAnimation;
  late Animation<double> _chartFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadNetworkData();
  }

  void _initializeAnimations() {
    // Gauge animation
    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _gaugeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _gaugeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Cards animation
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _cardsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    // Chart animation
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _chartFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _gaugeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _chartController.forward();
    });
  }

  Future<void> _loadNetworkData() async {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
    await networkProvider.loadNetworkStats();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _cardsController.dispose();
    _chartController.dispose();
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
            onRefresh: _loadNetworkData,
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
                        // Network Gauge
                        _buildNetworkGauge(),
                        
                        const SizedBox(height: 32),
                        
                        // Mini Stats Cards
                        _buildMiniStatsCards(),
                        
                        const SizedBox(height: 32),
                        
                        // Bandwidth Chart
                        _buildBandwidthChart(),
                        
                        const SizedBox(height: 32),
                        
                        // Go to Dashboard Button
                        _buildDashboardButton(),
                        
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
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/login'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: Navigate to network settings
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Estado de Red',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildNetworkGauge() {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        return AnimatedBuilder(
          animation: _gaugeController,
          builder: (context, child) {
            return Transform.scale(
              scale: _gaugeScaleAnimation.value,
              child: Container(
                height: 300,
                child: NetworkSpeedGauge(
                  downloadSpeed: networkProvider.currentDownloadSpeed,
                  uploadSpeed: networkProvider.currentUploadSpeed,
                  maxSpeed: 100.0,
                  onTap: () {
                    // TODO: Show detailed network info
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStatsCards() {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        return AnimatedBuilder(
          animation: _cardsController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _cardsFadeAnimation,
              child: SlideTransition(
                position: _cardsSlideAnimation,
                child: Row(
                  children: [
                    // Wi-Fi Status Card
                    Expanded(
                      child: _buildWiFiStatusCard(networkProvider),
                    ),
                    const SizedBox(width: 12),
                    
                    // Data Usage Card
                    Expanded(
                      child: _buildDataUsageCard(networkProvider),
                    ),
                    const SizedBox(width: 12),
                    
                    // Active Users Card
                    Expanded(
                      child: _buildActiveUsersCard(networkProvider),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWiFiStatusCard(NetworkProvider networkProvider) {
    final status = networkProvider.networkStatus;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    return GlassmorphicCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.wifi,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wi-Fi',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: AppTextStyles.labelMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageCard(NetworkProvider networkProvider) {
    final utilization = networkProvider.bandwidthUtilization;
    final utilizationColor = AppColors.getPercentageColor(utilization);
    
    return GlassmorphicCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: utilizationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.data_usage,
              color: utilizationColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Datos',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            '${(utilization * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.labelMedium.copyWith(
              color: utilizationColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersCard(NetworkProvider networkProvider) {
    return GlassmorphicCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usuarios',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            '${networkProvider.activeUsers} activos',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandwidthChart() {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        return AnimatedBuilder(
          animation: _chartController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _chartFadeAnimation,
              child: GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ancho de Banda',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      child: _buildSimpleChart(networkProvider),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleChart(NetworkProvider networkProvider) {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedChartPainter(
            downloadSpeed: networkProvider.currentDownloadSpeed,
            uploadSpeed: networkProvider.currentUploadSpeed,
            animationValue: _chartFadeAnimation.value,
          ),
          size: const Size(double.infinity, 120),
        );
      },
    );
  }

  Widget _buildDashboardButton() {
    return AnimatedButtonVariants.primary(
      text: 'Ir al Panel',
      onPressed: () => context.go('/dashboard'),
      isFullWidth: true,
      icon: Icons.dashboard,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
      case 'good':
        return AppColors.success;
      case 'unstable':
      case 'moderate':
        return AppColors.warning;
      case 'down':
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
      case 'good':
        return 'Estable';
      case 'unstable':
      case 'moderate':
        return 'Inestable';
      case 'down':
      case 'poor':
        return 'Caído';
      default:
        return 'Desconocido';
    }
  }
}

class AnimatedChartPainter extends CustomPainter {
  final double downloadSpeed;
  final double uploadSpeed;
  final double animationValue;

  AnimatedChartPainter({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final downloadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final uploadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blue;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.withOpacity(0.3),
          Colors.green.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Dibujar fondo con gradiente
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fillPaint,
    );

    // Generar datos simulados para la gráfica
    final points = <Offset>[];
    final uploadPoints = <Offset>[];
    
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 19) * i;
      final baseDownload = downloadSpeed * (0.8 + 0.4 * math.sin(i * 0.3) * animationValue);
      final baseUpload = uploadSpeed * (0.7 + 0.6 * math.cos(i * 0.2) * animationValue);
      
      final y = size.height - (baseDownload / 100) * size.height * 0.8;
      final uploadY = size.height - (baseUpload / 100) * size.height * 0.8;
      
      points.add(Offset(x, y));
      uploadPoints.add(Offset(x, uploadY));
    }

    // Dibujar línea de descarga
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      canvas.drawPath(path, downloadPaint);
    }

    // Dibujar línea de subida
    if (uploadPoints.isNotEmpty) {
      final uploadPath = Path();
      uploadPath.moveTo(uploadPoints.first.dx, uploadPoints.first.dy);
      
      for (int i = 1; i < uploadPoints.length; i++) {
        uploadPath.lineTo(uploadPoints[i].dx, uploadPoints[i].dy);
      }
      
      canvas.drawPath(uploadPath, uploadPaint);
    }

    // Dibujar puntos de datos
    for (final point in points) {
      canvas.drawCircle(point, 3, downloadPaint..style = PaintingStyle.fill);
    }
    
    for (final point in uploadPoints) {
      canvas.drawCircle(point, 3, uploadPaint..style = PaintingStyle.fill);
    }

    // Dibujar texto de velocidad actual
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${downloadSpeed.toStringAsFixed(1)} Mbps',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

    final uploadTextPainter = TextPainter(
      text: TextSpan(
        text: '${uploadSpeed.toStringAsFixed(1)} Mbps',
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    uploadTextPainter.layout();
    uploadTextPainter.paint(canvas, Offset(10, 30));
  }

  @override
  bool shouldRepaint(AnimatedChartPainter oldDelegate) {
    return oldDelegate.downloadSpeed != downloadSpeed ||
           oldDelegate.uploadSpeed != uploadSpeed ||
           oldDelegate.animationValue != animationValue;
  }
}
