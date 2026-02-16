import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/font_size_provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/results_screen.dart';
import 'screens/treatment_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/intro_screen.dart';

class CropDiseaseApp extends StatelessWidget {
  const CropDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLanguages.keys
          .map((code) => Locale(code))
          .toList(),

      // Theme
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Font Scaling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontSizeProvider.scaleFactor),
          ),
          child: child!,
        );
      },

      // Routes
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        switch (settings.name) {
          case AppConstants.routePreview:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PreviewScreen(
                imagePath: args['imagePath'],
                submission: args['submission'],
              ),
            );
          case AppConstants.routeResults:
            final submissionId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ResultsScreen(submissionId: submissionId),
            );
          case AppConstants.routeTreatment:
            final diseaseId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TreatmentScreen(diseaseId: diseaseId),
            );
          default:
            return null;
        }
      },
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
        AppConstants.routeSplash: (context) => const SplashScreen(),
        AppConstants.routeOnboarding: (context) => const OnboardingScreen(),
        // Home should include the bottom navigation bar.
        AppConstants.routeHome: (context) => const MainNavigation(),
        AppConstants.routeSettings: (context) => const SettingsScreen(),
        AppConstants.routeCamera: (context) => const CameraScreen(),
        AppConstants.routeGallery: (context) => const GalleryScreen(),
      },
    );
  }
}
