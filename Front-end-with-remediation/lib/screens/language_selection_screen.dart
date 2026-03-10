import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final theme = Theme.of(context);

    // Hardcoded localization for the language screen
    final Map<String, String> welcomeTexts = {
      'en': 'Choose your language',
      'hi': 'अपनी भाषा चुनें',
      'te': 'మీ భాషను ఎంచుకోండి',
      'ta': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    };

    final Map<String, String> confirmationTexts = {
      'en': 'English selected',
      'hi': 'हिंदी चुनी गई',
      'te': 'తెలుగు ఎంచుకోబడింది',
      'ta': 'தமிழ் தேர்ந்தெடுக்கப்பட்டது',
    };

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  welcomeTexts[languageProvider.currentLocale.languageCode] ?? 'Choose your language',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select a language to continue',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48),
                
                // Language Cards
                ...AppConstants.supportedLanguages.entries.map((entry) {
                  final isSelected = languageProvider.currentLocale.languageCode == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () {
                        languageProvider.setLanguage(entry.key);
                        // Speak confirmation in the newly selected language
                        final message = confirmationTexts[entry.key] ?? 'Language selected';
                        ttsService.speak(message, languageCode: entry.key);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.value,
                                style: TextStyle(
                                  color: isSelected ? theme.colorScheme.primary : Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isSelected) 
                                Icon(Icons.check_circle, color: theme.colorScheme.primary)
                              else 
                                const Icon(Icons.circle_outlined, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Go directly to Splash Screen which handles first launch logic (Login/Onboarding)
                    Navigator.pushReplacementNamed(context, AppConstants.routeSplash);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continue ➔',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
