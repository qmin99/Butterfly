import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../theme/app_theme.dart';

class TimelineScreen extends StatefulWidget {
  final Map<String, dynamic>? personaData;
  final Function(Map<String, dynamic>) onNext;
  final Function(String) onSelectPersona;

  const TimelineScreen({
    Key? key,
    this.personaData,
    required this.onNext,
    required this.onSelectPersona,
  }) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late AnimationController _selectionController;
  late AnimationController _hologramController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _hologramAnimation;
  
  String? selectedPersona;
  bool showComparison = false;
  
  // Generated personas based on AI analysis
  List<Map<String, dynamic>> alternatePersonas = [
    {
      'id': 'confident',
      'title': 'The Bold Path',
      'subtitle': 'Courage over comfort',
      'description': 'A version who took risks and embraced uncertainty',
      'probability': 0.87,
      'impact': 'high',
      'color': const Color(0xFFFF6B6B),
      'icon': '🔥',
      'traits': ['Leader', 'Risk-taker', 'Influential'],
      'timeline': {
        '1_year': 'Started own venture',
        '5_years': 'Industry recognition',
        '10_years': 'Changed lives of thousands'
      }
    },
    {
      'id': 'connected', 
      'title': 'The Social Catalyst',
      'subtitle': 'Community builder',
      'description': 'A version who prioritized deep human connections',
      'probability': 0.73,
      'impact': 'medium',
      'color': const Color(0xFF4ECDC4),
      'icon': '✨',
      'traits': ['Empathetic', 'Networker', 'Inspiring'],
      'timeline': {
        '1_year': 'Built meaningful relationships',
        '5_years': 'Community leader',
        '10_years': 'Social movement pioneer'
      }
    },
    {
      'id': 'creator',
      'title': 'The Artistic Soul', 
      'subtitle': 'Creative expression',
      'description': 'A version who followed pure creative instincts',
      'probability': 0.91,
      'impact': 'transformative',
      'color': const Color(0xFF9B59B6),
      'icon': '🎨',
      'traits': ['Visionary', 'Original', 'Passionate'],
      'timeline': {
        '1_year': 'Pursued artistic calling',
        '5_years': 'Acclaimed creator',
        '10_years': 'Cultural icon'
      }
    }
  ];

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: AppTheme.mediumDuration,
      vsync: this,
    );
    
    _hologramController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve)
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve));
    
    _hologramAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hologramController, curve: Curves.linear)
    );
    
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _selectionController.dispose();
    _hologramController.dispose();
    super.dispose();
  }

  void _selectPersona(String personaId) {
    HapticFeedback.mediumImpact();
    
    setState(() {
      selectedPersona = personaId;
      showComparison = true;
    });
    
    widget.onSelectPersona(personaId);
    _selectionController.forward();
    
    Timer(const Duration(seconds: 2), () {
      widget.onNext({
        'selectedPersona': personaId,
        'comparison_ready': true,
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
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  Text(
                    'Alternate Realities Detected',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Each choice creates a different you',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Personas Grid
                  Expanded(
                    child: showComparison 
                      ? _buildComparisonView()
                      : _buildPersonaSelection(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonaSelection() {
    return ListView.builder(
      itemCount: alternatePersonas.length,
      itemBuilder: (context, index) {
        final persona = alternatePersonas[index];
        
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + index * 200),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: _buildPersonaCard(persona),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPersonaCard(Map<String, dynamic> persona) {
    final isSelected = selectedPersona == persona['id'];
    
    return GestureDetector(
      onTap: () => _selectPersona(persona['id']),
      child: AnimatedContainer(
        duration: AppTheme.mediumDuration,
        curve: AppTheme.primaryCurve,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.02 : 1.0)
          ..translate(0.0, isSelected ? -4.0 : 0.0),
        child: Container(
          decoration: AppTheme.neuralContainer,
          child: Stack(
            children: [
              // Holographic effect
              AnimatedBuilder(
                animation: _hologramAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: HolographicPainter(
                      color: persona['color'],
                      animation: _hologramAnimation.value,
                      opacity: 0.1,
                    ),
                  );
                },
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Avatar/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            persona['color'].withOpacity(0.3),
                            persona['color'].withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: persona['color'].withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          persona['icon'],
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            persona['title'],
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            persona['subtitle'],
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: persona['color'],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            persona['description'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Traits
                          Wrap(
                            spacing: 8,
                            children: (persona['traits'] as List<String>).map((trait) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: persona['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: persona['color'].withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  trait,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: persona['color'],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Probability indicator
                    Column(
                      children: [
                        Text(
                          '${(persona['probability'] * 100).round()}%',
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: persona['color'],
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          'PROBABILITY',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonView() {
    final selectedPersonaData = alternatePersonas.firstWhere(
      (p) => p['id'] == selectedPersona,
      orElse: () => alternatePersonas[0],
    );
    
    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectionController.value,
          child: Column(
            children: [
              // Current vs Alternate
              Text(
                'Reality Comparison',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              Expanded(
                child: Row(
                  children: [
                    // Current Reality
                    Expanded(
                      child: _buildRealityColumn(
                        title: 'Current Path',
                        icon: '👤',
                        color: AppTheme.textSecondary,
                        description: 'The reality you\'ve lived',
                        isAlternate: false,
                      ),
                    ),
                    
                    // VS Separator
                    Container(
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.compare_arrows,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'VS',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    
                    // Alternate Reality
                    Expanded(
                      child: _buildRealityColumn(
                        title: selectedPersonaData['title'],
                        icon: selectedPersonaData['icon'],
                        color: selectedPersonaData['color'],
                        description: selectedPersonaData['description'],
                        timeline: selectedPersonaData['timeline'],
                        isAlternate: true,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Continue Button
              GestureDetector(
                onTap: () => widget.onNext({
                  'selectedPersona': selectedPersona,
                  'ready_to_converse': true,
                }),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppTheme.primaryButton,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connect with Alternate Self',
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealityColumn({
    required String title,
    required String icon,
    required Color color,
    required String description,
    required bool isAlternate,
    Map<String, String>? timeline,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isAlternate 
                ? RadialGradient(
                    colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                  )
                : null,
              color: isAlternate ? null : AppTheme.surfaceColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: isAlternate ? color : AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          
          if (timeline != null) ...[
            const SizedBox(height: 20),
            
            // Timeline
            ...timeline.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

class HolographicPainter extends CustomPainter {
  final Color color;
  final double animation;
  final double opacity;

  HolographicPainter({
    required this.color,
    required this.animation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Scanning lines
    for (int i = 0; i < 5; i++) {
      final y = (animation + i * 0.2) % 1.0 * size.height;
      paint.color = color.withOpacity(opacity * (math.sin(animation * 2 * math.pi + i) + 1) / 2);
      
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HolographicPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}