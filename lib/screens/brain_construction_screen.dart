import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../theme/app_theme.dart';

class BrainConstructionScreen extends StatefulWidget {
  final Map<String, dynamic>? personaData;
  final Function(Map<String, dynamic>) onNext;

  const BrainConstructionScreen({
    Key? key,
    this.personaData,
    required this.onNext,
  }) : super(key: key);

  @override
  State<BrainConstructionScreen> createState() => _BrainConstructionScreenState();
}

class _BrainConstructionScreenState extends State<BrainConstructionScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late AnimationController _processingController;
  late AnimationController _matrixController;
  late AnimationController _completeController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _matrixAnimation;
  late Animation<double> _completeAnimation;
  
  List<String> processingStages = [
    'Analyzing neural pathways',
    'Mapping decision patterns',
    'Constructing alternate personas',
    'Generating timeline possibilities',
    'Reality matrix complete'
  ];
  
  int currentStage = 0;
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );
    
    _processingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _matrixController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _completeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve)
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut)
    );
    
    _matrixAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _matrixController, curve: Curves.linear)
    );
    
    _completeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completeController, curve: Curves.easeOut)
    );
    
    _startProcessingSequence();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _processingController.dispose();
    _matrixController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  void _startProcessingSequence() {
    _entranceController.forward();
    
    // Process through each stage
    for (int i = 0; i < processingStages.length; i++) {
      Timer(Duration(milliseconds: 1500 + i * 2000), () {
        if (mounted) {
          setState(() {
            currentStage = i;
          });
          
          if (i == processingStages.length - 1) {
            _completeProcessing();
          }
        }
      });
    }
  }

  void _completeProcessing() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isComplete = true;
      });
      _completeController.forward();
      
      Timer(const Duration(seconds: 3), () {
        widget.onNext({
          'processing_complete': true,
          'personas_generated': true,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Constructing Reality Matrix',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Neural Matrix Visualization
                Expanded(
                  flex: 3,
                  child: _buildNeuralMatrix(),
                ),
                
                const SizedBox(height: 40),
                
                // Processing Status
                Expanded(
                  flex: 1,
                  child: _buildProcessingStatus(),
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeuralMatrix() {
    return AnimatedBuilder(
      animation: _matrixAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: NeuralMatrixPainter(
            progress: currentStage / (processingStages.length - 1),
            matrixAnimation: _matrixAnimation.value,
            isComplete: isComplete,
            completeProgress: _completeAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildProcessingStatus() {
    return Column(
      children: [
        // Current stage indicator
        AnimatedSwitcher(
          duration: AppTheme.mediumDuration,
          child: Text(
            processingStages[currentStage],
            key: ValueKey(currentStage),
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Progress indicator
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedContainer(
            duration: AppTheme.slowDuration,
            width: 200 * (currentStage + 1) / processingStages.length,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppTheme.primaryGradient),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          '${((currentStage + 1) / processingStages.length * 100).round()}%',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        
        if (isComplete) ...[
          const SizedBox(height: 20),
          
          AnimatedBuilder(
            animation: _completeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _completeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reality Matrix Active',
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class NeuralMatrixPainter extends CustomPainter {
  final double progress;
  final double matrixAnimation;
  final bool isComplete;
  final double completeProgress;

  NeuralMatrixPainter({
    required this.progress,
    required this.matrixAnimation,
    required this.isComplete,
    required this.completeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Background energy field
    _drawEnergyField(canvas, center, size);
    
    // Neural grid
    _drawNeuralGrid(canvas, size);
    
    // Central processing core
    _drawProcessingCore(canvas, center, size);
    
    // Data streams
    _drawDataStreams(canvas, center, size);
    
    // Completion effects
    if (isComplete) {
      _drawCompletionEffects(canvas, center, size);
    }
  }

  void _drawEnergyField(Canvas canvas, Offset center, Size size) {
    final fieldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.1 * progress),
          AppTheme.accentColor.withOpacity(0.05 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(center: center, width: size.width, height: size.height));
    
    canvas.drawRect(Offset.zero & size, fieldPaint);
  }

  void _drawNeuralGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.2 * progress)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final gridSize = 40.0;
    final animationOffset = matrixAnimation * gridSize;
    
    // Vertical lines
    for (double x = -animationOffset; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Horizontal lines
    for (double y = -animationOffset; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    
    // Grid intersections
    _drawGridIntersections(canvas, size, gridSize, animationOffset);
  }

  void _drawGridIntersections(Canvas canvas, Size size, double gridSize, double offset) {
    final intersectionPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.6 * progress)
      ..style = PaintingStyle.fill;
    
    for (double x = -offset; x < size.width + gridSize; x += gridSize) {
      for (double y = -offset; y < size.height + gridSize; y += gridSize) {
        final pulseIntensity = (math.sin(matrixAnimation * 4 * math.pi + 
                               (x + y) / gridSize) + 1) / 2;
        
        final pulsePaint = Paint()
          ..color = AppTheme.primaryColor.withOpacity(pulseIntensity * 0.5 * progress)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 2, pulsePaint);
      }
    }
  }

  void _drawProcessingCore(Canvas canvas, Offset center, Size size) {
    final coreRadius = math.min(size.width, size.height) * 0.15;
    
    // Outer rings
    for (int i = 0; i < 3; i++) {
      final ringRadius = coreRadius * (1.0 + i * 0.3) * (1.0 + 0.1 * math.sin(matrixAnimation * 2 * math.pi));
      final ringOpacity = (1.0 - i * 0.2) * progress;
      
      final ringPaint = Paint()
        ..color = AppTheme.primaryColor.withOpacity(ringOpacity * 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, ringRadius, ringPaint);
    }
    
    // Core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9 * progress),
          AppTheme.primaryColor.withOpacity(0.7 * progress),
          AppTheme.accentColor.withOpacity(0.3 * progress),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));
    
    canvas.drawCircle(center, coreRadius, corePaint);
    
    // Rotating elements around core
    _drawRotatingElements(canvas, center, coreRadius);
  }

  void _drawRotatingElements(Canvas canvas, Offset center, double coreRadius) {
    final elementPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.8 * progress)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + matrixAnimation * 2 * math.pi;
      final elementRadius = coreRadius * 1.8;
      
      final x = center.dx + elementRadius * math.cos(angle);
      final y = center.dy + elementRadius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 4, elementPaint);
      
      // Connecting lines
      final linePaint = Paint()
        ..color = AppTheme.primaryColor.withOpacity(0.4 * progress)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(center, Offset(x, y), linePaint);
    }
  }

  void _drawDataStreams(Canvas canvas, Offset center, Size size) {
    final streamPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Horizontal streams
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.15);
      final streamProgress = (matrixAnimation + i * 0.2) % 1.0;
      final streamOpacity = (math.sin(streamProgress * math.pi) * progress).clamp(0.0, 1.0);
      
      streamPaint.shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppTheme.primaryColor.withOpacity(streamOpacity),
          Colors.transparent,
        ],
        stops: [0.0, streamProgress, 1.0],
      ).createShader(Rect.fromLTWH(0, y, size.width, 2));
      
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streamPaint);
    }
    
    // Vertical streams
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + i * 0.15);
      final streamProgress = (matrixAnimation + i * 0.3) % 1.0;
      final streamOpacity = (math.sin(streamProgress * math.pi) * progress).clamp(0.0, 1.0);
      
      streamPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppTheme.accentColor.withOpacity(streamOpacity),
          Colors.transparent,
        ],
        stops: [0.0, streamProgress, 1.0],
      ).createShader(Rect.fromLTWH(x, 0, 2, size.height));
      
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streamPaint);
    }
  }

  void _drawCompletionEffects(Canvas canvas, Offset center, Size size) {
    // Completion burst
    final burstPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(completeProgress),
          AppTheme.primaryColor.withOpacity(completeProgress * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * completeProgress));
    
    canvas.drawCircle(center, size.width * completeProgress * 0.3, burstPaint);
    
    // Success particles
    final particlePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(completeProgress)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final angle = i * math.pi * 2 / 20;
      final distance = size.width * 0.2 * completeProgress;
      
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 3 * completeProgress, particlePaint);
    }
  }

  @override
  bool shouldRepaint(NeuralMatrixPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.matrixAnimation != matrixAnimation ||
           oldDelegate.isComplete != isComplete ||
           oldDelegate.completeProgress != completeProgress;
  }
}