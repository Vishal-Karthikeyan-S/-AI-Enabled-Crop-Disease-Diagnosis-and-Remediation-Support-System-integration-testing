import 'package:flutter_tts/flutter_tts.dart';

import 'preferences_service.dart';

class SpeechService {
  final PreferencesService _prefs;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Map app language codes -> TTS locale codes
  static const Map<String, String> _languageCodes = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
  };

  SpeechService(this._prefs);

  bool get isEnabled => _prefs.isVoiceEnabled();

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);

    // Default language (will be overridden per speak())
    await _tts.setLanguage(_languageCodes['en']!);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text, String languageCode) async {
    if (!isEnabled) return;
    final locale = _languageCodes[languageCode] ?? _languageCodes['en']!;
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}
