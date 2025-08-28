import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/brain_3d_widget.dart';

class PersonaCreationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;

  const PersonaCreationScreen({Key? key, required this.onNext})
    : super(key: key);

  @override
  State<PersonaCreationScreen> createState() => _PersonaCreationScreenState();
}

class _PersonaCreationScreenState extends State<PersonaCreationScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _brainController;
  late AnimationController _questionController;
  late AnimationController _inputController;
  late AnimationController _dataStreamController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _brainOpacity;
  late Animation<double> _questionFade;
  late Animation<double> _inputScale;
  late Animation<double> _dataStreamAnimation;

  List<String> questions = [
    'What drives you most in life?',
    'How do you handle difficult decisions?',
    'What\'s your biggest unfulfilled dream?',
    'How do you connect with others?',
  ];

  int currentQuestionIndex = -1;
  bool isComplete = false;
  TextEditingController messageController = TextEditingController();
  FocusNode _focusNode = FocusNode();

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

    _questionController = AnimationController(
      duration: AppTheme.mediumDuration,
      vsync: this,
    );

    _inputController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _dataStreamController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: AppTheme.entranceCurve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: AppTheme.entranceCurve,
          ),
        );

    _brainOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _brainController, curve: Curves.easeIn));

    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeIn),
    );

    _inputScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeOutCubic),
    );

    _dataStreamAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dataStreamController, curve: Curves.easeOut),
    );

    _startIntroSequence();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _brainController.dispose();
    _questionController.dispose();
    _inputController.dispose();
    _dataStreamController.dispose();
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startIntroSequence() {
    _entranceController.forward();

    Timer(const Duration(milliseconds: 800), () {
      _brainController.forward();
      _showNextQuestion();
    });
  }

  void _showNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      _questionController.reverse(from: 1.0);
      Timer(AppTheme.mediumDuration, () {
        setState(() {
          currentQuestionIndex++;
        });
        _questionController.forward(from: 0.0);
      });
    } else {
      _completePersonaCreation();
    }
  }

  void _completePersonaCreation() {
    setState(() {
      isComplete = true;
    });

    Timer(const Duration(seconds: 2), () {
      widget.onNext({'persona': personaTraits, 'type': 'persona_created'});
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    _dataStreamController.forward(from: 0.0).then((_) {
      _dataStreamController.reset();
    });

    personaTraits[questions[currentQuestionIndex]] = text.trim();
    messageController.clear();

    _showNextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _dataStreamAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                // Brain Visualization
                Center(
                  child: AnimatedBuilder(
                    animation: _brainOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _brainOpacity.value,
                        child: Brain3DWidget(
                          progress:
                              (currentQuestionIndex + 1) / questions.length,
                          isComplete: isComplete,
                        ),
                      );
                    },
                  ),
                ),

                // Data Stream Effect
                if (_dataStreamController.isAnimating)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height:
                            MediaQuery.of(context).size.height *
                            (1.0 - _dataStreamAnimation.value),
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.0),
                              AppTheme.primaryColor.withOpacity(
                                _dataStreamAnimation.value > 0.5
                                    ? 1.0
                                    : _dataStreamAnimation.value * 2,
                              ),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),

                // UI Overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 48.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: AppTheme.primaryGradient,
                          ).createShader(bounds),
                          child: Text(
                            'NEURAL IDENTITY MAPPING',
                            style: Theme.of(context).textTheme.displaySmall!
                                .copyWith(color: AppTheme.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Syncing mental pathways...',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),

                        const Spacer(),

                        // Interactive Area
                        isComplete
                            ? _buildCompletionMessage()
                            : _buildQuestionAndInput(),
                      ],
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

  Widget _buildQuestionAndInput() {
    return Column(
      children: [
        if (currentQuestionIndex >= 0 &&
            currentQuestionIndex < questions.length)
          FadeTransition(
            opacity: _questionFade,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                questions[currentQuestionIndex],
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        AnimatedBuilder(
          animation: _inputScale,
          builder: (context, child) {
            return ScaleTransition(
              scale: _inputScale,
              child: Container(
                decoration: AppTheme.neuralContainer,
                child: RawKeyboardListener(
                  focusNode: _focusNode,
                  onKey: (event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                        !event.isShiftPressed &&
                        event.runtimeType.toString() == 'RawKeyDownEvent') {
                      _sendMessage(messageController.text);
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Type your answer here...',
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          textInputAction:
                              TextInputAction.send, // ✅ Makes Enter = Send
                          onSubmitted: (text) =>
                              _sendMessage(text), // ✅ Sends message
                          maxLines: 1, // ✅ Prevents newlines
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _sendMessage(messageController.text),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          width: 44,
                          height: 44,
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
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompletionMessage() {
    return Column(
      children: [
        Text(
          'Neural Mapping Complete.',
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        TweenAnimationBuilder(
          duration: AppTheme.slowDuration,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: () => widget.onNext(personaTraits),
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
                          style: Theme.of(context).textTheme.headlineLarge!
                              .copyWith(
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
        ),
      ],
    );
  }
}
