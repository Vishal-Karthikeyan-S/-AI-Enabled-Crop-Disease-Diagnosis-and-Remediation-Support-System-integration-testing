import 'package:flutter_tts/flutter_tts.dart';

import 'preferences_service.dart';

class TtsService {
  final PreferencesService _prefs;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService(this._prefs);

  bool get isEnabled => _prefs.isVoiceEnabled();

  static const Map<String, String> languageCodes = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
  };

  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    _isInitialized = true;
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (!isEnabled) return;
    if (!_isInitialized) await init();
    await _flutterTts.stop();
    if (languageCode != null) {
      await _flutterTts.setLanguage(languageCodes[languageCode] ?? 'en-US');
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
