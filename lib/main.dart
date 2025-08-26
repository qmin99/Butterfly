import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/persona_creation_screen.dart';
import 'screens/brain_construction_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/conversation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(NexusApp());
}

class NexusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS - Reality Engine',
      theme: AppTheme.darkTheme,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with TickerProviderStateMixin {
  
  PageController _pageController = PageController();
  int _currentStage = 0;
  
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? personaData;
  String? selectedPersona;

  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut)
    );
    
    _transitionController.forward();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
void _nextStage(Map<String, dynamic>? data) {
  HapticFeedback.mediumImpact();
  
  if (data != null) {
    setState(() {
      if (data.containsKey('persona')) {
        personaData = data;
      }
      if (data.containsKey('selectedPersona')) {
        selectedPersona = data['selectedPersona'];
      }
    });
  }

  _pageController.nextPage(
    duration: const Duration(milliseconds: 1000),
    curve: Curves.easeInOut,
  );

  setState(() {
    _currentStage++;
  });
}


  void _previousStage() {
    if (_currentStage > 0) {
      HapticFeedback.lightImpact();
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      
      setState(() {
        _currentStage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.3, -0.5),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1A1A2E).withOpacity(0.8),
                    const Color(0xFF16213E).withOpacity(0.6),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
            
            // Main content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PersonaCreationScreen(onNext: _nextStage),
                BrainConstructionScreen(
                  personaData: personaData,
                  onNext: _nextStage,
                ),
                TimelineScreen(
                  personaData: personaData,
                  onNext: _nextStage,
                  onSelectPersona: (persona) {
                    selectedPersona = persona;
                  },
                ),
                ConversationScreen(
                  selectedPersona: selectedPersona,
                  personaData: personaData,
                ),
              ],
            ),
            
            // Stage indicator
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value * 0.6,
                    child: _buildStageIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentStage;
        final isCurrent = index == _currentStage;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 2,
            decoration: BoxDecoration(
              color: isActive 
                ? (isCurrent ? AppTheme.accentColor : AppTheme.primaryColor)
                : AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}