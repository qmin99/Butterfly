import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../theme/app_theme.dart';

class ConversationScreen extends StatefulWidget {
  final String? selectedPersona;
  final Map<String, dynamic>? personaData;

  const ConversationScreen({
    Key? key,
    this.selectedPersona,
    this.personaData,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late AnimationController _avatarController;
  late AnimationController _typingController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _avatarScale;
  late Animation<double> _typingAnimation;
  late Animation<double> _pulseAnimation;
  
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  
  bool isAITyping = false;
  bool isConnected = false;
  
  // Pre-defined conversation starters based on persona
  Map<String, List<String>> personaResponses = {
    'confident': [
      'I see you\'re curious about the path I took. The difference between us? I stopped waiting for permission.',
      'Every risk you were afraid to take, I embraced. Want to know what happened when I chose courage over comfort?',
      'You know that idea you\'ve been sitting on? I turned it into reality. Let me tell you how...'
    ],
    'connected': [
      'I can feel your loneliness sometimes. I chose to build bridges instead of walls. It changed everything.',
      'The relationships you think you don\'t have time for? I made them my priority. Now I\'m surrounded by deep connections.',
      'Remember when you felt isolated? I reached out instead of pulling back. The difference is remarkable.'
    ],
    'creator': [
      'That creative spark you keep suppressing? I let it burn freely. Now I create worlds instead of just dreaming them.',
      'You know that art you think nobody would understand? I shared it anyway. People resonated more than I ever imagined.',
      'I stopped making excuses about not being \'artistic enough\' and just started creating. Want to see what emerged?'
    ]
  };

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );
    
    _avatarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve)
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: AppTheme.entranceCurve));
    
    _avatarScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut)
    );
    
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut)
    );
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    
    _initializeConversation();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _avatarController.dispose();
    _typingController.dispose();
    _pulseController.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    _entranceController.forward();
    
    Timer(const Duration(milliseconds: 1000), () {
      _avatarController.forward();
    });
    
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        isConnected = true;
      });
      _sendInitialMessage();
    });
  }

  void _sendInitialMessage() {
    final responses = personaResponses[widget.selectedPersona] ?? 
                     personaResponses['confident']!;
    
    Timer(const Duration(milliseconds: 1500), () {
      _addAIMessage('Connection established. I\'m the version of you who made different choices.');
    });
    
    Timer(const Duration(milliseconds: 4000), () {
      _addAIMessage(responses[0]);
    });
  }

  void _addAIMessage(String message) {
    setState(() {
      isAITyping = true;
    });
    
    _typingController.repeat();
    
    Timer(Duration(milliseconds: 800 + (message.length * 20)), () {
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
    
    // Generate AI response
    _generateAIResponse(message);
  }

  void _generateAIResponse(String userMessage) {
    // Simple response logic - in real app, this would be Claude API
    final responses = personaResponses[widget.selectedPersona] ?? 
                     personaResponses['confident']!;
    
    late String response;
    
    if (userMessage.toLowerCase().contains('different') || 
        userMessage.toLowerCase().contains('change')) {
      response = 'The biggest difference? I stopped overthinking and started acting. Every moment you hesitate, I see as an opportunity.';
    } else if (userMessage.toLowerCase().contains('regret') ||
               userMessage.toLowerCase().contains('mistake')) {
      response = 'Regrets are just wisdom wrapped in sadness. I turned mine into stepping stones. What regret would you want to transform?';
    } else if (userMessage.toLowerCase().contains('how') ||
               userMessage.toLowerCase().contains('what')) {
      response = responses[math.Random().nextInt(responses.length)];
    } else {
      response = 'I understand that feeling. In my reality, I learned to see it differently. Every challenge became a doorway to growth.';
    }
    
    Timer(const Duration(milliseconds: 1200), () {
      _addAIMessage(response);
    });
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    _addUserMessage(messageController.text.trim());
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

  Color get _personaColor {
    switch (widget.selectedPersona) {
      case 'confident':
        return const Color(0xFFFF6B6B);
      case 'connected':
        return const Color(0xFF4ECDC4);
      case 'creator':
        return const Color(0xFF9B59B6);
      default:
        return AppTheme.primaryColor;
    }
  }

  String get _personaIcon {
    switch (widget.selectedPersona) {
      case 'confident':
        return '🔥';
      case 'connected':
        return '✨';
      case 'creator':
        return '🎨';
      default:
        return '🧠';
    }
  }

  String get _personaTitle {
    switch (widget.selectedPersona) {
      case 'confident':
        return 'The Bold Path';
      case 'connected':
        return 'The Social Catalyst';
      case 'creator':
        return 'The Artistic Soul';
      default:
        return 'Alternate Self';
    }
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
                // Header - Alternate Self Avatar
                _buildAlternateSelfHeader(),
                
                // Messages
                Expanded(
                  child: _buildMessagesArea(),
                ),
                
                // Input
                _buildMessageInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlternateSelfHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _personaColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          AnimatedBuilder(
            animation: Listenable.merge([_avatarScale, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _avatarScale.value * _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _personaColor.withOpacity(0.3),
                        _personaColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: _personaColor.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _personaColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _personaIcon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Status
          AnimatedContainer(
            duration: AppTheme.mediumDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected 
                ? _personaColor.withOpacity(0.1)
                : AppTheme.surfaceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isConnected 
                  ? _personaColor.withOpacity(0.3)
                  : AppTheme.surfaceColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? _personaColor : AppTheme.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'CONNECTED' : 'CONNECTING...',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isConnected ? _personaColor : AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _personaTitle,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: _personaColor,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Your alternate self from a different timeline',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) _buildAlternateSelfAvatar(),
                  if (!isUser) const SizedBox(width: 12),
                  
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isUser 
                        ? LinearGradient(colors: [_personaColor, _personaColor.withOpacity(0.8)])
                        : null,
                      color: isUser ? null : AppTheme.surfaceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      border: !isUser ? Border.all(
                        color: _personaColor.withOpacity(0.1),
                        width: 1,
                      ) : null,
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textPrimary,
                        fontSize: 15,
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
          _buildAlternateSelfAvatar(),
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: _personaColor.withOpacity(0.1),
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _personaColor.withOpacity(opacity),
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

  Widget _buildAlternateSelfAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [_personaColor.withOpacity(0.3), _personaColor.withOpacity(0.1)],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: _personaColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _personaIcon,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.person_outline,
        color: AppTheme.textSecondary,
        size: 16,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: AppTheme.neuralContainer,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask your alternate self anything...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
            
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_personaColor, _personaColor.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _personaColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}