import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LanguageProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  late Locale _currentLocale;

  LanguageProvider(this._prefs) {
    _currentLocale = Locale(_prefs.getLanguage());
  }

  Locale get currentLocale => _currentLocale;

  void setLanguage(String langCode) {
    _currentLocale = Locale(langCode);
    _prefs.setLanguage(langCode);
    notifyListeners();
  }
}
