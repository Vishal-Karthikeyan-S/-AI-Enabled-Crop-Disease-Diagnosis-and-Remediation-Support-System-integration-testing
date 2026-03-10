import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import 'language_selection_screen.dart';
import 'login_screen.dart';

/// A StatefulWidget that decides the first screen to show.
/// By being stateful, it makes the decision ONCE and never re-evaluates
/// it on provider rebuilds. This prevents the language screen from
/// being auto-redirected when providers (LanguageProvider, ThemeProvider)
/// fire their notifyListeners() calls at startup.
class LandingRouter extends StatefulWidget {
  const LandingRouter({super.key});

  @override
  State<LandingRouter> createState() => _LandingRouterState();
}

class _LandingRouterState extends State<LandingRouter> {
  // Determined once in initState, never changes again.
  late bool _showLanguageScreen;

  @override
  void initState() {
    super.initState();
    // Read synchronously from prefs — this is a cached value, always fast.
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    _showLanguageScreen = !prefs.hasLanguageBeenChosen();
  }

  @override
  Widget build(BuildContext context) {
    if (_showLanguageScreen) {
      return const LanguageSelectionScreen();
    }
    return const LoginScreen();
  }
}
