import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/brain_3d_widget.dart';

class PersonaCreationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;

  const PersonaCreationScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  State<PersonaCreationScreen> createState() => _PersonaCreationScreenState();
}

class _PersonaCreationScreenState extends State<PersonaCreationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late AnimationController _brainController;
  late AnimationController _typingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _brainOpacity;
  late Animation<double> _typingAnimation;
  
  List<Map<String, dynamic>> messages = [];
  List<Map<String, String>> questions = [
    {
      'question': 'What drives you most in life?',
      'type': 'motivation'
    },
    {
      'question': 'How do you handle difficult decisions?',
      'type': 'decision_style'
    },
    {
      'question': 'What\'s your biggest unfulfilled dream?',
      'type': 'aspiration'
    },
    {
      'question': 'How do you connect with others?',
      'type': 'social_style'
    }
  ];
  
  int currentQuestionIndex = 0;
  bool isAITyping = false;
  bool isComplete = false;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  
  Map<String, String> personaTraits = {};

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );
    
    _brainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve)
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve));
    
    _brainOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brainController, curve: Curves.easeIn)
    );
    
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut)
    );
    
    _startIntroSequence();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _brainController.dispose();
    _typingController.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _startIntroSequence() {
    _entranceController.forward();
    
    Timer(const Duration(milliseconds: 800), () {
      _brainController.forward();
      _addAIMessage("I'm going to understand who you are at your core.");
    });
    
    Timer(const Duration(milliseconds: 2000), () {
      _addAIMessage("Let's discover your authentic self together.");
    });
    
    Timer(const Duration(milliseconds: 3500), () {
      _askNextQuestion();
    });
  }

  void _addAIMessage(String message) {
    setState(() {
      isAITyping = true;
    });
    
    _typingController.repeat();
    
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        messages.add({
          'text': message,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        isAITyping = false;
      });
      
      _typingController.stop();
      _scrollToBottom();
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    
    _scrollToBottom();
    messageController.clear();
    
    // Process the answer
    if (currentQuestionIndex < questions.length) {
      personaTraits[questions[currentQuestionIndex]['type']!] = message;
    }
  }

  void _askNextQuestion() {
    if (currentQuestionIndex < questions.length) {
      Timer(const Duration(milliseconds: 800), () {
        _addAIMessage(questions[currentQuestionIndex]['question']!);
        currentQuestionIndex++;
      });
    } else {
      _completePersonaCreation();
    }
  }

  void _completePersonaCreation() {
    Timer(const Duration(milliseconds: 1000), () {
      _addAIMessage("Your neural pattern is taking shape...");
    });
    
    Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        isComplete = true;
      });
    });
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    _addUserMessage(messageController.text.trim());
    
    Timer(const Duration(milliseconds: 500), () {
      _askNextQuestion();
    });
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: AppTheme.mediumDuration,
          curve: AppTheme.primaryCurve,
        );
      }
    });
  }

  void _proceedToNextStage() {
    widget.onNext({
      'persona': personaTraits,
      'type': 'persona_created',
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: AppTheme.primaryGradient,
                        ).createShader(bounds),
                        child: Text(
                          'NEXUS',
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Neural Identity Mapping',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                
                // 3D Brain Visualization
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _brainOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _brainOpacity.value,
                        child: Brain3DWidget(
                          progress: _brainController.value,
                          isComplete: isComplete,
                        ),
                      );
                    },
                  ),
                ),
                
                // Chat Interface
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.surfaceColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Messages
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: messages.length + (isAITyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length && isAITyping) {
                                  return _buildTypingIndicator();
                                }
                                return _buildMessage(messages[index]);
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Input or Complete Button
                          if (isComplete)
                            _buildCompleteButton()
                          else
                            _buildMessageInput(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    
    return TweenAnimationBuilder(
      duration: AppTheme.mediumDuration,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isUser) _buildAIAvatar(),
                  if (!isUser) const SizedBox(width: 12),
                  
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isUser 
                        ? const LinearGradient(colors: AppTheme.primaryGradient)
                        : null,
                      color: isUser ? null : AppTheme.surfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: !isUser ? Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        width: 1,
                      ) : null,
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  if (isUser) const SizedBox(width: 12),
                  if (isUser) _buildUserAvatar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAIAvatar(),
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final opacity = (math.sin((_typingAnimation.value + delay) * 2 * math.pi) + 1) / 2;
                    
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_outlined,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.person_outline,
        color: AppTheme.textSecondary,
        size: 16,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: AppTheme.primaryButton,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return TweenAnimationBuilder(
      duration: AppTheme.slowDuration,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: _proceedToNextStage,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: AppTheme.primaryButton,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Construct Reality Map',
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
        );
      },
    );
  }
}