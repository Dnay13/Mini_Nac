import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../utils/formatters.dart';

class NetworkGauge extends StatefulWidget {
  final double value;
  final double maxValue;
  final String unit;
  final String title;
  final Color? color;
  final bool showNeedle;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const NetworkGauge({
    super.key,
    required this.value,
    this.maxValue = 100.0,
    this.unit = 'Mbps',
    this.title = 'Velocidad',
    this.color,
    this.showNeedle = true,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onTap,
  });

  @override
  State<NetworkGauge> createState() => _NetworkGaugeState();
}

class _NetworkGaugeState extends State<NetworkGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: _getRotationAngle(widget.value),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(NetworkGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _valueAnimation = Tween<double>(
        begin: _valueAnimation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _rotationAnimation = Tween<double>(
        begin: _rotationAnimation.value,
        end: _getRotationAngle(widget.value),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getRotationAngle(double value) {
    final percentage = (value / widget.maxValue).clamp(0.0, 1.0);
    return (percentage * 180) - 90; // -90 to 90 degrees
  }

  Color _getGaugeColor(double value) {
    final percentage = (value / widget.maxValue).clamp(0.0, 1.0);
    if (percentage <= 0.5) {
      return AppColors.networkOptimal;
    } else if (percentage <= 0.8) {
      return AppColors.networkModerate;
    } else {
      return AppColors.networkSaturated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.title.isNotEmpty) ...[
              Text(
                widget.title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: NetworkGaugePainter(
                      value: _valueAnimation.value,
                      maxValue: widget.maxValue,
                      color: widget.color ?? _getGaugeColor(_valueAnimation.value),
                      showNeedle: widget.showNeedle,
                      showLabels: widget.showLabels,
                      needleRotation: _rotationAnimation.value,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _valueAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Text(
                      '${_valueAnimation.value.toStringAsFixed(1)} ${widget.unit}',
                      style: AppTextStyles.metricLarge.copyWith(
                        color: widget.color ?? _getGaugeColor(_valueAnimation.value),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'de ${widget.maxValue.toStringAsFixed(0)} ${widget.unit}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;
  final bool showNeedle;
  final bool showLabels;
  final double needleRotation;

  NetworkGaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.showNeedle,
    required this.showLabels,
    required this.needleRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Dibujar arco de fondo
    _drawBackgroundArc(canvas, center, radius);
    
    // Dibujar arco de valor
    _drawValueArc(canvas, center, radius);
    
    // Dibujar etiquetas
    if (showLabels) {
      _drawLabels(canvas, center, radius);
    }
    
    // Dibujar aguja
    if (showNeedle) {
      _drawNeedle(canvas, center, radius);
    }
    
    // Dibujar centro
    _drawCenter(canvas, center);
  }

  void _drawBackgroundArc(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // -90 degrees
      math.pi, // 180 degrees
      false,
      paint,
    );
  }

  void _drawValueArc(Canvas canvas, Offset center, double radius) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final sweepAngle = math.pi * percentage;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // -90 degrees
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Dibujar etiquetas cada 25%
    for (int i = 0; i <= 4; i++) {
      final percentage = i * 0.25;
      final angle = -math.pi / 2 + (math.pi * percentage);
      final labelValue = (maxValue * percentage).toStringAsFixed(0);
      
      // Posición de la etiqueta
      final labelRadius = radius + 15;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);
      
      textPainter.text = TextSpan(
        text: labelValue,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textLight,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      
      textPainter.paint(
        canvas,
        Offset(
          labelX - textPainter.width / 2,
          labelY - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final needleLength = radius * 0.8;
    final needleWidth = 3.0;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = needleWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleRotation * math.pi / 180);
    
    // Dibujar aguja
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, -needleLength),
      paint,
    );
    
    // Dibujar punta de la aguja
    final tipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, -needleLength);
    path.lineTo(-6, -needleLength + 12);
    path.lineTo(6, -needleLength + 12);
    path.close();
    
    canvas.drawPath(path, tipPaint);
    
    canvas.restore();
  }

  void _drawCenter(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, paint);
    
    // Círculo interior
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, innerPaint);
  }

  @override
  bool shouldRepaint(covariant NetworkGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.maxValue != maxValue ||
           oldDelegate.color != color ||
           oldDelegate.showNeedle != showNeedle ||
           oldDelegate.showLabels != showLabels ||
           oldDelegate.needleRotation != needleRotation;
  }
}

// Widget de velocímetro con indicadores de upload/download
class NetworkSpeedGauge extends StatelessWidget {
  final double downloadSpeed;
  final double uploadSpeed;
  final double maxSpeed;
  final VoidCallback? onTap;

  const NetworkSpeedGauge({
    super.key,
    required this.downloadSpeed,
    required this.uploadSpeed,
    this.maxSpeed = 100.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Velocímetro principal (download)
        Expanded(
          flex: 3,
          child: NetworkGauge(
            value: downloadSpeed,
            maxValue: maxSpeed,
            title: 'Descarga',
            unit: 'Mbps',
            onTap: onTap,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Indicadores de upload y download
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSpeedIndicator(
              'Descarga',
              downloadSpeed,
              Icons.download,
              AppColors.success,
            ),
            _buildSpeedIndicator(
              'Subida',
              uploadSpeed,
              Icons.upload,
              AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedIndicator(
    String label,
    double speed,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          '${speed.toStringAsFixed(1)} Mbps',
          style: AppTextStyles.metricSmall.copyWith(
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
