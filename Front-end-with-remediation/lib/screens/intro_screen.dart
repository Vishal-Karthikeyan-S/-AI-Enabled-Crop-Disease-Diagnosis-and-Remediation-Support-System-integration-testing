import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';
import '../providers/language_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentMessageIndex = 0;
  bool _isPlaying = false;

  final List<Map<String, String>> _introMessages = [
    {
      'en': 'Welcome to Crop Disease Detection App',
      'hi': 'फसल रोग पहचान ऐप में आपका स्वागत है',
      'te': 'పంట వ్యాధి గుర్తింపు యాప్‌లోకి స్వాగతం',
      'ta': 'பயிர் நோய் கண்டறிதல் செயலிக்கு வரவேற்கிறோம்',
    },
    {
      'en': 'Detect crop diseases using your camera',
      'hi': 'अपने कैमरे का उपयोग करके फसल रोगों का पता लगाएं',
      'te': 'మీ కెమెరాను ఉపయోగించి పంట వ్యాధులను గుర్తించండి',
      'ta': 'உங்கள் கேமராவைப் பயன்படுத்தி பயிர் நோய்களைக் கண்டறியுங்கள்',
    },
    {
      'en': 'Get treatment recommendations instantly',
      'hi': 'तुरंत उपचार सिफारिशें प्राप्त करें',
      'te': 'వెంటనే చికిత్స సిఫార్సులను పొందండి',
      'ta': 'உடனடியாக சிகிச்சை பரிந்துரைகளைப் பெறுங்கள்',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIntro();
    });
  }

  Future<void> _startIntro() async {
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = langProvider.currentLocale.languageCode;

    setState(() => _isPlaying = true);

    for (int i = 0; i < _introMessages.length; i++) {
      if (!mounted) return;

      setState(() => _currentMessageIndex = i);
      _animationController.reset();
      _animationController.forward();

      // Speak the message
      final message = _introMessages[i][lang] ?? _introMessages[i]['en']!;
      await ttsService.speak(message, languageCode: lang);

      // Wait a bit before next message
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Navigate to login after intro
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skipIntro() {
    final ttsService = Provider.of<TtsService>(context, listen: false);
    ttsService.stop();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.currentLocale.languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Animated Message
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Text(
                              _introMessages[_currentMessageIndex][lang] ??
                                  _introMessages[_currentMessageIndex]['en']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Progress Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _introMessages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentMessageIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentMessageIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Skip Button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipIntro,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Speaking Indicator
            if (_isPlaying)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Speaking...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
