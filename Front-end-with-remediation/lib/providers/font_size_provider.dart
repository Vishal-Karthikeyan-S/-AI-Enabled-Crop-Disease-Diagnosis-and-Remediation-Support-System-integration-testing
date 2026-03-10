import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';

class FontSizeProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  late FontSize _currentFontSize;

  FontSizeProvider(this._prefs) {
    int index = _prefs.getFontSizeIndex();
    _currentFontSize = FontSize.values[index];
  }

  FontSize get currentFontSize => _currentFontSize;

  double get scaleFactor {
    switch (_currentFontSize) {
      case FontSize.small:
        return AppConstants.fontSizeSmall;
      case FontSize.medium:
        return AppConstants.fontSizeMedium;
      case FontSize.large:
        return AppConstants.fontSizeLarge;
    }
  }

  void setFontSize(FontSize size) {
    _currentFontSize = size;
    _prefs.setFontSizeIndex(size.index);
    notifyListeners();
  }
}
