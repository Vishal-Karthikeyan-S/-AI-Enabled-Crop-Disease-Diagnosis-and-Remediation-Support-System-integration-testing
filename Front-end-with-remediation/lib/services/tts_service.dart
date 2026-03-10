import 'package:flutter/foundation.dart';
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
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('TTS init error (likely web platform): $e');
      }
    }
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (!isEnabled) return;
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      if (languageCode != null) {
        await _flutterTts.setLanguage(languageCodes[languageCode] ?? 'en-US');
      }
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('TTS speak error (likely web platform): $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (kDebugMode) {
        print('TTS stop error: $e');
      }
    }
  }
}
