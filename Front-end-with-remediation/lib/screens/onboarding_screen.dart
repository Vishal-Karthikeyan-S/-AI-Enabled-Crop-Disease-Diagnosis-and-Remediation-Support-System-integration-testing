import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/speech_service.dart';
import '../providers/language_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Speak first slide after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakCurrentPage();
    });
  }

  void _speakCurrentPage() {
    final l10n = AppLocalizations.of(context)!;
    final speechService = Provider.of<SpeechService>(context, listen: false);
    final langCode = Provider.of<LanguageProvider>(context, listen: false)
        .currentLocale
        .languageCode;

    String text = "";
    switch (_currentPage) {
      case 0:
        text = "${l10n.welcomeTitle}. ${l10n.welcomeMessage}";
        break;
      case 1:
        text = "${l10n.onboardingStep1Title}. ${l10n.onboardingStep1Desc}";
        break;
      case 2:
        text = "${l10n.onboardingStep2Title}. ${l10n.onboardingStep2Desc}";
        break;
      case 3:
        text = "${l10n.onboardingStep3Title}. ${l10n.onboardingStep3Desc}";
        break;
      case 4:
        text = "${l10n.onboardingStep4Title}. ${l10n.onboardingStep4Desc}";
        break;
    }
    speechService.speak(text, langCode);
  }

  void _completeOnboarding() {
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    prefs.setFirstLaunch(false);
    prefs.setTutorialCompleted(true);
    // Requirement: show Login first, then navigate to Home.
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<OnboardingData> slides = [
      OnboardingData(
        title: l10n.welcomeTitle,
        desc: l10n.welcomeMessage,
        icon: Icons.agriculture,
        color: Colors.green,
      ),
      OnboardingData(
        title: l10n.onboardingStep1Title,
        desc: l10n.onboardingStep1Desc,
        icon: Icons.camera_alt,
        color: Colors.blue,
      ),
      OnboardingData(
        title: l10n.onboardingStep2Title,
        desc: l10n.onboardingStep2Desc,
        icon: Icons.wifi_off,
        color: Colors.orange,
      ),
      OnboardingData(
        title: l10n.onboardingStep3Title,
        desc: l10n.onboardingStep3Desc,
        icon: Icons.translate,
        color: Colors.purple,
      ),
      OnboardingData(
        title: l10n.onboardingStep4Title,
        desc: l10n.onboardingStep4Desc,
        icon: Icons.volume_up,
        color: Colors.red,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _speakCurrentPage();
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _buildPage(slides[index]);
            },
          ),
          // Top Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                l10n.skip,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == slides.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == slides.length - 1
                          ? l10n.getStarted
                          : l10n.next,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: 150,
            color: data.color,
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });
}
