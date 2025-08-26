import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class Brain3DWidget extends StatefulWidget {
  final double progress;
  final bool isComplete;

  const Brain3DWidget({
    Key? key,
    required this.progress,
    this.isComplete = false,
  }) : super(key: key);

  @override
  State<Brain3DWidget> createState() => _Brain3DWidgetState();
}

class _Brain3DWidgetState extends State<Brain3DWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _synapseController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _synapseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _synapseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear)
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    
    _synapseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _synapseController, curve: Curves.linear)
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _synapseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _rotationAnimation,
            _pulseAnimation,
            _synapseAnimation,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: Brain3DPainter(
                progress: widget.progress,
                rotation: _rotationAnimation.value,
                pulse: _pulseAnimation.value,
                synapseProgress: _synapseAnimation.value,
                isComplete: widget.isComplete,
              ),
            );
          },
        ),
      ),
    );
  }
}

class Brain3DPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final double pulse;
  final double synapseProgress;
  final bool isComplete;

  Brain3DPainter({
    required this.progress,
    required this.rotation,
    required this.pulse,
    required this.synapseProgress,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.3;
    
    // Background glow
    _drawBackgroundGlow(canvas, center, baseRadius);
    
    // Main brain structure
    _drawBrainCore(canvas, center, baseRadius);
    
    // Neural networks
    _drawNeuralNetworks(canvas, center, baseRadius);
    
    // Synapses
    _drawSynapses(canvas, center, baseRadius);
    
    // Outer energy field
    if (isComplete) {
      _drawEnergyField(canvas, center, baseRadius);
    }
    
    // Central consciousness point
    _drawConsciousnessCore(canvas, center);
  }

  void _drawBackgroundGlow(Canvas canvas, Offset center, double radius) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.1 * progress),
          AppTheme.accentColor.withOpacity(0.05 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2));
    
    canvas.drawCircle(center, radius * 2, glowPaint);
  }

  void _drawBrainCore(Canvas canvas, Offset center, double radius) {
    // Left hemisphere
    final leftHemisphere = Path();
    final leftCenter = Offset(center.dx - radius * 0.2, center.dy);
    
    for (int i = 0; i <= 180; i++) {
      final angle = (i * math.pi / 180) + rotation * 0.1;
      final currentRadius = radius * 0.8 * (1 + 0.1 * math.sin(angle * 3)) * pulse;
      final x = leftCenter.dx + currentRadius * math.cos(angle);
      final y = leftCenter.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        leftHemisphere.moveTo(x, y);
      } else {
        leftHemisphere.lineTo(x, y);
      }
    }
    leftHemisphere.close();

    // Right hemisphere
    final rightHemisphere = Path();
    final rightCenter = Offset(center.dx + radius * 0.2, center.dy);
    
    for (int i = 0; i <= 180; i++) {
      final angle = (i * math.pi / 180) + rotation * 0.1;
      final currentRadius = radius * 0.8 * (1 + 0.1 * math.sin(angle * 3)) * pulse;
      final x = rightCenter.dx + currentRadius * math.cos(angle + math.pi);
      final y = rightCenter.dy + currentRadius * math.sin(angle + math.pi);
      
      if (i == 0) {
        rightHemisphere.moveTo(x, y);
      } else {
        rightHemisphere.lineTo(x, y);
      }
    }
    rightHemisphere.close();

    // Paint hemispheres
    final brainPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.3 * progress),
          AppTheme.accentColor.withOpacity(0.2 * progress),
          AppTheme.primaryColor.withOpacity(0.1 * progress),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(leftHemisphere, brainPaint);
    canvas.drawPath(rightHemisphere, brainPaint);

    // Brain ridges/folds
    _drawBrainFolds(canvas, leftCenter, rightCenter, radius);
  }

  void _drawBrainFolds(Canvas canvas, Offset leftCenter, Offset rightCenter, double radius) {
    final foldPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.6 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Left hemisphere folds
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + rotation * 0.2;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.75;
      
      final startX = leftCenter.dx + startRadius * math.cos(angle);
      final startY = leftCenter.dy + startRadius * math.sin(angle);
      final endX = leftCenter.dx + endRadius * math.cos(angle);
      final endY = leftCenter.dy + endRadius * math.sin(angle);
      
      final path = Path();
      path.moveTo(startX, startY);
      
      // Create wavy line
      for (int j = 1; j <= 10; j++) {
        final t = j / 10.0;
        final x = startX + (endX - startX) * t;
        final y = startY + (endY - startY) * t + 
                  math.sin(t * math.pi * 4 + synapseProgress * 2 * math.pi) * 5;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, foldPaint);
    }

    // Right hemisphere folds
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + rotation * 0.2;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.75;
      
      final startX = rightCenter.dx + startRadius * math.cos(angle);
      final startY = rightCenter.dy + startRadius * math.sin(angle);
      final endX = rightCenter.dx + endRadius * math.cos(angle);
      final endY = rightCenter.dy + endRadius * math.sin(angle);
      
      final path = Path();
      path.moveTo(startX, startY);
      
      for (int j = 1; j <= 10; j++) {
        final t = j / 10.0;
        final x = startX + (endX - startX) * t;
        final y = startY + (endY - startY) * t + 
                  math.sin(t * math.pi * 4 + synapseProgress * 2 * math.pi) * 5;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, foldPaint);
    }
  }

  void _drawNeuralNetworks(Canvas canvas, Offset center, double radius) {
    final networkPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.4 * progress)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Create neural network connections
    for (int i = 0; i < 50; i++) {
      final angle1 = (i * math.pi * 2 / 50) + rotation;
      final angle2 = ((i + 1) * math.pi * 2 / 50) + rotation;
      
      final radius1 = radius * (0.4 + 0.3 * math.sin(synapseProgress * 2 * math.pi + i));
      final radius2 = radius * (0.4 + 0.3 * math.cos(synapseProgress * 2 * math.pi + i));
      
      final x1 = center.dx + radius1 * math.cos(angle1);
      final y1 = center.dy + radius1 * math.sin(angle1);
      final x2 = center.dx + radius2 * math.cos(angle2);
      final y2 = center.dy + radius2 * math.sin(angle2);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), networkPaint);
    }
  }

  void _drawSynapses(Canvas canvas, Offset center, double radius) {
    // Neural firing synapses
    for (int i = 0; i < 30; i++) {
      final angle = (i * math.pi * 2 / 30) + rotation * 2;
      final synapseRadius = radius * (0.5 + 0.3 * math.sin(synapseProgress * 2 * math.pi + i));
      
      final x = center.dx + synapseRadius * math.cos(angle);
      final y = center.dy + synapseRadius * math.sin(angle);
      
      final synapseOpacity = (math.sin(synapseProgress * 4 * math.pi + i) + 1) / 2;
      
      final synapsePaint = Paint()
        ..color = AppTheme.accentColor.withOpacity(synapseOpacity * progress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 3 * pulse, synapsePaint);
      
      // Synapse glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.accentColor.withOpacity(synapseOpacity * 0.8 * progress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 8));
      
      canvas.drawCircle(Offset(x, y), 8 * pulse, glowPaint);
    }
  }

  void _drawEnergyField(Canvas canvas, Offset center, double radius) {
    final energyPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Outer energy rings
    for (int ring = 0; ring < 3; ring++) {
      final ringRadius = radius * (1.2 + ring * 0.1) * pulse;
      final ringOpacity = (1.0 - ring * 0.3) * progress;
      
      final ringPaint = Paint()
        ..color = AppTheme.primaryColor.withOpacity(ringOpacity)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, ringRadius, ringPaint);
    }
  }

  void _drawConsciousnessCore(Canvas canvas, Offset center) {
    // Central bright point representing consciousness
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9 * progress),
          AppTheme.primaryColor.withOpacity(0.7 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 15));
    
    canvas.drawCircle(center, 15 * pulse, corePaint);
    
    // Inner core
    final innerCorePaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * progress)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 5 * pulse, innerCorePaint);
  }

  @override
  bool shouldRepaint(Brain3DPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.rotation != rotation ||
           oldDelegate.pulse != pulse ||
           oldDelegate.synapseProgress != synapseProgress ||
           oldDelegate.isComplete != isComplete;
  }
}